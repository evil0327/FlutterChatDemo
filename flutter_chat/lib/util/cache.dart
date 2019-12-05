import 'package:flutter_chat/model/user.dart';

class Cache{
  static String uid;
  static Map<String, User> userCache = Map();

  static void putUser(String id, User user){
    userCache[id] = user;
  }

  static User getUser(String id){
    return userCache[id];
  }

  static String getUserName(String id){
    return userCache[id]==null ? "" : userCache[id].name;
  }
}