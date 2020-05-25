import 'package:flutter/material.dart';
import 'package:socket/src/model/user.dart';

enum UserOnlineStatus { connecting, online, offline }

class ChatTitle extends StatelessWidget {
  final UserOnlineStatus userOnlineStatus;
  final User toChatUser;

  const ChatTitle(
      {Key key, @required this.toChatUser, @required this.userOnlineStatus});
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            toChatUser.name,
            style: TextStyle(fontSize: 20),
          ),
          Text(_getStatusText(),
              style: TextStyle(fontSize: 17, color: Colors.white70)),
        ],
      ),
    );
  }

  _getStatusText() {
    if (userOnlineStatus == UserOnlineStatus.online) {
      return "online";
    }
    if (userOnlineStatus == UserOnlineStatus.offline) {
      return "offline";
    }
    return "connecting....";
  }
}
