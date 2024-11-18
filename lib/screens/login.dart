import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:fnb_hotel/screens/homepage.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final Dio _dio = Dio(); // Menggunakan plugin Dio untuk menghubungkan server

  bool _isLoading = false; // Status untuk tombol loading
  bool _secureText = true;

  void _login() async {
    setState(() {
      _isLoading = true; // Menampilkan loading indicator
    });

    final username = usernameController.text;
    final password = passwordController.text;

    try {
      final response = await _dio.post(
        'https://74gslzvj-8000.asse.devtunnels.ms/api/login', // URL API
        data: {
          'username': username,
          'password': password,
        },
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login berhasil')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Homepage(), // Pindah halaman jika berhasil
          ),
        );
      } else {
        throw Exception("Login gagal");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login gagal')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Sembunyikan loading indicator
      });
    }
  }

  void showhide() {
    setState(() {
      _secureText = !_secureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Row(
        children: [
          _loginForm(size),
          _imageSection(size),
        ],
      ),
    );
  }

  Widget _loginForm(Size size) {
    return Expanded(
      child: Container(
        color: const Color(0xFF2C2C54),
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Container(
            width: size.width * 0.5,
            height: size.height,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white, width: 1.0),
            ),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('assets/images/logo.png'),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Sign In",
                      style: GoogleFonts.josefinSans(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: usernameController,
                      hintText: "Username",
                      icon: Icons.person_2,
                      obscureText: false,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: passwordController,
                      hintText: "Password",
                      icon: Icons.lock,
                      obscureText: _secureText,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _secureText ? Icons.visibility : Icons.visibility_off,
                          color: const Color(0xFF1C1C1C),
                        ),
                        onPressed: showhide,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : _login, // Nonaktifkan tombol saat loading
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero, // Hapus padding default
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 0, // Sesuaikan bayangan
                      ),
                      child: Container(
                        width: size.width * 0.1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFF48181), Color(0xFFED3838)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        alignment: Alignment.center,
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              )
                            : Text(
                                "Login",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height * 0.1,
      width: size.width * 0.3,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.black),
          suffixIcon: suffixIcon,
          hintText: hintText,
          hintStyle: GoogleFonts.josefinSans(
            color: Colors.black,
            fontWeight: FontWeight.w400,
            fontSize: size.width * 0.012,
          ),
          fillColor: const Color(0xFFE3FFF3),
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(size.width * 0.009),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _imageSection(Size size) {
    return Expanded(
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/images/hotel.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.5)),
          Center(
            child: Container(
              width: size.width * 0.4,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 1.0),
              ),
              child: Text(
                "Welcome Cashier!",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 40,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
