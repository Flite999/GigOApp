import 'package:flutter/material.dart';
import 'login_page.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'Gig-O-Matic',
        theme: new ThemeData(
          primarySwatch: Colors.green,
        ),
        home: new LoginPage());
  }
}
