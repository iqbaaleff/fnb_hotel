import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fnb_hotel/models/produk.dart';

class ApiService {
  final Dio _dio = Dio();

  /// Simpan token ke SharedPreferences
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  /// Ambil token dari SharedPreferences
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// API Cemilan
  Future<List<Product>> getProductsCemilan() async {
    const String url =
        'https://74gslzvj-3000.asse.devtunnels.ms/api/produk/cemilan';

    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan. Silakan login kembali.');
      }

      Response response = await _dio.get(
        url,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token', // Tambahkan token ke header
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        List<dynamic> data = response.data['data'];
        return data.map((product) => Product.fromJson(product)).toList();
      } else {
        throw Exception(
          'Error ${response.statusCode}: ${response.data['message'] ?? 'Tidak diketahui'}',
        );
      }
    } catch (e) {
      print('Kesalahan API Cemilan: $e');
      throw Exception('Gagal memuat produk cemilan: $e');
    }
  }

  /// API Coffe
  Future<List<Product>> getProductsCoffe() async {
    const String url =
        'https://74gslzvj-3000.asse.devtunnels.ms/api/produk/coffe';

    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan. Silakan login kembali.');
      }

      Response response = await _dio.get(
        url,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token', // Tambahkan token ke header
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        List<dynamic> data = response.data['data'];
        return data.map((product) => Product.fromJson(product)).toList();
      } else {
        throw Exception(
          'Error ${response.statusCode}: ${response.data['message'] ?? 'Tidak diketahui'}',
        );
      }
    } catch (e) {
      print('Kesalahan API Coffee: $e');
      throw Exception('Gagal memuat produk coffee: $e');
    }
  }
}
