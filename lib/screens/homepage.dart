import 'package:flutter/material.dart';
import 'package:fnb_hotel/api_services.dart';
import 'package:fnb_hotel/models/produk.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  late Future<List<Product>> _product;
  List<Product> selectedProducts = [];
  final TextEditingController nominalController = TextEditingController();

  double totalHarga() {
    return selectedProducts.fold(0, (sum, product) {
      return sum + (product.harga! * product.quantity);
    });
  }

  double subTotalHarga() {
    double totalHarga = selectedProducts.fold(0, (sum, product) {
      return sum + (product.harga! * product.quantity);
    });
    return totalHarga + 3000;
  }

  void tambah(Product product) {
    setState(() {
      product.quantity++;
    });
  }

  void kurang(Product product) {
    if (product.quantity > 1) {
      setState(() {
        product.quantity--;
      });
    }
  }

  // pop up
  void _popupKonfirBayar(BuildContext context) {
    final size = MediaQuery.of(context).size;
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: Color(0xffE22323),
                width: 2,
              ),
            ),
            content: Stack(
              children: [
                Container(
                  width: size.width * 0.3,
                  height: size.height * 0.4,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.05,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Total Pesanan',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 30,
                            color: Color(0xff0C085C),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(
                          height: size.height * 0.05,
                        ),
                        Expanded(
                          child: Container(
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Total Harga:'),
                                    Text('Rp. ${totalHarga()}'),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Biaya Layanan:'),
                                    Text('Rp. 3000'),
                                  ],
                                ),
                                Divider(thickness: 1, color: Colors.grey),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Subtotal:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'Rp ${subTotalHarga()}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.03),
                          child: Container(
                            width: size.width * 0.2,
                            child: ElevatedButton(
                              onPressed: () {
                                _popupNominalBayar(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xffE22323),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: Text(
                                "Bayar",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Color(0xffE22323),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(); // Tutup popup
                    },
                  ),
                ),
              ],
            ),
          );
        });
  }

  void _popupNominalBayar(BuildContext context) {
    final size = MediaQuery.of(context).size;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: Color(0xffE22323),
              width: 2,
            ),
          ),
          content: Stack(
            children: [
              Container(
                width: size.width * 0.4,
                height: size.height * 0.5,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.05,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calculate_outlined,
                            color: Color(0xffE22323),
                            size: 40,
                          ),
                          SizedBox(width: 10),
                          Text(
                            "Masukan Nominal",
                            style: TextStyle(
                              color: Color(0xff0C085C),
                              fontSize: 25,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      // TextField untuk input nominal
                      TextField(
                        controller: nominalController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          hintText: "Rp. ",
                          prefixText: "Rp. ",
                        ),
                      ),
                      SizedBox(height: 20),
                      // Tombol Bayar
                      Container(
                        width: size.width * 0.2,
                        child: ElevatedButton(
                          onPressed: () {
                            String inputNominal = nominalController.text.trim();
                            if (inputNominal.isNotEmpty) {
                              double? nominal = double.tryParse(inputNominal);
                              if (nominal != null && nominal > 0) {
                                // Lakukan sesuatu dengan nominal yang dimasukkan
                                print("Nominal: Rp. $nominal");
                                _popupBayarBerhasil(context);
                              } else {
                                // Tampilkan pesan error jika input tidak valid
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text("Masukkan nominal yang valid!"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xffE22323),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Text(
                            "Bayar",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Color(0xffE22323),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); // Tutup popup
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _popupBayarBerhasil(BuildContext context) {
    final size = MediaQuery.of(context).size;
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: Color(0xffE22323),
                width: 2,
              ),
            ),
            content: Stack(
              children: [
                Container(
                  width: size.width * 0.4,
                  height: size.height * 0.6,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.06,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset("assets/images/Subtract.png"),
                        Text(
                          'Pembayaran Berhasil !',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 30,
                            color: Color(0xff0C085C),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(
                          height: size.height * 0.1,
                        ),
                        Expanded(
                          child: Container(
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Total Harga:'),
                                    Text('Rp. ${totalHarga()}'),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Biaya Layanan:'),
                                    Text('Rp. 3000'),
                                  ],
                                ),
                                Divider(thickness: 1, color: Colors.grey),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Subtotal:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'Rp ${subTotalHarga()}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Jumlah Uang:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'Rp isi pan',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Kembalian:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'Rp isi pan',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.03),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: size.width * 0.1,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Homepage()),
                                      (Route<dynamic> route) =>
                                          false, // Kondisi untuk menghapus semua rute sebelumnya
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xffE22323),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.storefront_outlined,
                                        color: Colors.white,
                                      ),
                                      Text(
                                        "Home",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xffE22323),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                child: Icon(
                                  Icons.print,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Color(0xffE22323),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(); // Tutup popup
                    },
                  ),
                ),
              ],
            ),
          );
        });
  }

  @override
  void initState() {
    super.initState();
    _product = ApiService().getProductsTanaman();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.005,
        ),
        child: Row(
          children: [
            // Bagian Kiri
            Container(
              width: size.width * 0.72,
              height: size.height,
              child: Column(
                children: [
                  // Bar
                  Expanded(
                    flex: 1,
                    child: Row(
                      children: [
                        // Logo
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: size.height * 0.005,
                              horizontal: size.width * 0.01),
                          child: Image.asset("assets/images/logo.png"),
                        ),

                        // Fnb text
                        Text(
                          "Food & Beverage",
                          style: TextStyle(
                            color: Color(0xff0C085C),
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        // Search bar
                      ],
                    ),
                  ),
                  Divider(
                    color: Color(0xff8B8B8B),
                    height: 10,
                  ),
                  // List Menu
                  Expanded(
                    flex: 9,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                            width: size.width,
                            height: size.height,
                          ),
                        ),
                        Expanded(
                          flex: 8,
                          child: Container(
                            width: size.width,
                            height: size.height,
                            decoration: BoxDecoration(
                              color: Color(0xffF4F4F4),
                              border: Border(
                                left: BorderSide(
                                  color: Color(0xff8B8B8B),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: size.width * 0.005),
                              child: FutureBuilder<List<Product>>(
                                  future: _product,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Center(
                                          child: CircularProgressIndicator());
                                    } else if (snapshot.hasError) {
                                      return Center(
                                          child:
                                              Text('Error: ${snapshot.error}'));
                                    } else if (!snapshot.hasData ||
                                        snapshot.data!.isEmpty) {
                                      return Center(
                                          child: Text('No products available'));
                                    }

                                    final produk = snapshot.data;

                                    return GridView.builder(
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisSpacing: 10,
                                        mainAxisSpacing: 5,
                                        crossAxisCount: 4,
                                        childAspectRatio: 0.95,
                                      ),
                                      itemCount: 10,
                                      itemBuilder: (context, index) {
                                        final products = produk![index];
                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              selectedProducts.add(
                                                  products); // Tambahkan produk yang dipilih ke daftar
                                            });
                                          },
                                          child: Card(
                                            color: Colors.white,
                                            elevation: 2,
                                            child: Column(
                                              children: [
                                                Expanded(
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    child:
                                                        products.fotoProduk !=
                                                                    null &&
                                                                products
                                                                    .fotoProduk!
                                                                    .isNotEmpty
                                                            ? Image.network(
                                                                'https://74gslzvj-8000.asse.devtunnels.ms${products.fotoProduk}',
                                                                fit:
                                                                    BoxFit.fill,
                                                                width: double
                                                                    .infinity,
                                                              )
                                                            : Container(
                                                                color: Colors
                                                                    .grey[200],
                                                                child: Icon(Icons
                                                                    .image_not_supported),
                                                              ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      left: size.width * 0.007,
                                                      right: size.width * 0.007,
                                                      bottom:
                                                          size.height * 0.02),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Padding(
                                                        padding: EdgeInsets.only(
                                                            top: size.height *
                                                                0.005),
                                                        child: Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  vertical: size
                                                                          .height *
                                                                      0.005),
                                                          child: Text(
                                                            products
                                                                .judulProduk,
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              color: Color(
                                                                  0xff0C085C),
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Text(
                                                        "Rp. ${products.harga.toString()}",
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors
                                                              .grey.shade600,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  }),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            // Order Menu
            Container(
              width: size.width * 0.26,
              height: size.height,
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: Color(0xff8B8B8B),
                    width: 1,
                  ),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.only(left: size.width * 0.01),
                child: Column(
                  children: [
                    // Bar Atas
                    Expanded(
                      flex: 1,
                      child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: size.width * 0.01),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Color(0xffE22323),
                              ),
                              child: Image.asset(
                                "assets/images/clipboard.png",
                                height: size.height * 0.047,
                                width: size.width * 0.027,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              "Order Menu",
                              style: TextStyle(
                                color: Color(0xff0C085C),
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.more_vert),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      color: Color(0xff8B8B8B),
                      height: 10,
                    ),
                    // Cart
                    Expanded(
                      flex: 7,
                      child: selectedProducts.isNotEmpty
                          ? ListView.builder(
                              padding: EdgeInsets.all(10),
                              itemCount: selectedProducts.length,
                              itemBuilder: (context, index) {
                                final products = selectedProducts[index];

                                return Padding(
                                  padding: EdgeInsets.only(
                                      bottom: size.height * 0.015),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Color(0xffE22323),
                                          width: 2,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 0,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(15),
                                              bottomLeft: Radius.circular(15),
                                            ),
                                            child: Container(
                                              height: size.height * 0.11,
                                              width: size.width * 0.01,
                                              color: Color(0xffE22323),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            child: Row(
                                              children: [
                                                products.fotoProduk != null &&
                                                        products.fotoProduk!
                                                            .isNotEmpty
                                                    ? Image.network(
                                                        'https://74gslzvj-8000.asse.devtunnels.ms${products.fotoProduk}',
                                                        fit: BoxFit.contain,
                                                        width:
                                                            size.width * 0.05,
                                                        height:
                                                            size.height * 0.11,
                                                      )
                                                    : Icon(
                                                        Icons
                                                            .image_not_supported,
                                                        size: 100,
                                                        color: Colors.grey[400],
                                                      ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Container(
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      products.judulProduk,
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xff0C085C),
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      "Rp. ${products.harga.toString()}",
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors
                                                            .grey.shade600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Container(
                                            child: Row(
                                              children: [
                                                // -
                                                IconButton(
                                                  onPressed: () {
                                                    kurang(products);
                                                  },
                                                  icon: Icon(
                                                    Icons.remove_circle,
                                                    color: Color(0xffE22323),
                                                  ),
                                                ),
                                                // angka
                                                Text(products.quantity
                                                    .toString()),
                                                // +
                                                IconButton(
                                                  onPressed: () {
                                                    tambah(products);
                                                  },
                                                  icon: Icon(
                                                    Icons.add_circle,
                                                    color: Color(0xffE22323),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            )
                          : Center(
                              child: Text("Pilih sebuah produk"),
                            ),
                    ),
                    Divider(
                      color: Color(0xff8B8B8B),
                      height: 10,
                    ),
                    // Button Order
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: size.height * 0.04,
                          horizontal: size.width * 0.01,
                        ),
                        child: Container(
                          width: size.width,
                          height: size.height,
                          decoration: BoxDecoration(
                            color: Color(0xffE22323),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: size.width * 0.01),
                            child: Row(
                              children: [
                                // pcs + total harga
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${selectedProducts.length} Items",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white.withOpacity(0.3),
                                        ),
                                      ),
                                      Text(
                                        "${totalHarga().toString()}",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                //button
                                ElevatedButton(
                                  onPressed: () {
                                    _popupKonfirBayar(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  child: Text(
                                    "Order",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
