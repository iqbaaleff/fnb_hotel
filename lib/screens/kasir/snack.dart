import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fnb_hotel/services/api_services.dart';
import 'package:fnb_hotel/models/produk.dart';

class Snack extends StatefulWidget {
  final Size size;
  final Function(Product) onProductSelected;
  final Function(double) formatAngka;

  const Snack({
    Key? key,
    required this.size,
    required this.onProductSelected,
    required this.formatAngka,
  }) : super(key: key);

  @override
  State<Snack> createState() => _SnackState();
}

class _SnackState extends State<Snack> {
  Future<List<Product>>? _product;
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadToken(); // Ambil token saat widget diinisialisasi
  }

  Future<void> _loadToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token != null) {
        setState(() {
          _token = token;
          _product = ApiService().getProductsSnack();
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Token tidak ditemukan, silakan login ulang')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan saat mengambil token: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 8,
      child: Container(
        width: widget.size.width,
        height: widget.size.height,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: widget.size.width * 0.005),
          child: Column(
            children: [
              Expanded(
                child: FutureBuilder<List<Product>>(
                  future: _product,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No products available'));
                    }

                    final products = snapshot.data;

                    return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 5,
                        crossAxisCount: 5,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: products!.length,
                      itemBuilder: (context, index) {
                        final product = products[index];final isOutOfStock =
                            product.stok == null || product.stok! <= 0;
                        return GestureDetector(
                          onTap: () {
                            if (!isOutOfStock) {
                              widget.onProductSelected(
                                  product); // Produk bisa dipilih
                            } else {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor: Color(0xffE22323),
                                    title: Text(
                                      "Stok Habis",
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    actions: [
                                      Center(
                                        child: TextButton(
                                          style: TextButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                          ),
                                          child: Text(
                                            "OK",
                                            style: TextStyle(
                                              color: Color(0xffE22323),
                                            ),
                                          ),
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop(); // Menutup pop-up
                                          },
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          },
                          child: Opacity(
                            opacity: isOutOfStock
                                ? 0.5
                                : 1.0, // Turunkan opacity jika stok habis
                            child: Card(
                              color: isOutOfStock
                                  ? Colors.grey[300]
                                  : Colors
                                      .white, // Warna abu-abu untuk stok habis
                              elevation: isOutOfStock
                                  ? 1
                                  : 2, // Kurangi elevasi untuk stok habis
                              child: Column(
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: product.fotoProduk != null &&
                                              product.fotoProduk!.isNotEmpty
                                          ? Image.network(
                                              'https://74gslzvj-3000.asse.devtunnels.ms${product.fotoProduk!}',
                                              fit: BoxFit.fill,
                                              width: double.infinity,
                                            )
                                          : Container(
                                              color: Colors.grey[200],
                                              child: const Icon(
                                                  Icons.image_not_supported),
                                            ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                      left: widget.size.width * 0.007,
                                      right: widget.size.width * 0.007,
                                      bottom: widget.size.height * 0.02,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                            top: widget.size.height * 0.005,
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical:
                                                  widget.size.height * 0.005,
                                            ),
                                            child: Text(
                                              product.judulProduk,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: isOutOfStock
                                                    ? Colors.grey
                                                    : Color(0xff0C085C),
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          "Rp. ${product.harga != null ? widget.formatAngka(product.harga!.toDouble()) : 'Tidak ada harga'}",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isOutOfStock
                                                ? Colors.grey
                                                : Colors.grey.shade600,
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Text(
                                              "Stok: ${product.stok != null ? product.stok!.toString() : 'Kosong'}",
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: isOutOfStock
                                                    ? Colors.grey
                                                    : Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
