import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fnb_hotel/services/logoutFunction.dart'; // Assuming this exists

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

class EditProduct extends StatefulWidget {
  final Map<String, dynamic> productData;

  const EditProduct({Key? key, required this.productData}) : super(key: key);

  @override
  _EditProductState createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  final _formKey = GlobalKey<FormState>();
  final Dio _dio = Dio();
  final ImagePicker _picker = ImagePicker();
  final CancelToken _cancelToken = CancelToken();

  // Controllers
  late final TextEditingController _judulController;
  late final TextEditingController _hargaAwalController;
  late final TextEditingController _hargaJualController;
  late final TextEditingController _stokController;

  late ProductCategory _kategoriProduk;
  String? _fotoProduk;
  File? _imageFile;
  bool _isLoading = false;

  final NumberFormat currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  // Base URL for images
  static const String baseUrl = 'https://zshnvs5v-3000.asse.devtunnels.ms';

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing product data
    _judulController =
        TextEditingController(text: widget.productData['judul_produk']);
    _hargaAwalController = TextEditingController(
      text: currencyFormat.format(widget.productData['hargaAwal'] ?? 0),
    );
    _hargaJualController = TextEditingController(
      text: currencyFormat.format(widget.productData['hargaJual'] ?? 0),
    );
    _stokController = TextEditingController(
        text: widget.productData['stok']?.toString() ?? '');
    _kategoriProduk = ProductCategory.values.firstWhere(
      (e) =>
          e.toString().split('.').last == widget.productData['kategori_produk'],
      orElse: () => ProductCategory.makanan,
    );
    // Fix relative paths by prepending base URL
    _fotoProduk = widget.productData['foto_produk']?.startsWith('http')
        ? widget.productData['foto_produk']
        : widget.productData['foto_produk'] != null
            ? '$baseUrl${widget.productData['foto_produk']}'
            : null;
  }

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
            _imageFile = file;
            _fotoProduk = null; // Clear network image when new file is selected
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

  // Update product via API
  Future<void> _updateProduct() async {
    if (_formKey.currentState!.validate()) {
      _safeExecute(() {
        setState(() {
          _isLoading = true;
        });
      });

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
        _safeExecute(() {
          setState(() {
            _isLoading = false;
          });
        });
        return;
      }

      final formData = FormData.fromMap({
        'judul_produk': _judulController.text,
        'hargaAwal': hargaJual,
        'hargaJual': hargaJual,
        'stok': int.parse(_stokController.text),
        'kategori_produk': _kategoriProduk.toString().split('.').last,
        'foto_produk': _imageFile != null
            ? await MultipartFile.fromFile(_imageFile!.path)
            : _fotoProduk,
      });

      try {
        final response = await _dio.put(
          '$baseUrl/api/produk/${widget.productData['id']}',
          data: formData,
          options: Options(headers: {'Authorization': 'Bearer $token'}),
          cancelToken: _cancelToken,
        );

        if (response.statusCode == 200) {
          _safeExecute(() {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Produk berhasil diperbarui!')),
            );
            Navigator.pop(context, true);
          });
        } else {
          _safeExecute(() {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text('Gagal memperbarui produk: ${response.statusCode}')),
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
          await logout(context);
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

  // Reset form
  void _resetForm() {
    _safeExecute(() {
      setState(() {
        _formKey.currentState?.reset();
        _judulController.text = widget.productData['judul_produk'] ?? '';
        _hargaAwalController.text =
            currencyFormat.format(widget.productData['hargaAwal'] ?? 0);
        _hargaJualController.text =
            currencyFormat.format(widget.productData['hargaJual'] ?? 0);
        _stokController.text = widget.productData['stok']?.toString() ?? '';
        _kategoriProduk = ProductCategory.values.firstWhere(
          (e) =>
              e.toString().split('.').last ==
              widget.productData['kategori_produk'],
          orElse: () => ProductCategory.makanan,
        );
        _imageFile = null;
        _fotoProduk = widget.productData['foto_produk']?.startsWith('http')
            ? widget.productData['foto_produk']
            : widget.productData['foto_produk'] != null
                ? '$baseUrl${widget.productData['foto_produk']}'
                : null;
      });
    });
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
          'Edit Produk',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(4.0),
          child: Divider(
            color: AppColors.accent,
            height: 2.0,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
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
                            borderSide: const BorderSide(
                                color: AppColors.accent, width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: AppColors.accent, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
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
                            borderSide: const BorderSide(
                                color: AppColors.accent, width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: AppColors.accent, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
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
                            borderSide: const BorderSide(
                                color: AppColors.accent, width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: AppColors.accent, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
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
                          labelText: 'Kategori Produk',
                          labelStyle: const TextStyle(color: AppColors.primary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: AppColors.accent, width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: AppColors.accent, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
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
                          _imageFile == null && _fotoProduk == null
                              ? 'Pilih Foto'
                              : 'Ganti Foto',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_imageFile != null)
                        Container(
                          height: 200,
                          width: double.infinity,
                          child: Image.file(_imageFile!, fit: BoxFit.cover),
                        )
                      else if (_fotoProduk != null && _fotoProduk!.isNotEmpty)
                        Container(
                          height: 200,
                          width: double.infinity,
                          child: Image.network(
                            _fotoProduk!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Center(
                              child: Text(
                                'Gagal memuat gambar',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),

                      // Submit and Reset Buttons
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              onPressed: _isLoading ? null : _updateProduct,
                              child: const Text(
                                'Update Produk',
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
