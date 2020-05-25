import 'package:flutter/material.dart';
import 'package:socket/src/style.dart';

import 'src/screen/login.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: darkTheme,
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}
