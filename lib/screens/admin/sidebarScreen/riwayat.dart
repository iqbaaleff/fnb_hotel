import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:fnb_hotel/services/logoutFunction.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // Import intl untuk format tanggal

class Riwayat extends StatefulWidget {
  @override
  _RiwayatState createState() => _RiwayatState();
}

class _RiwayatState extends State<Riwayat> {
  List<dynamic> transaksiList = [];
  String? token;

  // Fungsi untuk mengambil token dari shared_preferences
  Future<void> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token');
    });
  }

  // Fungsi untuk format tanggal
  String formatDate(String? date) {
    if (date == null || date.isEmpty) return '-';
    try {
      DateTime parsedDate = DateTime.parse(date);
      return DateFormat('yyyy-MM-dd')
          .format(parsedDate); // Format hanya tanggal
    } catch (e) {
      print('Error parsing date: $e');
      return '-';
    }
  }

  // Fungsi untuk mengambil data transaksi dari backend
  Future<void> getTransaksi() async {
    try {
      var dio = Dio();

      // Menambahkan token ke header jika token tersedia
      dio.options.headers['Authorization'] = 'Bearer $token';

      var response = await dio.get(
        'https://74gslzvj-3000.asse.devtunnels.ms/api/transaksiOrder',
      );

      if (response.statusCode == 200) {
        setState(() {
          transaksiList = response.data;
        });
      } else {
        throw Exception('Failed to load transaksi');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    getToken().then((_) {
      if (token != null && token!.isNotEmpty) {
        getTransaksi(); // Mengambil data transaksi setelah token tersedia
      } else {
        // Tampilkan error jika token tidak tersedia
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Token tidak tersedia!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Riwayat Transaksi',
          style: TextStyle(
            color: Color(0xff0C085C),
            fontWeight: FontWeight.bold,
          ),
        ),
        
        backgroundColor: Colors.white,
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0), // Ketebalan garis
          child: Container(
            color: Color(0xffE22323), // Warna garis
            height: 2.0, // Tinggi garis (ketebalan)
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
        child: transaksiList.isEmpty
            ? Center(
                child:
                    CircularProgressIndicator(), // Tampilkan loader saat data masih kosong
              )
            : SingleChildScrollView(
                scrollDirection:
                    Axis.vertical, // Agar tabel bisa digulir vertikal
                child: SingleChildScrollView(
                  scrollDirection:
                      Axis.horizontal, // Agar tabel bisa digulir horizontal
                  child: DataTable(
                    dataRowColor: MaterialStateColor.resolveWith(
                        (states) => Colors.grey[200]!),
                    headingRowColor: MaterialStateColor.resolveWith(
                        (states) => const Color(0xffE22323)),
                    columns: [
                      DataColumn(label: Text('Order No')),
                      DataColumn(label: Text('Tanggal')),
                      DataColumn(label: Text('Atas Nama')),
                      DataColumn(label: Text('Kasir')),
                      DataColumn(label: Text('Catatan')),
                      DataColumn(label: Text('Layanan 10%')),
                      DataColumn(label: Text('PPN 5%')),
                      DataColumn(label: Text('Total')),
                      DataColumn(label: Text('Subtotal')),
                      DataColumn(label: Text('Aksi')), // Kolom aksi
                    ],
                    rows: transaksiList.map((transaksi) {
                      return DataRow(cells: [
                        DataCell(Text((transaksiList.indexOf(transaksi) + 1)
                            .toString())), // Mulai dari 1
                        DataCell(Text(formatDate(
                            transaksi['createdAt']))), // Format tanggal
                        DataCell(Text(transaksi['nama'] ?? '-')),
                        DataCell(Text(transaksi['namaKasir'] ?? '-')),
                        DataCell(Text(transaksi['tambahan'] ?? '-')),
                        DataCell(Text('Rp ${transaksi['ppn'] ?? '0'}')),
                        DataCell(Text('Rp ${transaksi['layanan'] ?? '0'}')),
                        DataCell(Text('Rp ${transaksi['total'] ?? '0'}')),
                        DataCell(Text('Rp ${transaksi['subTotal'] ?? '0'}')),
                        DataCell(
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              // Menanyakan konfirmasi sebelum menghapus
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Konfirmasi Hapus'),
                                  content: Text(
                                      'Apakah Anda yakin ingin menghapus transaksi ini?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text('Batal'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        // Panggil hapus transaksi
                                      },
                                      child: Text('Hapus'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
      ),
    );
  }
}
