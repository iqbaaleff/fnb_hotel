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
                                        return Card(
                                          color: Colors.white,
                                          elevation: 2,
                                          child: Column(
                                            children: [
                                              Expanded(
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  child: products.fotoProduk !=
                                                              null &&
                                                          products.fotoProduk!
                                                              .isNotEmpty
                                                      ? Image.network(
                                                          'https://74gslzvj-8000.asse.devtunnels.ms${products.fotoProduk}',
                                                          fit: BoxFit.fill,
                                                          width:
                                                              double.infinity,
                                                        )
                                                      : Container(
                                                          color:
                                                              Colors.grey[200],
                                                          child: Icon(Icons
                                                              .image_not_supported),
                                                        ),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    left: size.width * 0.007,
                                                    right: size.width * 0.007,
                                                    bottom: size.height * 0.02),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          top: size.height *
                                                              0.005),
                                                      child: Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical:
                                                                    size.height *
                                                                        0.005),
                                                        child: Text(
                                                          products.judulProduk,
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            color: Color(
                                                                0xff0C085C),
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.w700,
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
                      child: Center(
                        child: Text("Silahkan pilih menu"),
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
                                        "4 Items",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white.withOpacity(0.3),
                                        ),
                                      ),
                                      Text(
                                        "Rp. 24.000",
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
                                  onPressed: () {},
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
