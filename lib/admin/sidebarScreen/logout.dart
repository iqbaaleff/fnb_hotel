import 'package:flutter/material.dart';
import 'package:fnb_hotel/logoutFunction/logoutFunction.dart';

class LogoutAdmin extends StatefulWidget {
  const LogoutAdmin({super.key});

  @override
  State<LogoutAdmin> createState() => _LogoutAdminState();
}

class _LogoutAdminState extends State<LogoutAdmin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            logout(context);
          },
          child: Text("Logout"),
        ),
      ),
    );
  }
}
