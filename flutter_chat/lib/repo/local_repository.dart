import 'package:shared_preferences/shared_preferences.dart';

class LocalRepository {
  factory LocalRepository() => _getInstance();

  static LocalRepository get instance => _getInstance();
  static LocalRepository _instance;

  LocalRepository._internal() {
  }

  static LocalRepository _getInstance() {
    if (_instance == null) {
      _instance = new LocalRepository._internal();
    }
    return _instance;
  }

  void saveUid(String uid) async{
    var preferences = await SharedPreferences.getInstance();
    preferences.setString('uid', uid);
  }

  Future<String> getUid() async{
    var preferences = await SharedPreferences.getInstance();
    return preferences.get("uid");
  }

  Future<bool> isLogin() async{
    var preferences = await SharedPreferences.getInstance();
    return preferences.get("uid") != null && preferences.get("uid") != "";
  }

}