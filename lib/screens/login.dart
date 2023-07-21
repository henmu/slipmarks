import 'package:flutter/material.dart';
import 'package:slipmarks/screens/home.dart';
import 'package:slipmarks/services/auth_service.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool isProgressing = false;
  bool isLoggedIn = false;
  String errorMessage = '';
  String? name;

  setSuccessAuthState() {
    setState(() {
      isProgressing = false;
      isLoggedIn = true;
      name = AuthService.instance.idToken?.name;
    });

    navigateToHomePage(context);
  }

  setLoadingState() {
    setState(() {
      isProgressing = true;
      errorMessage = '';
    });
  }

  Future<void> loginAction() async {
    setLoadingState();
    final message = await AuthService.instance.login();
    if (message == 'Success') {
      setSuccessAuthState();
    } else {
      setState(() {
        isProgressing = false;
        errorMessage = message;
      });
    }
  }

  initAction() async {
    setLoadingState();
    final bool isAuth = await AuthService.instance.init();
    if (isAuth) {
      setSuccessAuthState();
    } else {
      setState(() {
        isProgressing = false;
      });
    }
  }

  @override
  void initState() {
    initAction();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: const Color(0xFF1f1f1f),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if (isProgressing)
            const CircularProgressIndicator()
          else if (!isLoggedIn)
            ElevatedButton(
                onPressed: loginAction,
                child: const Text(
                  'Login | Register2',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ))
          else
            Text(
              'Welcome $name',
              style: const TextStyle(
                fontFamily: 'Inter',
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
        ], // <Widget>[]
      ),
    ));
  }
}

void navigateToHomePage(BuildContext context) {
  // Replace the oldRoute with the appropriate route name that you want to replace
  // Replace the newRoute with the appropriate route name for the homepage widget
  Navigator.replace(
    context,
    oldRoute: ModalRoute.of(context)!,
    newRoute:
        MaterialPageRoute(builder: (BuildContext context) => const Home()),
  );
}
// class LoginPage extends StatelessWidget {
//   const LoginPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//       backgroundColor: Colors.transparent,
//       body: Center(
//         child: Text(
//           'This is the Login page ${const String.fromEnvironment("AUTH0_DOMAIN")}',
//           style: TextStyle(
//             fontFamily: 'Inter',
//             color: Colors.white,
//           ),
//         ),
//       ),
//     );
//   }
// }
