import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fnb_hotel/models/produk.dart';
import 'package:fnb_hotel/screens/kasir/cemilan.dart';
import 'package:fnb_hotel/screens/kasir/coffe.dart';
import 'package:fnb_hotel/screens/kasir/order_menu.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

Dio _dio = Dio();

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  String _selectedCategory = "Cemilan";
  String _selectedCategoryIndex = "Makanan";
  int _currentIndex = 0;
  List<Product> selectedProducts = [];
  String kasirName = '';
  double biayaLayanan = 3000;
  double subtotal = 0;

  final TextEditingController aNamaController = TextEditingController();
  final TextEditingController totalHargaController = TextEditingController();
  final TextEditingController nominalController = TextEditingController();

  Map<String, List<String>> kategori = {
    "makanan": ["Cemilan", "Coming Soon"],
    "minuman": ["Coffe", "Soon"]
  };

// Rupiah
  String formatAngka(double angka) {
    final formatter = NumberFormat(
        '#,##0', 'id_ID'); // Menggunakan locale Indonesia dengan format titik
    return formatter.format(angka); // Hasilnya akan seperti 1.000.000
  }

// Fungsi untuk menghitung total harga
  double totalHarga() {
    return selectedProducts.fold(0, (sum, product) {
      return sum + (product.harga! * product.quantity);
    });
  }

// Fungsi untuk menghitung subtotal harga dengan biaya layanan
  double subTotalHarga() {
    double totalHarga = selectedProducts.fold(0, (sum, product) {
      return sum + (product.harga! * product.quantity);
    });
    return totalHarga + biayaLayanan;
  }

  @override
  void initState() {
    super.initState();
    getUserData(); // Ambil data username saat halaman dimuat
  }

// Fungsi untuk mengambil token dan username dari SharedPreferences
  Future<void> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    kasirName = prefs.getString('username') ?? '';
    print(
        "KasirName from SharedPreferences: $kasirName"); // Tambahkan print debug
    setState(() {}); // Perbarui UI setelah mendapatkan kasirName
  }

// Fungsi untuk mendapatkan token dari SharedPreferences
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

