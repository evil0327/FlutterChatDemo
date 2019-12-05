import 'package:equatable/equatable.dart';
import 'package:flutter_chat/model/status.dart';

// ignore: must_be_immutable
class ChatMessage extends Equatable{
  String id;
  String message;
  String uid;
  int createTime;
  Status status;

  ChatMessage({this.id, this.message, this.uid, this.createTime, this.status});

  @override
  // TODO: implement props
  List<Object> get props => [id];
}