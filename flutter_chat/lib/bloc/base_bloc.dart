import 'package:rxdart/rxdart.dart';

class BaseBloc{
  final PublishSubject<String> _errorSubject = PublishSubject<String>();
  PublishSubject<String> get errorSubject => _errorSubject;

  dispose(){
    _errorSubject.close();
  }

}