// Fungsi untuk mengirim transaksi ke backend
  Future<void> kirimTransaksi() async {
    try {
      // Pastikan getUserData() dipanggil sebelum kirimTransaksi
      await getUserData();
      print(
          "Kasir Name after getUserData: $kasirName"); // Log untuk melihat nilai kasirName

      // Cek apakah data kasir atau atas nama sudah diisi
      if (kasirName.isEmpty || aNamaController.text.isEmpty) {
        print("KasirName: $kasirName, AtasNama: ${aNamaController.text}");
        throw Exception("Data kasir atau atas nama tidak lengkap!");
      }

      // Pastikan ada produk yang dipilih
      if (selectedProducts.isEmpty) {
        throw Exception("Tidak ada produk yang dipilih!");
      }

      // Konversi data produk yang dipilih menjadi format yang dibutuhkan
      List<Map<String, dynamic>> produkData = selectedProducts.map((product) {
        return {
          "id_produk": product.id,
          "jumlah": product.quantity,
          "subTotal": product.harga! * product.quantity,
        };
      }).toList();

      print("Produk yang dikirim ke backend: $produkData"); // Log data produk

      // Ambil token jika diperlukan untuk autentikasi
      String? token = await getToken();

      // Kirim data transaksi ke server
      final response = await _dio.post(
        'https://74gslzvj-3000.asse.devtunnels.ms/api/order',
        data: {
          'atasNama': aNamaController.text,
          'produk': produkData,
        },
        options: Options(
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ),
      );

      print("Transaksi berhasil: ${response.data}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Transaksi berhasil!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print("Gagal mengirim transaksi: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal mengirim transaksi! ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

// Fungsi untuk menambahkan quantity produk
  void tambah(Product product) {
    setState(() {
      product.quantity++;
    });
  }

// Fungsi untuk mengurangi quantity produk
  void kurang(Product product) {
    if (product.quantity > 1) {
      setState(() {
        product.quantity--;
      });
    }
  }

// Fungsi untuk memilih produk dan menambahkannya ke daftar selectedProducts
  void onProductSelected(Product product) {
    setState(() {
      int index = selectedProducts.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        // Jika produk sudah ada, tambah quantity-nya
        selectedProducts[index].quantity++;
      } else {
        // Jika produk belum ada, tambahkan produk dengan quantity 1
        selectedProducts.add(Product(
          id: product.id,
          judulProduk: product.judulProduk,
          fotoProduk: product.fotoProduk,
          harga: product.harga,
          kategoriProduk: product.kategoriProduk,
          subKategoriProduk: product.subKategoriProduk,
          quantity: 1, // Memastikan quantity dimulai dari 1
        ));
      }
    });
    print("Selected Products: ${selectedProducts}"); // Log produk yang dipilih
  }

  // pop-up konfirmasi pembayaran
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
                        padding:
                            EdgeInsets.symmetric(vertical: size.height * 0.03),
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
                                  color: Color(0xffE22323)), // Border merah
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                  color: Color(0xffE22323),
                                  width: 2), // Border merah saat fokus
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
                                  Text(
                                    "Rp. ${totalHarga() != null ? formatAngka(totalHarga().toDouble()) : 'Tidak ada harga'}",
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Biaya Layanan:'),
                                  Text(
                                      "Rp. ${biayaLayanan != null ? formatAngka(biayaLayanan.toDouble()) : 'Tidak ada harga'}"),
                                ],
                              ),
                              Divider(thickness: 1, color: Colors.grey),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Subtotal:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "Rp. ${subTotalHarga() != null ? formatAngka(subTotalHarga().toDouble()) : 'Tidak ada harga'}",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: size.width * 0.03),
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
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
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
        );
      },
    );
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
                                // Debug log untuk memeriksa nominal dan produk yang dipilih
                                print("Nominal: Rp. $nominal");
                                print("Selected Products: $selectedProducts");

                                if (nominal >= subTotalHarga()) {
                                  // Mengirim transaksi
                                  kirimTransaksi(); // Kirim transaksi ke server
                                  _popupBayarBerhasil(context,
                                      nominal - subTotalHarga(), nominal);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text("Nominal bayar tidak cukup!"),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              } else {
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

  void _popupBayarBerhasil(
      BuildContext context, double kembalian, double nominalBayar) {
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
                                    Text(
                                        "Rp. ${totalHarga() != null ? formatAngka(totalHarga().toDouble()) : 'Tidak ada harga'}"),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Biaya Layanan:'),
                                    Text(
                                        "Rp. ${biayaLayanan != null ? formatAngka(biayaLayanan.toDouble()) : 'Tidak ada harga'}"),
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
                                      "Rp. ${subTotalHarga() != null ? formatAngka(subTotalHarga().toDouble()) : 'Tidak ada harga'}",
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
                                      "Rp. ${nominalBayar != null ? formatAngka(nominalBayar.toDouble()) : 'Tidak ada harga'}",
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
                                      "Rp. ${kembalian != null ? formatAngka(kembalian.toDouble()) : 'Tidak ada harga'}",
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
                        // Search Bar
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
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                right: BorderSide(
                                  color: Color(0xff8B8B8B),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Column(
                              children: [
                                // Kategori Makanan
                                Row(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: size.width * 0.01),
                                      child: Image.asset(
                                          "assets/images/rice 1.png"),
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

                                      return ListTile(
                                        title: Text(
                                          item,
                                          style: TextStyle(
                                            color: _selectedCategory ==
                                                    makanan[index]
                                                ? Colors.white
                                                : null,
                                          ),
                                        ),
                                        onTap: () {
                                          setState(() {
                                            _selectedCategory = makanan[index];
                                            _selectedCategoryIndex = "Makanan";

                                            _currentIndex = index;
                                          });
                                        },
                                        tileColor: _selectedCategory ==
                                                makanan[index]
                                            ? Color(0xffE22323)
                                            : null, // Ganti warna jika kategori dipilih
                                        selectedTileColor: Color(
                                            0xffE22323), // Warna saat item aktif
                                        selected: _selectedCategory ==
                                            makanan[
                                                index], // Menandai jika kategori ini dipilih
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

                                      return ListTile(
                                        title: Text(
                                          item,
                                          style: TextStyle(
                                            color: _selectedCategory ==
                                                    minuman[index]
                                                ? Colors.white
                                                : null,
                                          ),
                                        ),
                                        onTap: () {
                                          setState(() {
                                            _selectedCategory = minuman[index];
                                            _selectedCategoryIndex = "Minuman";

                                            _currentIndex = index;
                                          });
                                        },
                                        tileColor: _selectedCategory ==
                                                minuman[index]
                                            ? Color(0xffE22323)
                                            : null, // Ganti warna jika kategori dipilih
                                        selectedTileColor: Color(
                                            0xffE22323), // Warna saat item aktif
                                        selected: _selectedCategory ==
                                            minuman[
                                                index], // Menandai jika kategori ini dipilih
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Tampilan Konten Berdasarkan Kategori
                        Expanded(
                          flex: 6,
                          child: IndexedStack(
                            index:
                                _currentIndex, // Index berubah sesuai dengan halaman yang dipilih
                            children: [
                              
                              if (_selectedCategoryIndex == "Makanan") ...[
                                Cemilan(
                                  formatAngka: formatAngka,
                                  size: size,
                                  onProductSelected: onProductSelected,
                                ),
                              ],
                              if (_selectedCategoryIndex == "Minuman") ...[
                                Coffe(
                                  formatAngka: formatAngka,
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
              formatAngka: formatAngka,
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
