import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: size.width * 0.5,
                  height: size.height,
                  color: Colors.red,
                ),
                Container(
                  width: size.width * 0.45,
                  height: size.height * 0.9,
                  color: Colors.white,
                ),
              ],
            ),
            Container(
              width: size.width * 0.5,
              height: size.height,
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }
}
