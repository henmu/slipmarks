import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:slipmarks/screens/home.dart';
import 'package:slipmarks/screens/login.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF1F1F1F),
    ),
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
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
