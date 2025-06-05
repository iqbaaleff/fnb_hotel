import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Assuming logoutFunction.dart exists and contains a logout function
import 'package:fnb_hotel/services/logoutFunction.dart';

enum ProductCategory { makanan, minuman, cemilan }

// Extension to capitalize enum strings
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

class AppColors {
  static const primary = Color(0xff0C085C);
  static const accent = Color(0xffE22323);
}

class AddProduct extends StatefulWidget {
  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final _formKey = GlobalKey<FormState>();
  final Dio _dio = Dio();
  final ImagePicker _picker = ImagePicker();
  final CancelToken _cancelToken = CancelToken();

  // Controllers
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _hargaAwalController = TextEditingController();
  final TextEditingController _hargaJualController = TextEditingController();
  final TextEditingController _stokController = TextEditingController();

  ProductCategory _kategoriProduk = ProductCategory.makanan;
  String? _fotoProduk;
  bool _isLoading = false;

  final NumberFormat currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  // Helper function to safely execute setState or ScaffoldMessenger
  void _safeExecute(VoidCallback callback) {
    if (mounted) {
      callback();
    }
  }

  // Format currency input
  void _onHargaChanged(String value, TextEditingController controller) {
    String sanitizedValue = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (sanitizedValue.isNotEmpty) {
      final int parsedValue = int.parse(sanitizedValue);
      final String formattedValue = currencyFormat.format(parsedValue);
      controller.value = TextEditingValue(
        text: formattedValue,
        selection: TextSelection.collapsed(offset: formattedValue.length),
      );
    } else {
      controller.clear();
    }
  }

  // Parse currency string to int
  int? _parseCurrency(String value) {
    try {
      String sanitizedValue = value.replaceAll(RegExp(r'[^0-9]'), '');
      return sanitizedValue.isNotEmpty ? int.parse(sanitizedValue) : null;
    } catch (e) {
      return null;
    }
  }

  // Get token from SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Pick image with validation
  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final sizeInMB = (await file.length()) / (1024 * 1024);
        if (sizeInMB > 5) {
          _safeExecute(() {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Ukuran gambar terlalu besar (maks 5MB)')),
            );
          });
          return;
        }
        _safeExecute(() {
          setState(() {
            _fotoProduk = pickedFile.path;
          });
        });
      }
    } catch (e) {
      _safeExecute(() {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih gambar: $e')),
        );
      });
    }
  }

  // Submit form to API
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final token = await _getToken();
      if (token == null) {
        _safeExecute(() {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Token tidak ditemukan. Silakan login kembali.')),
          );
        });
        return;
      }

      final hargaAwal = _parseCurrency(_hargaJualController.text);
      final hargaJual = _parseCurrency(_hargaJualController.text);
      if (hargaAwal == null || hargaJual == null) {
        _safeExecute(() {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Harga tidak valid')),
          );
        });
        return;
      }

      _safeExecute(() {
        setState(() {
          _isLoading = true;
        });
      });

      final formData = FormData.fromMap({
        'judul_produk': _judulController.text,
        'hargaAwal': hargaJual,
        'hargaJual': hargaJual,
        'stok': int.parse(_stokController.text),
        'kategori_produk': _kategoriProduk.toString().split('.').last,
        'foto_produk': _fotoProduk != null
            ? await MultipartFile.fromFile(_fotoProduk!)
            : null,
      });

      try {
        final response = await _dio.post(
          'https://zshnvs5v-3000.asse.devtunnels.ms/api/produk',
          data: formData,
          options: Options(headers: {'Authorization': 'Bearer $token'}),
          cancelToken: _cancelToken,
        );

        if (response.statusCode == 201) {
          _safeExecute(() {
            setState(() {
              _formKey.currentState?.reset();
              _judulController.clear();
              _hargaAwalController.clear();
              _hargaJualController.clear();
              _stokController.clear();
              _kategoriProduk = ProductCategory.makanan;
              _fotoProduk = null;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Produk berhasil ditambahkan!')),
            );
            Navigator.pop(context, true);
          });
        } else {
          _safeExecute(() {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text('Gagal menambahkan produk: ${response.statusCode}')),
            );
          });
        }
      } on DioException catch (e) {
        if (e.response?.statusCode == 401) {
          _safeExecute(() {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Sesi telah berakhir. Silakan login kembali.')),
            );
          });
          await logout(context); // Ensure logout function is implemented
        } else {
          _safeExecute(() {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Terjadi kesalahan: ${e.message}')),
            );
          });
        }
      } catch (e) {
        _safeExecute(() {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Terjadi kesalahan tidak terduga: $e')),
          );
        });
      } finally {
        _safeExecute(() {
          setState(() {
            _isLoading = false;
          });
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
        title: const Text(
          'Tambah Produk',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(
            color: AppColors.accent,
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
                    labelStyle: const TextStyle(color: AppColors.primary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: AppColors.accent, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: AppColors.accent, width: 2),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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

                // Harga Jual
                TextFormField(
                  controller: _hargaJualController,
                  onChanged: (value) =>
                      _onHargaChanged(value, _hargaJualController),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Harga Jual',
                    labelStyle: const TextStyle(color: AppColors.primary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: AppColors.accent, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: AppColors.accent, width: 2),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                    labelStyle: const TextStyle(color: AppColors.primary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: AppColors.accent, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: AppColors.accent, width: 2),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Stok tidak boleh kosong';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Stok harus berupa angka';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Kategori Produk
                DropdownButtonFormField<ProductCategory>(
                  value: _kategoriProduk,
                  items: ProductCategory.values
                      .map((kategori) => DropdownMenuItem(
                            value: kategori,
                            child: Text(kategori
                                .toString()
                                .split('.')
                                .last
                                .capitalize()),
                          ))
                      .toList(),
                  onChanged: (value) {
                    _safeExecute(() {
                      setState(() {
                        _kategoriProduk = value!;
                      });
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Kategori',
                    labelStyle: const TextStyle(color: AppColors.primary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: AppColors.accent, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: AppColors.accent, width: 2),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  ),
                  dropdownColor: Colors.white,
                  style: const TextStyle(color: AppColors.primary),
                ),
                const SizedBox(height: 16),

                // Foto Produk
                ElevatedButton(
                  onPressed: _isLoading ? null : _pickImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    _fotoProduk == null ? 'Pilih Foto' : 'Ganti Foto',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                if (_fotoProduk != null)
                  Container(
                    height: 200,
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 16),
                    child: Image.file(File(_fotoProduk!), fit: BoxFit.cover),
                  ),
                const SizedBox(height: 16),

                // Submit and Reset Buttons
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accent,
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
                    ],
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
