import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat/bloc/base_bloc.dart';
import 'package:flutter_chat/model/chat_message.dart';
import 'package:flutter_chat/model/status.dart';
import 'package:flutter_chat/repo/api_repository.dart';
import 'package:flutter_chat/repo/local_repository.dart';
import 'package:flutter_chat/util/cache.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

class ChatMessageBloc extends BaseBloc{
  final BehaviorSubject<List<ChatMessage>> _messagesSubject = BehaviorSubject<List<ChatMessage>>.seeded([]);
  final BehaviorSubject<Status> _loadingStatusSubject = BehaviorSubject<Status>.seeded(Status.Success);
  StreamSubscription _streamSubscription;
  ApiRepository _apiRepository = ApiRepository.instance;

  void listenToNewMessage(int timestamp){
    print("listenToNewMessage timestamp="+timestamp.toString());
    if(_streamSubscription!=null){
      _streamSubscription.cancel();
    }
    _streamSubscription = _apiRepository.listenToNewMessage(timestamp).listen((querySnapshot){
      print("listenToNewMessage querySnapshot");
      List<ChatMessage> list = querySnapshot.documents.map((doc){
        return ChatMessage(id: doc.documentID, message: doc.data['message'], uid : doc.data["uid"], createTime: doc.data["createTime"]);
      }).toList();

      if(list==null || list.length==0){
        return;
      }

      List<ChatMessage> current = _messagesSubject.value;
      print("listenToNewMessage list="+list.length.toString());
      if(current!=null){
        list.forEach((message){
          if(!current.contains(message)){
            current.insert(0, message);
            _messagesSubject.add(current);
            print("listenToNewMessage add message="+ message.message);

            listenToNewMessage(current[0].createTime);
          }
        });
      }else{
        _messagesSubject.add(list);
        listenToNewMessage(list[0].createTime);

        list.forEach((message){print(message.message);});
      }

    });
  }

  void sendMessage(String message){
    String uuid = Uuid().v4();
    ChatMessage chatMessage = ChatMessage(id : uuid, message: message, uid: Cache.uid, createTime: DateTime.now().millisecondsSinceEpoch, status: Status.Loading);
    var list = _messagesSubject.value;
    list.insert(0, chatMessage);

    _messagesSubject.add(list);
    _apiRepository.sendMessage(chatMessage).listen((dynamic){
          chatMessage.status = Status.Success;
          _messagesSubject.add(list);
          print("send success");
      }
    ).onError((e){
      errorSubject.add("sendMessage error");
      print("error");
    });
  }

  void getMessages(int createTime){
      print("getMessages createTime=$createTime");
      if(_loadingStatusSubject.value == Status.Loading || _loadingStatusSubject.value == Status.No_Data){
        return;
      }
      _loadingStatusSubject.add(Status.Loading);

      _apiRepository.getMessages(createTime).delay(new Duration(seconds: 1)).listen((querySnapshot){
        print("getMessages querySnapsho");
       List<ChatMessage> list = querySnapshot.documents.map((doc){
         return ChatMessage(id: doc.documentID, message: doc.data['message'], uid : doc.data["uid"], createTime: doc.data["createTime"]);
       }).toList();

        List<ChatMessage> current = _messagesSubject.value;

       if(list==null || list.length==0){
         _loadingStatusSubject.add(Status.No_Data);
         //if no data on backend, we listen from timestamp of now
         if(current==null || current.length==0){
           listenToNewMessage(DateTime.now().millisecondsSinceEpoch);
         }
         return;
       }else{
         _loadingStatusSubject.add(Status.Success);
       }
        print("getMessages querySnapsho list="+list.length.toString());

       if(current!=null && current.length>0){
         _messagesSubject.add(current+list);
       }else{
         _messagesSubject.add(list);
         listenToNewMessage(list[0].createTime);
       }

       list.forEach((message){print(message.message);});
     }).onError((e){
          errorSubject.add("get message error");
          print("error");
      });
  }

  notifyDataChanged(){
    _messagesSubject.add(_messagesSubject.value);
  }

  BehaviorSubject<List<ChatMessage>> get messagesSubject => _messagesSubject;
  BehaviorSubject<Status> get loadingStatusSubject => _loadingStatusSubject;

  @override
  dispose() {
    super.dispose();
    _messagesSubject.close();
    loadingStatusSubject.close();
  }

}