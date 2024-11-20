import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fnb_hotel/screens/login.dart';

Future<void> logout(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Menghapus token dan role
  await prefs.remove('token');
  await prefs.remove('role');

  // Menampilkan snackbar untuk konfirmasi logout
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('You have logged out successfully!')),
  );

  // Mengarahkan pengguna kembali ke halaman login
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => const Login()),
    (route) => false, // Hapus semua route sebelumnya
  );
}
