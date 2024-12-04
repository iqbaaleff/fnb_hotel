import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductList extends StatefulWidget {
  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  final Dio _dio = Dio();
  final String apiUrl = 'https://74gslzvj-3000.asse.devtunnels.ms/api/produk';
  List<dynamic> _produkList = [];
  bool _isLoading = true;

  Future<String?> _getToken() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString('token');
    } catch (e) {
      debugPrint('Error mendapatkan token: $e');
      return null;
    }
  }

  Future<void> _fetchProducts() async {
    try {
      final token = await _getToken();

      if (token == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Token tidak ditemukan, silakan login ulang')),
          );
        }
        return;
      }

      final response = await _dio.get(
        apiUrl,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        setState(() {
          _produkList = response.data is List
              ? response.data
              : (response.data['data'] ?? []);
          _isLoading = false;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Gagal memuat data: ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error saat mengambil produk: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
      }
    }
  }

  Future<void> _deleteProduct(int id) async {
    try {
      final token = await _getToken();
      if (token == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Token tidak ditemukan, silakan login ulang')),
          );
        }
        return;
      }

      final response = await _dio.delete(
        'https://74gslzvj-3000.asse.devtunnels.ms/api/delete/$id',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Produk berhasil dihapus')),
          );
        }
        _fetchProducts(); // Refresh data
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Gagal menghapus produk: ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error saat menghapus produk: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
      }
    }
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text('Apakah Anda yakin ingin menghapus produk ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteProduct(id);
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daftar Produk',
          style: TextStyle(
            color: Color(0xFF22E284),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _produkList.isEmpty
              ? const Center(child: Text('Tidak ada data produk'))
              : Center(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        dataRowColor: MaterialStateColor.resolveWith(
                            (states) => Colors.grey[200]!),
                        headingRowColor: MaterialStateColor.resolveWith(
                            (states) => const Color(0xFF22E284)),
                        columns: const [
                          DataColumn(label: Text('No')),
                          DataColumn(label: Text('Foto')),
                          DataColumn(label: Text('Judul Produk')),
                          DataColumn(label: Text('Harga')),
                          DataColumn(label: Text('Kategori')),
                          DataColumn(label: Text('Sub Kategori')),
                          DataColumn(label: Text('Aksi')),
                        ],
                        rows: _produkList.asMap().entries.map((entry) {
                          final index = entry.key;
                          final produk = entry.value;
                          return DataRow(cells: [
                            DataCell(Text('${index + 1}')),
                            DataCell(
                              produk['foto_produk'] != null
                                  ? Image.network(
                                      'https://74gslzvj-3000.asse.devtunnels.ms/${produk['foto_produk']}',
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error,
                                              stackTrace) =>
                                          const Icon(Icons.image_not_supported),
                                    )
                                  : const Icon(Icons.image_not_supported),
                            ),
                            DataCell(Text(produk['judul_produk'] ?? '-')),
                            DataCell(Text(produk['harga']?.toString() ?? '-')),
                            DataCell(Text(produk['kategori_produk'] ?? '-')),
                            DataCell(
                                Text(produk['sub_kategori_produk'] ?? '-')),
                            DataCell(Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () {
                                    _confirmDelete(produk['id']);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Fitur update belum diimplementasikan')),
                                    );
                                  },
                                ),
                              ],
                            )),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
                ),
    );
  }
}
