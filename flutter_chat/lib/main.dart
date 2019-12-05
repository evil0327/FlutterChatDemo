import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat/bloc/app_bloc.dart';
import 'package:flutter_chat/bloc/chat_message_bloc.dart';
import 'package:flutter_chat/login_screen.dart';
import 'package:flutter_chat/repo/api_repository.dart';
import 'package:flutter_chat/repo/local_repository.dart';
import 'package:flutter_chat/util/cache.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

import 'chat_screen.dart';

AppBloc _appBloc =  AppBloc();

void main() {
  _initCache();
  _initFcm();
  runApp(MyApp());
}

Future _initCache() async {
 String uid = await LocalRepository.instance.getUid();
 Cache.uid = uid;
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppBloc>(
            create: (_) => _appBloc,
            dispose: (context, value) => value.dispose()
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(primarySwatch: Colors.blue),
        routes: <String, WidgetBuilder>{
          // Set routes for using the Navigator.
          '/login': (BuildContext context) => LoginScreen(),
          '/chat': (BuildContext context) => ChatScreen(title: "ChatRoom"),
        },
        home: FutureBuilder(
          // get the Provider, and call the getUser method
          future: LocalRepository.instance.isLogin(),
          // wait for the future to resolve and render the appropriate
          // widget for HomePage or LoginPage
          builder: (context, AsyncSnapshot<bool> snapshot) {
            if (snapshot.hasData && snapshot.data == true) {
              _listenUsers();
              return ChatScreen(title: "ChatRoom");
            } else {
              return LoginScreen();
            }
          },
        ),
      ),
    );
  }
}

void _listenUsers(){
  _appBloc.listenToNewUser();
}

void _initFcm(){
  FirebaseMessaging().configure(
    onMessage: (Map<String, dynamic> message) async {
      print("onMessage: $message");
    },
    onLaunch: (Map<String, dynamic> message) async {
      print("onLaunch: $message");
    },
    onResume: (Map<String, dynamic> message) async {
      print("onResume: $message");
    },
  );
}

