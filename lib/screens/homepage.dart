import 'package:flutter/material.dart';
import 'package:fnb_hotel/api_services.dart';

import 'package:fnb_hotel/models/produk.dart';
import 'package:fnb_hotel/screens/berat.dart';
import 'package:fnb_hotel/screens/cemilan.dart';
import 'package:fnb_hotel/screens/coffe.dart';
import 'package:fnb_hotel/screens/order_menu.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  String _selectedCategory = "";
  int _currentIndex = 0;
  int? _currentIndexMakanan;
  int? _currentIndexMinuman;
  List<Product> selectedProducts = [];

  Map<String, List<String>> kategori = {
    "makanan": ["Cemilan", "Mie Ayam", "Rendang", "Sate", "Bakso"],
    "minuman": ["Teh Manis", "Kopi", "Jus Jeruk", "Air Mineral", "Es Teh"]
  };

  final ApiService apiService = ApiService();

  final TextEditingController nominalController = TextEditingController();
  final TextEditingController aNamaController = TextEditingController();

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

  void onProductSelected(Product product) {
    setState(() {
      selectedProducts.add(product);
    });
  }

  // pop up
  void popupKonfirBayar(BuildContext context) {
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
                  height: size.height * 0.5,
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
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: size.height * 0.03),
                          child: TextField(
                            controller: aNamaController,
                            decoration: InputDecoration(
                              labelText: 'Nama Pemesan',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    color: Color(
                                        0xffE22323)), // Border warna merah saat tidak fokus
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    color: Color(0xffE22323),
                                    width: 2), // Border warna merah saat fokus
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                            ),
                          ),
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
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    List<String> makanan = kategori["makanan"] ?? [];
    List<String> minuman = kategori["minuman"] ?? [];

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.005,
        ),
        child: Row(
          children: [
            // Bagian Kiri
            Container(
              width: size.width * 0.6,
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
                        // ListView with menu items
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              // Kategori Makanan
                              Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: size.width * 0.01),
                                    child:
                                        Image.asset("assets/images/rice 1.png"),
                                  ),
                                  Text(
                                    "Makanan",
                                    style: TextStyle(
                                      color: Color(0xff0C085C),
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: makanan.length,
                                  itemBuilder: (context, index) {
                                    final item = makanan[index];
                                    final isSelected =
                                        _currentIndexMakanan == index;

                                    return Container(
                                      color: isSelected
                                          ? Color(0xffE22323)
                                          : Colors
                                              .transparent, // Abu-abu jika dipilih
                                      child: ListTile(
                                        title: Text(
                                          item,
                                          style: TextStyle(
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                        onTap: () {
                                          setState(() {
                                            _selectedCategory = "Makanan";
                                            _currentIndexMakanan = index;
                                            _currentIndexMinuman == null;
                                            _currentIndex = index;
                                          });
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                              // Kategori Minuman
                              Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: size.width * 0.01),
                                    child: Image.asset(
                                        "assets/images/coffee-cup 2.png"),
                                  ),
                                  Text(
                                    "Minuman",
                                    style: TextStyle(
                                      color: Color(0xff0C085C),
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: minuman.length,
                                  itemBuilder: (context, index) {
                                    final item = minuman[index];
                                    final isSelected =
                                        _currentIndexMinuman == index;

                                    return Container(
                                      color: isSelected
                                          ? Color(0xffE22323)
                                          : Colors
                                              .transparent, // Abu-abu jika dipilih
                                      child: ListTile(
                                        title: Text(
                                          item,
                                          style: TextStyle(
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                        onTap: () {
                                          setState(() {
                                            _selectedCategory = "Minuman";
                                            _currentIndexMinuman = index;
                                            _currentIndexMakanan == null;
                                            _currentIndex = index;
                                          });
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Tampilan Konten Berdasarkan Kategori
                        Expanded(
                          flex: 6,
                          child: IndexedStack(
                            index:
                                _currentIndex, // Index berubah sesuai dengan halaman yang dipilih
                            children: [
                              if (_selectedCategory == "Makanan") ...[
                                Cemilan(
                                  size: size,
                                  onProductSelected: onProductSelected,
                                ),
                                MakananBerat(
                                  size: size,
                                  onProductSelected: onProductSelected,
                                ),
                              ],
                              if (_selectedCategory == "Minuman") ...[
                                Coffe(
                                  size: size,
                                  onProductSelected: onProductSelected,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Order Menu
            OrderMenu(
              selectedProducts: selectedProducts,
              size: size,
              totalHarga: totalHarga,
              popupKonfirBayar: popupKonfirBayar,
              kurang: kurang,
              tambah: tambah,
            ),
          ],
        ),
      ),
    );
  }
}
