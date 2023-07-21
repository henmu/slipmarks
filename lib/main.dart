import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:slipmarks/screens/home.dart';
import 'package:slipmarks/screens/login.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF1F1F1F),
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: <String, WidgetBuilder>{
        '/': (BuildContext context) {
          return const Login();
        },
        '/home': (BuildContext context) {
          return const Home();
        }
      },
    );
  }
}
