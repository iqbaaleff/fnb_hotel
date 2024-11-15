import 'package:dio/dio.dart';
import 'package:fnb_hotel/models/produk.dart';


class ApiService {
  final Dio _dio = Dio();

  //API Tanaman
  Future<List<Product>> getProductsTanaman() async {
    const String url =
        'https://74gslzvj-8000.asse.devtunnels.ms/api/filterdanGet?kategori=tanaman';

    try {
      Response response = await _dio.get(url);
      print(response.data);
      List<dynamic> data = response.data;

      // Konversi data JSON menjadi daftar objek Product
      return data.map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load products: $e');
    }
  }

  //API Ikan
  Future<List<Product>> getProductsIkan() async {
    const String url =
        'https://74gslzvj-8000.asse.devtunnels.ms/api/filterdanGet?kategori=ikan';

    try {
      Response response = await _dio.get(url);
      print(response.data);
      List<dynamic> data = response.data;

      // Konversi data JSON menjadi daftar objek Product
      return data.map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load products: $e');
    }
  }

  //API Burung
  Future<List<Product>> getProductsBurung() async {
    const String url =
        'https://74gslzvj-8000.asse.devtunnels.ms/api/filterdanGet?kategori=burung';

    try {
      Response response = await _dio.get(url);
      print(response.data);
      List<dynamic> data = response.data;

      // Konversi data JSON menjadi daftar objek Product
      return data.map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load products: $e');
    }
  }
}