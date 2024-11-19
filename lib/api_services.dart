import 'package:dio/dio.dart';
import 'package:fnb_hotel/models/produk.dart';

class ApiService {
  final Dio _dio = Dio();

  //API Cemilan
  Future<List<Product>> getProductsCemilan() async {
    const String url =
        'https://xrzwvx14-5000.asse.devtunnels.ms/api/produk/cemilan';

    try {
      Response response = await _dio.get(url);

      if (response.statusCode == 200 && response.data['success'] == true) {
        List<dynamic> data = response.data['data'];
        return data.map((product) => Product.fromJson(product)).toList();
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      throw Exception('Failed to load products: $e');
    }
  }

  //API Coffe
  Future<List<Product>> getProductsCoffe() async {
    const String url =
        'https://xrzwvx14-5000.asse.devtunnels.ms/api/produk/coffe';

    try {
      Response response = await _dio.get(url);

      if (response.statusCode == 200 && response.data['success'] == true) {
        List<dynamic> data = response.data['data'];
        return data.map((product) => Product.fromJson(product)).toList();
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      throw Exception('Failed to load products: $e');
    }
  }
}
