import 'package:dart_numerics/dart_numerics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/model/app_event.dart';
import 'package:flutter_chat/model/chat_message.dart';
import 'package:flutter_chat/util/cache.dart';
import 'package:provider/provider.dart';
import 'bloc/app_bloc.dart';
import 'bloc/chat_message_bloc.dart';
import 'model/status.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController textEditingController =
      new TextEditingController();
  ScrollController _listScrollController;
  final FocusNode focusNode = new FocusNode();

  ChatMessageBloc bloc = ChatMessageBloc();

  @override
  void initState() {
    super.initState();
    _listScrollController = new ScrollController();
    _listScrollController.addListener(_scrollListener);

    bloc.getMessages(int64MaxValue);
  }

  _scrollListener() {
    if (_listScrollController.offset >=
            _listScrollController.position.maxScrollExtent - 100 &&
        !_listScrollController.position.outOfRange) {
      var list = bloc.messagesSubject.value;
      if (list != null && list.length > 0) {
        int lastTime = list.last.createTime;
        bloc.getMessages(lastTime);
      }
    }
  }

  void _init(BuildContext context){
    AppBloc _appBloc = Provider.of<AppBloc>(context);
    _appBloc.eventPublishSubject.listen((event){
      if(event.eventType == EventType.USER_UPDATED){
        print("chat scree got EventType.USER_UPDATED");
        bloc.notifyDataChanged();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _init(context);

    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
        ),
        body: WillPopScope(
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  // List of messages
                  buildListWidget(),
                  // Input content
                  buildInput(),
                ],
              ),
            ],
          ),
        ));
  }

  Widget buildListWidget() {
    return Flexible(
      child: StreamBuilder<List<ChatMessage>>(
          stream: bloc.messagesSubject.stream,
          builder: (context, AsyncSnapshot<List<ChatMessage>> snapshot) {
            if (!snapshot.hasData) {
              return Text("no data");
            }
            var _items = snapshot.data;
            return new ListView.builder(
                controller: _listScrollController,
                itemCount: _items.length + 1,
                reverse: true,
                itemBuilder: (context, i) {
                  if (i == _items.length) {
                    return buildLoadingWidget();
                  }
                  return buildTextWidget(_items[i]);
                });
          }),
    );
  }

  Widget buildTextWidget(ChatMessage chatMessage) {
    if (chatMessage.uid == Cache.uid) {
      return buildMeTextWidget(chatMessage);
    }
    return buildFriendTextWidget(chatMessage);
  }

  Widget buildMeTextWidget(ChatMessage chatMessage) {
    return Container(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Visibility(
            visible: chatMessage.status == Status.Loading,
            child: Container(
                margin: EdgeInsets.only(right: 10.0),
                child: Image.asset(
                  'assets/images/upper_left_arrow.png',
                  height: 10,
                  width: 10,
                )),
          ),
          Container(
            child: Text(
              chatMessage.message,
              style: new TextStyle(
                color: Colors.white,
                fontSize: 15.0,
              ),
            ),
            constraints: BoxConstraints(minWidth: 50, maxWidth: 300),
            padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
            decoration: BoxDecoration(
                color: Colors.lightBlue,
                borderRadius: BorderRadius.circular(20.0)),
            margin: EdgeInsets.only(bottom: 10.0, top: 5.0, right: 15.0),
          )
        ],
      ),
    );
  }

  Widget buildLoadingWidget() {
    return StreamBuilder<Status>(
        stream: bloc.loadingStatusSubject.stream,
        builder: (context, AsyncSnapshot<Status> snapshot) {
          var _status = snapshot.data;
          if (_status == Status.Loading) {
            return new Container(
              margin: EdgeInsets.only(bottom: 15.0, top: 15.0),
                child: Center(child: const CircularProgressIndicator())
            );
          } else if (_status == Status.No_Data) {
            return Text("");
          } else {
            return Text("");
          }
        });
  }

  Widget buildFriendTextWidget(ChatMessage chatMessage) {
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: 10.0, left: 15.0),
            child: CircleAvatar(
              backgroundImage: NetworkImage(
                  "https://pm1.narvii.com/7253/a2bc868224523e4d627a5d08a1c4cdbc001fd072r1-1952-1080v2_128.jpg"),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(left: 15.0),
                child: Text(
                  Cache.getUserName(chatMessage.uid),
                  style: new TextStyle(
                    color: Colors.grey,
                    fontSize: 15.0,
                  ),
                ),
              ),
              Container(
                child: Text(
                  chatMessage.message,
                  style: new TextStyle(
                    color: Colors.black,
                    fontSize: 15.0,
                  ),
                ),
                constraints: BoxConstraints(minWidth: 50, maxWidth: 300),
                padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                decoration: BoxDecoration(
                    color: Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(20.0)),
                margin: EdgeInsets.only(bottom: 10.0, top: 5.0, left: 10.0),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget buildInput() {
    return Container(
      child: Row(
        children: <Widget>[
          // Edit text
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                style: TextStyle(color: Colors.black, fontSize: 15.0),
                controller: textEditingController,
                decoration: InputDecoration.collapsed(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                focusNode: focusNode,
              ),
            ),
          ),
          // Button send message
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 8.0),
              child: new IconButton(
                icon: new Icon(Icons.send),
                onPressed: () {
                  bloc.sendMessage(textEditingController.text);
                  textEditingController.clear();
                },
                color: Colors.blue,
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: new BoxDecoration(
          border: new Border(
              top: new BorderSide(color: Colors.black12, width: 0.5)),
          color: Colors.white),
    );
  }
}
