import 'package:flutter/material.dart';
import 'package:flutter_chat/bloc/app_bloc.dart';
import 'package:flutter_chat/bloc/login_bloc.dart';
import 'package:flutter_chat/model/status.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  LoginBloc _loginBloc = LoginBloc();
  TextEditingController _nameController = new TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AppBloc _appBloc =  Provider.of<AppBloc>(context);
    _loginBloc.loadingStatusSubject.listen((status){
      if(status==Status.Success){
        _appBloc.listenToNewUser();
        Navigator.of(context).pushReplacementNamed("/chat");
      }
    });

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(16.0),
            height: double.infinity,
            decoration: BoxDecoration(
                gradient:
                    LinearGradient(colors: [Colors.lightBlue, Colors.blue])),
            child: Column(
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(top: 40.0, bottom: 20.0),
                  height: 80,
                  // child: PNetworkImage(foodLogo)
                ),
                Text(
                  "Flutter Chat".toUpperCase(),
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 40.0),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(16.0),
                    prefixIcon: Container(
                        padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                        margin: const EdgeInsets.only(right: 8.0),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30.0),
                                bottomLeft: Radius.circular(30.0),
                                topRight: Radius.circular(30.0),
                                bottomRight: Radius.circular(10.0))),
                        child: Icon(
                          Icons.person,
                          color: Colors.lightBlueAccent,
                        )),
                    hintText: "enter your nickname",
                    hintStyle: TextStyle(color: Colors.white54),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                  ),
                ),
                SizedBox(height: 30.0),
                SizedBox(
                  width: double.infinity,
                  child: RaisedButton(
                    color: Colors.white,
                    textColor: Colors.blue,
                    padding: const EdgeInsets.all(20.0),
                    child: Text("Enter ChatRoom".toUpperCase()),
                    onPressed: () {
                      _login();
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                  ),
                ),
              ],
            ),
          ),
          loadingWidget(),
        ],
      ),
    );
  }

  void _login() {
    FocusScope.of(context).unfocus();
    String name = _nameController.text;
    if (name != null && name.trim() != "") {
      _loginBloc.login(name);
    } else {}

  }

  Widget loadingWidget() {
    return StreamBuilder<Object>(
      stream: _loginBloc.loadingStatusSubject.stream,
      builder: (context, snapshot) {
        return Visibility(
          visible: snapshot.hasData && snapshot.data == Status.Loading,
          child: Stack(
            children: <Widget>[
              Opacity(
                  opacity: 0.8,
                  child: ModalBarrier(
                    color: Colors.black87,
                  )),
              Center(
                child: CircularProgressIndicator(),
              )
            ],
          ),
        );
      }
    );
  }
}
