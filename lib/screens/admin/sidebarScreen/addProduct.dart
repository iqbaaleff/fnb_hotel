import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:fnb_hotel/services/logoutFunction.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
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
  final TextEditingController _hargaAwalController = TextEditingController();
  final TextEditingController _hargaJualController = TextEditingController();
  final TextEditingController _stokController = TextEditingController();

  String _kategoriProduk = 'Makanan';
  String? _fotoProduk;

  final ImagePicker _picker = ImagePicker();
  final CancelToken _cancelToken = CancelToken();

  final NumberFormat currencyFormat = NumberFormat.currency(
    locale: 'id_ID', // Locale Indonesia
    symbol: 'Rp ', // Simbol mata uang
    decimalDigits: 0,
  );

  void _onHargaAwalChanged(String value) {
    String sanitizedValue = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (sanitizedValue.isNotEmpty) {
      final int parsedValue = int.parse(sanitizedValue);
      final String formattedValue = currencyFormat.format(parsedValue);
      _hargaAwalController.value = TextEditingValue(
        text: formattedValue,
        selection: TextSelection.collapsed(offset: formattedValue.length),
      );
    } else {
      _hargaAwalController.clear();
    }
  }

  void _onHargaJualChanged(String value) {
    String sanitizedValue = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (sanitizedValue.isNotEmpty) {
      final int parsedValue = int.parse(sanitizedValue);
      final String formattedValue = currencyFormat.format(parsedValue);
      _hargaJualController.value = TextEditingValue(
        text: formattedValue,
        selection: TextSelection.collapsed(offset: formattedValue.length),
      );
    } else {
      _hargaJualController.clear();
    }
  }

  // API Endpoint
  final String apiUrl = 'https://zshnvs5v-3000.asse.devtunnels.ms/api/produk';

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
        'hargaAwal': int.parse(_hargaAwalController.text),
        'hargaJual': int.parse(_hargaJualController.text),
        'stok': int.parse(_stokController.text),
        'kategori_produk': _kategoriProduk,
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
              'Authorization': 'Bearer $token',
            },
          ),
          cancelToken: _cancelToken,
        );

        if (response.statusCode == 201) {
          if (mounted) {
            setState(() {
              _judulController.clear();
              _hargaAwalController.clear();
              _hargaJualController.clear();
              _stokController.clear();
              _kategoriProduk = 'Makanan';
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
    _cancelToken.cancel();
    _judulController.dispose();
    _hargaAwalController.dispose();
    _hargaJualController.dispose();
    _stokController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Produk',
            style: TextStyle(
              color: Color(0xff0C085C),
              fontWeight: FontWeight.bold,
            )),
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
        backgroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(
            color: const Color(0xffE22323),
            height: 2.0,
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
                    labelStyle: TextStyle(
                      color: Color(0xff0C085C),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          BorderSide(color: Color(0xffE22323), width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          BorderSide(color: Color(0xffE22323), width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Judul produk tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Harga Awal
                TextFormField(
                  controller: _hargaAwalController,
                  onChanged: _onHargaAwalChanged,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Harga Awal',
                    labelStyle: TextStyle(
                      color: Color(0xff0C085C),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          BorderSide(color: Color(0xffE22323), width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          BorderSide(color: Color(0xffE22323), width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Harga awal tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Harga Jual
                TextFormField(
                  controller: _hargaJualController,
                  onChanged: _onHargaJualChanged,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Harga Jual',
                    labelStyle: TextStyle(
                      color: Color(0xff0C085C),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          BorderSide(color: Color(0xffE22323), width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          BorderSide(color: Color(0xffE22323), width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Harga jual tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Stok
                TextFormField(
                  controller: _stokController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Stok',
                    labelStyle: TextStyle(
                      color: Color(0xff0C085C),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          BorderSide(color: Color(0xffE22323), width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          BorderSide(color: Color(0xffE22323), width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Stok tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Kategori Produk
                DropdownButtonFormField<String>(
                  value: _kategoriProduk,

                  items: ['Makanan', 'Minuman', 'Cemilan']
                      .map((kategori) => DropdownMenuItem(
                            value: kategori,
                            child: Text(kategori),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _kategoriProduk = value!;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Role',
                    labelStyle: TextStyle(
                      color: Color(0xff0C085C),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          BorderSide(color: Color(0xffE22323), width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          BorderSide(color: Color(0xffE22323), width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                  ),
                  dropdownColor: Colors.white, // Warna latar dropdown
                  style: TextStyle(
                    color: Color(0xff0C085C), // Warna teks dalam dropdown
                  ),
                ),
                const SizedBox(height: 16),

                // Foto Produk
                ElevatedButton(
                  onPressed: _pickImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xffE22323),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    _fotoProduk == null ? 'Pilih Foto' : 'Ganti Foto',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                if (_fotoProduk != null) Image.file(File(_fotoProduk!)),

                const SizedBox(height: 16),

                // Tombol Submit
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xffE22323),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: _submitForm,
                    child: const Text(
                      'Simpan Produk',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
