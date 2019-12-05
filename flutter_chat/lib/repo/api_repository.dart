import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_chat/model/chat_message.dart';
import 'package:flutter_chat/repo/local_repository.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

class ApiRepository {
  var _databaseReference;
  FirebaseMessaging _fcm;

  LocalRepository _localRepository;

  factory ApiRepository() => _getInstance();

  static ApiRepository get instance => _getInstance();
  static ApiRepository _instance;

  ApiRepository._internal() {
    _databaseReference = Firestore.instance;
    _fcm = FirebaseMessaging();
    _localRepository = LocalRepository.instance;
  }

  static ApiRepository _getInstance() {
    if (_instance == null) {
      _instance = new ApiRepository._internal();
    }
    return _instance;
  }

  Observable<QuerySnapshot> listenToNewMessage(int timestamp) {
    return Observable<QuerySnapshot>(_databaseReference
        .collection('messages')
        .where("createTime", isGreaterThan: timestamp)
        .orderBy('createTime', descending: false)
        .snapshots());
  }

  Observable sendMessage(ChatMessage chatMessage) {
    return Observable.fromFuture(_localRepository.getUid().then((uid) {
      _databaseReference
          .collection("messages")
          .document(chatMessage.id)
          .setData({
        'message': chatMessage.message,
        'createTime': chatMessage.createTime,
        'uid': uid
      });
    }));
  }

  Observable<QuerySnapshot> getMessages(int time) {
    return Observable<QuerySnapshot>.fromFuture(_databaseReference
        .collection('messages')
        .where("createTime", isLessThan: time)
        .orderBy('createTime', descending: true)
        .limit(20)
        .getDocuments());
  }

  Observable login(String nickname) {
    String uid = Uuid().v4();
    return Observable.fromFuture(_fcm.getToken().then((token) {
      _databaseReference.collection("users").document(uid).setData({
        'name': nickname,
        'uid': uid,
        'token': token,
      });
      LocalRepository.instance.saveUid(uid);
    }));
  }

  Observable<QuerySnapshot> listenUsers() {
    return Observable<QuerySnapshot>(_databaseReference
        .collection('users')
        .snapshots());
  }
}
