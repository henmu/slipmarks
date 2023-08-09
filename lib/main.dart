import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:slipmarks/elements/add_bookmark_dialog.dart';
import 'package:slipmarks/firebase_options.dart';
import 'package:slipmarks/screens/home.dart';
import 'package:slipmarks/screens/login.dart';

import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;

// Define a GlobalKey to access the root Navigator's context
GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Set up the MethodChannel handler after initializing WidgetsFlutterBinding
  const MethodChannel channel = MethodChannel('web_content_share');
  channel.setMethodCallHandler(_handleMethodCall);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF1F1F1F),
    ),
  );

  runApp(
    ProviderScope(
      child: MaterialApp(
        navigatorKey: navigatorKey, // Set the global key here
        theme: ThemeData.dark(),
        routes: <String, WidgetBuilder>{
          '/': (BuildContext context) {
            return const Login();
          },
          '/home': (BuildContext context) {
            return const Home();
          },
        },
      ),
    ),
  );
}

Future<void> _handleMethodCall(MethodCall call) async {
  if (call.method == 'handleSharedContent') {
    String sharedContent = call.arguments;
    // Fetch the webpage content using http package
    String webpageContent = await fetchWebpageContent(sharedContent);

    // Parse the HTML content to extract the title
    String pageTitle = parseTitleFromHTML(webpageContent);

    // Use the context from the global navigator key to show the add bookmark dialog
    showAddBookmarkDialog(navigatorKey.currentContext!,
        name: pageTitle, url: sharedContent);
  }
}

// Fetch the webpage content using http package
Future<String> fetchWebpageContent(String url) async {
  http.Response response = await http.get(Uri.parse(url));
  return response.body;
}

// Parse the title from the HTML content
String parseTitleFromHTML(String htmlContent) {
  var document = html_parser.parse(htmlContent);
  var titleElement = document.head?.querySelector('title');

  if (titleElement != null) {
    return titleElement.text;
  } else {
    return ''; // Default title if no title tag is found
  }
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
        },
      },
    );
  }
}
