import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:fnb_hotel/screens/admin/sidebarScreen/addProduct.dart';
import 'package:fnb_hotel/screens/admin/sidebarScreen/editProduct.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fnb_hotel/services/logoutFunction.dart';

class ProductList extends StatefulWidget {
  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  final Dio _dio = Dio();
  final String apiUrl = 'https://zshnvs5v-3000.asse.devtunnels.ms/api/produk';
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
        'https://zshnvs5v-3000.asse.devtunnels.ms/api/delete/$id',
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
              style: TextButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteProduct(id);
              },
              child: const Text(
                'Hapus',
                style: TextStyle(color: Colors.white),
              ),
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
            color: Color(0xffE22323),
          ),
        ),
        backgroundColor: Colors.white,
        actions: [
          ElevatedButton(
            onPressed: () {
              // Panggil fungsi logout
              logout(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xffE22323),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.logout_rounded,
                  color: Colors.white,
                ),
                Text(
                  "Logout",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                )
              ],
            ),
          ),
          SizedBox(
            width: 30,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0), // Ketebalan garis
          child: Container(
            color: Color(0xffE22323), // Warna garis
            height: 2.0, // Tinggi garis (ketebalan)
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _produkList.isEmpty
              ? const Center(child: Text('Tidak ada data produk'))
              : Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 25),
                      child: Container(
                        width: 300,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddProduct(),
                                ));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xffE22323),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add,
                                color: Colors.white,
                              ),
                              Text(
                                "Tambah Produk",
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            dataRowColor: MaterialStateColor.resolveWith(
                                (states) => Colors.grey[200]!),
                            headingRowColor: MaterialStateColor.resolveWith(
                                (states) => const Color(0xffE22323)),
                            columns: const [
                              DataColumn(
                                  label: Text(
                                'No',
                                style: TextStyle(color: Colors.white),
                              )),
                              DataColumn(
                                  label: Text(
                                'Foto',
                                style: TextStyle(color: Colors.white),
                              )),
                              DataColumn(
                                  label: Text(
                                'Judul Produk',
                                style: TextStyle(color: Colors.white),
                              )),
                              DataColumn(
                                  label: Text(
                                'Harga',
                                style: TextStyle(color: Colors.white),
                              )),
                              DataColumn(
                                  label: Text(
                                'Stok',
                                style: TextStyle(color: Colors.white),
                              )),
                              DataColumn(
                                  label: Text(
                                'Kategori',
                                style: TextStyle(color: Colors.white),
                              )),
                              DataColumn(
                                  label: Text(
                                'Aksi',
                                style: TextStyle(color: Colors.white),
                              )),
                            ],
                            rows: _produkList.asMap().entries.map((entry) {
                              final index = entry.key;
                              final produk = entry.value;
                              return DataRow(cells: [
                                DataCell(Text('${index + 1}')),
                                DataCell(
                                  produk['foto_produk'] != null
                                      ? Image.network(
                                          'https://zshnvs5v-3000.asse.devtunnels.ms${produk['foto_produk']}',
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error,
                                                  stackTrace) =>
                                              const Icon(
                                                  Icons.image_not_supported),
                                        )
                                      : const Icon(Icons.image_not_supported),
                                ),
                                DataCell(Text(produk['judul_produk'] ?? '-')),
                                DataCell(Text(
                                    'Rp ${produk['hargaJual']?.toString() ?? '-'}')),
                                DataCell(
                                    Text(produk['stok']?.toString() ?? '-')),
                                DataCell(
                                    Text(produk['kategori_produk'] ?? '-')),
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
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => EditProduct(
                                                productData: produk),
                                          ),
                                        ).then((success) {
                                          if (success == true) {
                                            // Refresh data produk jika diperlukan
                                          }
                                        });
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
                  ],
                ),
    );
  }
}
