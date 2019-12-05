import 'package:flutter_chat/model/status.dart';
import 'package:flutter_chat/repo/api_repository.dart';
import 'package:rxdart/rxdart.dart';
import 'base_bloc.dart';

class LoginBloc extends BaseBloc{
  final BehaviorSubject<Status> _loadingStatusSubject = BehaviorSubject<Status>.seeded(Status.No_Data);
  ApiRepository _apiRepository = ApiRepository.instance;

  BehaviorSubject<Status> get loadingStatusSubject => _loadingStatusSubject;

  void login(String name){
    _loadingStatusSubject.add(Status.Loading);
    print("LoginBloc login");
    _apiRepository.login(name).delay(Duration(seconds: 3)).listen((v){
      print("LoginBloc login success");
      _loadingStatusSubject.add(Status.Success);
    });
  }

  @override
  dispose() {
    super.dispose();
  }
}