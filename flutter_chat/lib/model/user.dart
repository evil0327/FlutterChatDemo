import 'package:equatable/equatable.dart';

class User extends Equatable{
String id;
String name;
String avatar;

User({this.id, this.name, this.avatar});

@override
// TODO: implement props
List<Object> get props => [id];
}