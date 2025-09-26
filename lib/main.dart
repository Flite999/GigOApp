import 'package:flutter/material.dart';
import 'screens/login.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  await dotenv.load();
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Gig-O-Matic',
        theme: new ThemeData(
          primarySwatch: Colors.green,
        ),
        home: new LoginPage());
  }
}
