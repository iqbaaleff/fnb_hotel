import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fnb_hotel/screens/homepage.dart';
import 'package:fnb_hotel/admin/sidebar.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final Dio _dio = Dio();
  bool _isLoading = false;
  bool _secureText = true;

  void _login() async {
    setState(() {
      _isLoading = true;
    });

    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username dan Password wajib diisi')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await _dio.post(
        'https://74gslzvj-3000.asse.devtunnels.ms/api/login', // Ganti dengan endpoint login backend Anda
        data: {
          'username': username,
          'password': password,
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );
      if (response.statusCode == 200) {
        final role = response.data['user']['role'];
        final token = response.data['token'];
        final kasirName =
            response.data['user']['username']; // Mengambil username

        // Simpan token, role, dan username ke SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('role', role);
        await prefs.setString('username', kasirName); // Simpan username

        // Navigasi berdasarkan role
        if (role == 'kasir') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Homepage()),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login sebagai Kasir berhasil')),
          );
        } else if (role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const SidebarAdmin(isAdmin: true),
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login sebagai Admin berhasil')),
          );
        } else {
          throw Exception('Role tidak dikenali');
        }
      } else {
        throw Exception('Login gagal, periksa kredensial Anda');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login gagal: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void showhide() {
    setState(() {
      _secureText = !_secureText;
    });
  }

  Future<void> _checkToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Token: $token')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token tidak ditemukan')),
      );
    }
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
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 0,
                      ),
                      child: Container(
                        width: size.width * 0.1,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
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
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
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
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/hotel.png'),
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
