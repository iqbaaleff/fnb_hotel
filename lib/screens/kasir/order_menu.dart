import 'package:flutter/material.dart';
import 'package:fnb_hotel/services/logoutFunction.dart';

class OrderMenu extends StatefulWidget {
  final Size size;
  final List<dynamic> selectedProducts;
  final Function kurang;
  final Function tambah;
  final Function totalHarga;
  final Function(BuildContext) popupKonfirBayar;
  final Function(double) formatAngka;

  const OrderMenu({
    Key? key,
    required this.size,
    required this.selectedProducts,
    required this.kurang,
    required this.tambah,
    required this.totalHarga,
    required this.popupKonfirBayar,
    required this.formatAngka,
  }) : super(key: key);

  @override
  State<OrderMenu> createState() => _OrderMenuState();
}

class _OrderMenuState extends State<OrderMenu> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size.width * 0.38,
      height: widget.size.height,
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: Color(0xff8B8B8B),
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(left: widget.size.width * 0.01),
        child: Column(
          children: [
            // Bar Atas
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: widget.size.width * 0.01),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Color(0xffE22323),
                      ),
                      child: Image.asset(
                        "assets/images/clipboard.png",
                        height: widget.size.height * 0.047,
                        width: widget.size.width * 0.027,
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
              child: widget.selectedProducts.isNotEmpty
                  ? ListView.builder(
                      padding: EdgeInsets.all(10),
                      itemCount: widget.selectedProducts.length,
                      itemBuilder: (context, index) {
                        final products = widget.selectedProducts[index];

                        return Padding(
                          padding: EdgeInsets.only(
                              bottom: widget.size.height * 0.015),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Color(0xffE22323),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
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
                                      height: widget.size.height * 0.11,
                                      width: widget.size.width * 0.01,
                                      color: Color(0xffE22323),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                              left: widget.size.width * 0.01),
                                          child: products.fotoProduk != null &&
                                                  products
                                                      .fotoProduk!.isNotEmpty
                                              ? Image.network(
                                                  'https://74gslzvj-3000.asse.devtunnels.ms${products.fotoProduk!}',
                                                  fit: BoxFit.contain,
                                                  width:
                                                      widget.size.width * 0.05,
                                                  height:
                                                      widget.size.height * 0.11,
                                                )
                                              : Icon(
                                                  Icons.image_not_supported,
                                                  size: 100,
                                                  color: Colors.grey[400],
                                                ),
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
                                                color: Color(0xff0C085C),
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "Rp. ${products.harga != null ? widget.formatAngka(products.harga!.toDouble()) : 'Tidak ada harga'}",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade600,
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
                                            widget.kurang(products);
                                          },
                                          icon: Icon(
                                            Icons.remove_circle,
                                            color: Color(0xffE22323),
                                          ),
                                        ),
                                        // angka
                                        Text(products.quantity.toString()),
                                        // +
                                        IconButton(
                                          onPressed: () {
                                            widget.tambah(products);
                                          },
                                          icon: Icon(
                                            Icons.add_circle,
                                            color: Color(0xffE22323),
                                          ),
                                        ),
                                        // Tombol hapus
                                        IconButton(
                                          onPressed: () {
                                            setState(() {
                                              widget.selectedProducts
                                                  .removeAt(index);
                                            });
                                          },
                                          icon: Icon(
                                            Icons.delete,
                                            color: Colors.red,
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
                  vertical: widget.size.height * 0.04,
                  horizontal: widget.size.width * 0.05,
                ),
                child: Container(
                  width: widget.size.width,
                  height: widget.size.height,
                  decoration: BoxDecoration(
                    color: Color(0xffE22323),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: widget.size.width * 0.01),
                    child: Row(
                      children: [
                        // pcs + total harga
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${widget.selectedProducts.length} Items",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white.withOpacity(0.3),
                                ),
                              ),
                              Text(
                                "Rp. ${widget.totalHarga() != null ? widget.formatAngka(widget.totalHarga().toDouble()) : 'Tidak ada harga'}",
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
                            if (widget.selectedProducts.isNotEmpty) {
                              widget.popupKonfirBayar(context);
                            } else {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor: Color(0xffE22323),
                                    title: Text(
                                      "Tidak ada produk yang dipilih.",
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
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
    );
  }
}
