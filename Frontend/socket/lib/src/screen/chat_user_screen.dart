import 'package:flutter/material.dart';
import 'package:socket/src/Global.dart';
import 'package:socket/src/model/user.dart';

import '../style.dart';
import 'chat_screen.dart';

class ChatUserScreen extends StatefulWidget {
  @override
  _ChatUserScreenState createState() => _ChatUserScreenState();
}

class _ChatUserScreenState extends State<ChatUserScreen> {
  List<User> _chatUsers;
  bool _connectedToSocket;
  String _connectMessage;

  @override
  void initState() {
    _connectedToSocket = false;
    _connectMessage = 'Connecting...';
    _chatUsers = G.getUsersFor(G.loggedInUsers);
    _connectToSocket();
    super.initState();
  }

  _connectToSocket() async {
    print(
        'Connectiong Logged In User ${G.loggedInUsers.name},${G.loggedInUsers.id}');

    G.initSocket();
    await G.socketUtils.initSocket(G.loggedInUsers);
    G.socketUtils.connectToSocket();
    G.socketUtils.setOnConnection(onConnection);
    G.socketUtils.setOnConnectionErrorListener(onConnectionError);
    G.socketUtils.setOnConnetionTimeOut(onConnectionTimeOut);
    G.socketUtils.setOnErrorListener(onError);
    G.socketUtils.setOnDisconnectListener(onDisconnect);
  }

  onConnection(data) {
    print('onConnection $data');
    setState(() {
      _connectedToSocket = true;
      _connectMessage = 'Connected to the socket';
    });
  }

  onConnectionError(data) {
    print('onConnectionError $data');
    setState(() {
      _connectedToSocket = false;
      _connectMessage = 'Connection Error';
    });
  }

  onConnectionTimeOut(data) {
    print('onConnectionTimeOut $data');
    setState(() {
      _connectedToSocket = false;
      _connectMessage = 'Connection TimeOut';
    });
  }

  onError(data) {
    print('onError $data');
    setState(() {
      _connectedToSocket = false;
      _connectMessage = 'Connection Error';
    });
  }

  onDisconnect(data) {
    print('onDisconnect $data');
    setState(() {
      _connectedToSocket = false;
      _connectMessage = 'Disconnected from the socket';
    });
  }

  @override
  void dispose() {
    G.socketUtils.closeConnection();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat App"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
      ),
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(30.0),
        child: Column(
          children: <Widget>[
            Text(
              _connectedToSocket ? 'Connected to the socket' : _connectMessage,
              style: TextStyle(color: orange, fontSize: 27),
            ),
            SizedBox(
              height: 50,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _chatUsers.length,
                itemBuilder: (context, index) {
                  User user = _chatUsers[index];
                  return Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: orange),
                    child: ListTile(
                      onTap: () {
                        G.toChatUser = user;
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ChatScreen()));
                      },
                      title: Text(
                        user.name,
                        style: TextStyle(fontSize: 20),
                      ),
                      subtitle: Text('Email ${user.email}',
                          style: TextStyle(fontSize: 17)),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
