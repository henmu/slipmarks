import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:slipmarks/firebase_options.dart';
import 'package:slipmarks/screens/home.dart';
import 'package:slipmarks/screens/login.dart';
import 'package:slipmarks/services/messaging_service.dart';

Future<void> main() async {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF1F1F1F),
    ),
  );

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Instance of MessagingService for handling notifications
  final _messagingService = MessagingService();

  @override
  void initState() {
    super.initState();
    // Initialize MessagingService to handle notifications
    _messagingService.init(context);
  }

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
