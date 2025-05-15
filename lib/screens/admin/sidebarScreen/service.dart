import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransactionService {
  final Dio _dio = Dio();

  // Fungsi untuk menyimpan token ke SharedPreferences
  Future<void> saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    print("Token disimpan: $token");
  }

  // Fungsi untuk mengambil token dari SharedPreferences
  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Fungsi untuk membuat transaksi
  Future<Map<String, dynamic>> createTransaction(
      String atasNama, List<Map<String, dynamic>> produk) async {
    try {
      String? token = await getToken(); // Ambil token dari SharedPreferences

      final response = await _dio.post(
        'https://zshnvs5v-3000.asse.devtunnels.ms/api/order',
        data: {
          'atasNama': atasNama,
          'produk': produk,
        },
        options: Options(
          headers: {
            if (token != null)
              'Authorization': 'Bearer $token', // Tambahkan token jika ada
          },
        ),
      );

      return response.data;
    } catch (e) {
      throw Exception('Failed to create transaction: $e');
    }
  }

  // Fungsi untuk cek token
  Future<bool> checkToken() async {
    String? token = await getToken();
    return token != null; // Mengembalikan true jika token ada
  }
}
