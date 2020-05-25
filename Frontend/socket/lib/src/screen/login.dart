import 'package:flutter/material.dart';
import 'package:socket/src/Global.dart';
import 'package:socket/src/model/user.dart';
import 'package:socket/src/screen/chat_user_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _usernameController;

  @override
  void initState() {
    _usernameController = new TextEditingController();
    G.initDummyUsers();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Made by Darshan Satra"),
      ),
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(30.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              cursorColor: Colors.orange,
              controller: _usernameController,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                  hintText: 'Username',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  filled: true,
                  contentPadding: EdgeInsets.all(20)),
            ),
            SizedBox(
              height: 20.0,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
              decoration: BoxDecoration(
                  color: Colors.green, borderRadius: BorderRadius.circular(10)),
              child: GestureDetector(
                  onTap: _loginButtonTap,
                  child: Text(
                    'LOGIN',
                    style: TextStyle(fontSize: 17),
                  )),
            )
          ],
        ),
      ),
    );
  }

  _loginButtonTap() {
    if (_usernameController.text.isEmpty) return;
    User me = G.dummyUsers[0];
    if (_usernameController.text != 'a') {
      me = G.dummyUsers[1];
    }

    G.loggedInUsers = me;
    _openChatUsersListScreen(context);
  }

  _openChatUsersListScreen(context) async {
    _usernameController.clear();
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ChatUserScreen(),
    ));
  }
}
