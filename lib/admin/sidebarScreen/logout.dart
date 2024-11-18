import 'package:flutter/material.dart';
import 'package:fnb_hotel/screens/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogoutPage extends StatefulWidget {
  const LogoutPage({super.key});

  @override
  _LogoutPageState createState() => _LogoutPageState();
}

class _LogoutPageState extends State<LogoutPage> {
  @override
  void initState() {
    super.initState();
    _logout();
  }

  // Fungsi untuk logout
  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Menghapus token dan role
    await prefs.remove('token');
    await prefs.remove('role');

    // Menampilkan snackbar untuk konfirmasi logout
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('You have logged out successfully!')),
    );

    // Mengarahkan pengguna kembali ke halaman login
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logout'),
      ),
      body: Center(
        child:
            CircularProgressIndicator(), // Menampilkan loading indicator selama proses logout
      ),
    );
  }
}
