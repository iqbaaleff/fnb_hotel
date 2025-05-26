import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:fnb_hotel/services/logoutFunction.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProduct extends StatefulWidget {
  final Map<String, dynamic> productData;

  const EditProduct({Key? key, required this.productData}) : super(key: key);

  @override
  _EditProductState createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  final _formKey = GlobalKey<FormState>();
  final Dio _dio = Dio();

  // Controllers
  late final TextEditingController _judulController;
  late final TextEditingController _hargaAwalController;
  late final TextEditingController _hargaJualController;
  late final TextEditingController _stokController;

  late String _kategoriProduk;
  String? _fotoProduk;
  File? _imageFile;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();
  final CancelToken _cancelToken = CancelToken();

  final NumberFormat currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing product data
    _judulController =
        TextEditingController(text: widget.productData['judul_produk']);
    _hargaAwalController = TextEditingController(
      text: currencyFormat.format(widget.productData['hargaAwal']),
    );
    _hargaJualController = TextEditingController(
      text: currencyFormat.format(widget.productData['hargaJual']),
    );
    _stokController =
        TextEditingController(text: widget.productData['stok'].toString());
    _kategoriProduk = widget.productData['kategori_produk'];
    _fotoProduk = widget.productData['foto_produk'];
  }

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
  String get apiUrl =>
      'https://zshnvs5v-3000.asse.devtunnels.ms/api/produk/${widget.productData['id']}';

  // Fungsi untuk mengambil token dari SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Fungsi untuk mengupdate data produk
  Future<void> _updateProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

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
        'hargaAwal': int.parse(
            _hargaJualController.text.replaceAll(RegExp(r'[^0-9]'), '')),
        'hargaJual': int.parse(
            _hargaJualController.text.replaceAll(RegExp(r'[^0-9]'), '')),
        'stok': int.parse(_stokController.text),
        'kategori_produk': _kategoriProduk,
        'foto_produk': _imageFile != null
            ? await MultipartFile.fromFile(_imageFile!.path)
            : _fotoProduk,
      });

      try {
        final response = await _dio.put(
          apiUrl,
          data: formData,
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ),
          cancelToken: _cancelToken,
        );

        if (response.statusCode == 200) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Produk berhasil diperbarui!')),
            );
            Navigator.pop(context, true); // Return true to indicate success
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Gagal memperbarui produk!')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Terjadi kesalahan: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
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
          _imageFile = File(pickedFile.path);
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
        title: const Text('Edit Produk',
            style: TextStyle(
              color: Color(0xff0C085C),
              fontWeight: FontWeight.bold,
            )),
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
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
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
                          labelText: 'Kategori Produk',
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
                        dropdownColor: Colors.white,
                        style: TextStyle(
                          color: Color(0xff0C085C),
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
                          _imageFile == null ? 'Pilih Foto' : 'Ganti Foto',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_imageFile != null)
                        Image.file(_imageFile!, height: 200)
                      else if (_fotoProduk != null && _fotoProduk!.isNotEmpty)
                        Image.network(_fotoProduk!, height: 200),

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
                          onPressed: _updateProduct,
                          child: const Text(
                            'Update Produk',
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
