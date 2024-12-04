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
  Future<List<Product>> getProductsMakanan() async {
    const String url =
        'https://74gslzvj-3000.asse.devtunnels.ms/api/produk/Makanan';

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
      print('Kesalahan API Makanan: $e');
      throw Exception('Gagal memuat produk makanan: $e');
    }
  }

  /// API Coffe
  Future<List<Product>> getProductsMinuman() async {
    const String url =
        'https://74gslzvj-3000.asse.devtunnels.ms/api/produk/Minuman';

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
      print('Kesalahan API Minuman: $e');
      throw Exception('Gagal memuat produk Minuman: $e');
    }
  }

  /// API
  Future<List<Product>> getProductsSnack() async {
    const String url =
        'https://74gslzvj-3000.asse.devtunnels.ms/api/produk/Cemilan';

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
      throw Exception('Gagal memuat produk Cemilan: $e');
    }
  }
}
