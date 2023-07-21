import 'package:flutter/material.dart';
import 'package:slipmarks/screens/login.dart';
import 'package:slipmarks/services/auth_service.dart';

class Links extends StatelessWidget {
  const Links({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(children: [
        const Text(
          'This is the Home page',
          style: TextStyle(
            fontFamily: 'Inter',
            color: Colors.white,
          ),
        ),
        ElevatedButton(
            onPressed: () async {
              await AuthService.instance.logout();
              if (context.mounted) {
                Navigator.of(context).replace(
                  oldRoute: ModalRoute.of(context)!,
                  newRoute: MaterialPageRoute(
                      builder: (BuildContext context) => const Login()),
                );
              }
            },
            child: const Text(
              'Logout',
              style: TextStyle(
                fontFamily: 'Inter',
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ))
      ]),
    );
  }
}
