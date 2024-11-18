import 'package:flutter/material.dart';
import 'package:fnb_hotel/screens/homepage.dart';
import 'package:fnb_hotel/screens/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "Food & Beverage",
      debugShowCheckedModeBanner: false,
      home: Login(),
    );
  }
}
