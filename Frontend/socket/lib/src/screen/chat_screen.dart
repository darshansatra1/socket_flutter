import 'dart:async';

import 'package:flutter/material.dart';
import 'package:socket/services/socket_utils.dart';
import 'package:socket/src/Global.dart';
import 'package:socket/src/model/chat_message_model.dart';
import 'package:socket/src/model/user.dart';
import 'package:socket/src/widget/chat_title.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController _chatTextController;
  List<ChatMessageModel> _chatMessages;
  User _toChatUser;
  UserOnlineStatus _userOnlineStatus;
  ScrollController _chatListController;

  @override
  void initState() {
    _chatTextController = TextEditingController();
    _chatListController = ScrollController(initialScrollOffset: 0);
    _chatMessages = List();
    _toChatUser = G.toChatUser;
    _userOnlineStatus = UserOnlineStatus.connecting;
    _initSocketListeners();
    _checkOnline();
    super.initState();
  }

  setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void dispose() {
    G.socketUtils.setOnlinUserStatusListener(null);
    G.socketUtils.setOnChatMessageReceiveListener(null);
    super.dispose();
  }

  _checkOnline() {
    ChatMessageModel chatMessageModel = ChatMessageModel(
        chatId: 0,
        to: _toChatUser.id,
        from: G.loggedInUsers.id,
        toUserOnlineStatus: false,
        message: '',
        chatType: SocketUtils.SINGLE_CHAT);
    G.socketUtils.checkOnline(chatMessageModel);
  }

  _initSocketListeners() async {
    G.socketUtils.setOnlinUserStatusListener(onUserStatus);
    G.socketUtils.setOnChatMessageReceiveListener(onChatMessageReceived);
  }

  onUserStatus(data) {
    print('onUserStatus $data');
    ChatMessageModel chatMessageModel = ChatMessageModel.fromJson(data);
    setState(() {
      _userOnlineStatus = chatMessageModel.toUserOnlineStatus
          ? UserOnlineStatus.online
          : UserOnlineStatus.offline;
    });
  }

  onChatMessageReceived(data) {
    print('onChatMessageReceived $data');
    ChatMessageModel chatMessageModel = ChatMessageModel.fromJson(data);
    chatMessageModel.isFromMe = false;
    processMessage(chatMessageModel);
    _chatListScrollToBottom();
  }

  processMessage(ChatMessageModel chatMessageModel) {
    setState(() {
      _chatMessages.add(chatMessageModel);
    });
  }

  _chatListScrollToBottom() {
    Timer(Duration(milliseconds: 100), () {
      if (_chatListController.hasClients) {
        _chatListController.animateTo(
            _chatListController.position.maxScrollExtent,
            duration: Duration(milliseconds: 100),
            curve: Curves.decelerate);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ChatTitle(
          toChatUser: _toChatUser,
          userOnlineStatus: _userOnlineStatus,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _chatListController,
              itemCount: _chatMessages.length,
              itemBuilder: (context, index) {
                ChatMessageModel chatMessageModel = _chatMessages[index];
                bool isFromMe = chatMessageModel.isFromMe;
                return Container(
                  alignment:
                      isFromMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                      padding: EdgeInsets.all(10.0),
                      margin: EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
                      decoration: BoxDecoration(
                          color: isFromMe ? Colors.orange : Colors.green,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                              bottomLeft: isFromMe
                                  ? Radius.circular(10)
                                  : Radius.circular(0),
                              bottomRight: isFromMe
                                  ? Radius.circular(0)
                                  : Radius.circular(10))),
                      child: Text(
                        chatMessageModel.message,
                        style: TextStyle(fontSize: 20),
                      )),
                );
              },
            ),
          ),
          _bottomChatArea()
        ],
      ),
    );
  }

  _bottomChatArea() {
    return Container(
      padding: EdgeInsets.all(10),
      child: Row(
        children: <Widget>[
          _chatTextArea(),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: _onSend,
          )
        ],
      ),
    );
  }

  _chatTextArea() {
    return Expanded(
      child: TextField(
        controller: _chatTextController,
        decoration: InputDecoration(
            enabledBorder:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            focusedBorder:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            contentPadding: EdgeInsets.all(10),
            hintText: 'Type...'),
      ),
    );
  }

  _onSend() {
    if (_chatTextController.text.isEmpty) return;
    print('Sending message to ${_toChatUser.name}, id : ${_toChatUser.id}');
    ChatMessageModel chatMessageModel = ChatMessageModel(
        chatId: 0,
        to: _toChatUser.id,
        from: G.loggedInUsers.id,
        toUserOnlineStatus: false,
        message: _chatTextController.text,
        chatType: SocketUtils.SINGLE_CHAT,
        isFromMe: true);
    _chatTextController.clear();
    processMessage(chatMessageModel);
    _chatListScrollToBottom();
    G.socketUtils.sendSingleChatMessage(chatMessageModel);
  }
}
