import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:fnb_hotel/admin/sidebarScreen/produkList/ProductList.dart';
import 'package:fnb_hotel/logoutFunction/logoutFunction.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddProduct extends StatefulWidget {
  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final _formKey = GlobalKey<FormState>();
  final Dio _dio = Dio();

  // Controllers
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  final TextEditingController _subKategoriController = TextEditingController();

  String _kategoriProduk = 'makanan';
  String? _fotoProduk;

  final ImagePicker _picker = ImagePicker(); // Instance ImagePicker
  final CancelToken _cancelToken = CancelToken(); // Untuk membatalkan request

  // API Endpoint
  final String apiUrl = 'https://74gslzvj-3000.asse.devtunnels.ms/api/produk';

  // Fungsi untuk mengambil token dari SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Fungsi untuk mengunggah data ke API
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final token = await _getToken();
      if (token == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Token tidak ditemukan. Silakan login kembali.'),
            ),
          );
        }
        return;
      }

      final formData = FormData.fromMap({
        'judul_produk': _judulController.text,
        'harga': int.parse(_hargaController.text),
        'kategori_produk': _kategoriProduk,
        'sub_kategori_produk': _subKategoriController.text,
        'foto_produk': _fotoProduk != null
            ? await MultipartFile.fromFile(_fotoProduk!)
            : null,
      });

      try {
        final response = await _dio.post(
          apiUrl,
          data: formData,
          options: Options(
            headers: {
              'Authorization': 'Bearer $token', // Menambahkan token ke header
            },
          ),
          cancelToken: _cancelToken, // Menggunakan cancelToken
        );

        if (response.statusCode == 201) {
          if (mounted) {
            setState(() {
              _judulController.clear();
              _hargaController.clear();
              _subKategoriController.clear();
              _kategoriProduk = 'makanan';
              _fotoProduk = null;
            });
          }
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Produk berhasil ditambahkan!')),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Gagal menambahkan produk!')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Terjadi kesalahan: $e')),
          );
        }
      }
    }
  }

  // Fungsi untuk memilih foto
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (mounted) {
        setState(() {
          _fotoProduk = pickedFile.path;
        });
      }
    }
  }

  @override
  void dispose() {
    _cancelToken.cancel(); // Batalkan semua operasi Dio
    _judulController.dispose();
    _hargaController.dispose();
    _subKategoriController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Produk'),
        backgroundColor: Colors.white,
        actions: [
          ElevatedButton(
            onPressed: () {
              // Panggil fungsi logout
              logout(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF22E284),
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
            color: Colors.black, // Warna garis
            height: 2.0, // Tinggi garis (ketebalan)
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Judul Produk
                TextFormField(
                  controller: _judulController,
                  decoration: InputDecoration(
                    labelText: 'Judul Produk',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Judul produk tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Harga Produk
                TextFormField(
                  controller: _hargaController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Harga',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Harga tidak boleh kosong';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Harga harus berupa angka';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Kategori Produk
                DropdownButtonFormField<String>(
                  value: _kategoriProduk,
                  decoration: InputDecoration(
                    labelText: 'Kategori Produk',
                    border: OutlineInputBorder(),
                  ),
                  items: ['makanan', 'minuman']
                      .map(
                        (kategori) => DropdownMenuItem(
                          value: kategori,
                          child: Text(kategori),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _kategoriProduk = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Sub Kategori Produk
                TextFormField(
                  controller: _subKategoriController,
                  decoration: InputDecoration(
                    labelText: 'Sub Kategori Produk',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Sub kategori tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Foto Produk
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text(
                      _fotoProduk == null ? 'Pilih Foto' : 'Ganti Foto Produk'),
                ),
                if (_fotoProduk != null) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Image.file(
                      File(_fotoProduk!), // Menampilkan gambar yang dipilih
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Foto terpilih: $_fotoProduk',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
                const SizedBox(height: 16),

                // Tombol Submit
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    child: Text('Simpan Produk'),
                  ),
                ),

                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProductList()),
                    );
                  },
                  child: Text('Lihat Daftar Produk'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
