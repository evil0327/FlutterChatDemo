import 'dart:async';

import 'package:flutter_chat/bloc/base_bloc.dart';
import 'package:flutter_chat/model/app_event.dart';
import 'package:flutter_chat/model/user.dart';
import 'package:flutter_chat/repo/api_repository.dart';
import 'package:flutter_chat/util/cache.dart';
import 'package:rxdart/rxdart.dart';

class AppBloc extends BaseBloc{
  PublishSubject<AppEvent> _eventPublishSubject = PublishSubject<AppEvent>();
  StreamSubscription _userStreamSubscription;
  ApiRepository _apiRepository = ApiRepository.instance;

  void sendEvent(AppEvent event){
    _eventPublishSubject.add(event);
  }


  void listenToNewUser(){
    print("listenToNewUser");
    if(_userStreamSubscription!=null){
      _userStreamSubscription.cancel();
    }
    _userStreamSubscription = _apiRepository.listenUsers().listen((querySnapshot){
      print("listenToNewUser querySnapshot");
      List<User> list = querySnapshot.documents.map((doc){
        return User(id: doc.documentID, name: doc.data['name']);
      }).toList();

      if(list==null || list.length==0){
        return;
      }

      print("listenToNewUser list="+list.length.toString());
      list.forEach((user){
        Cache.putUser(user.id, user);
        _eventPublishSubject.add(AppEvent(eventType: EventType.USER_UPDATED));
      });
    });
  }

  PublishSubject<AppEvent> get eventPublishSubject => _eventPublishSubject;

  @override
  dispose() {
    super.dispose();
    _eventPublishSubject.close();
  }
}