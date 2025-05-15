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

  // Fungsi untuk mengecek token
  void cekToken() {
    if (token != null && token!.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Token ditemukan: $token'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Token tidak ditemukan!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Fungsi untuk mengambil data transaksi dari backend
  Future<void> getTransaksi() async {
    try {
      var dio = Dio();

      // Menambahkan token ke header jika token tersedia
      dio.options.headers['Authorization'] = 'Bearer $token';

      var response = await dio.get(
        'https://zshnvs5v-3000.asse.devtunnels.ms/api/transaksiOrder',
      );

      // Debugging untuk melihat status code dan data respons
      print("Response Status Code: ${response.statusCode}");
      print("Response Data: ${response.data}");

      if (response.statusCode == 200) {
        setState(() {
          transaksiList = response.data;
        });
      } else {
        throw Exception('Failed to load transaksi');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Fungsi untuk menghapus transaksi berdasarkan id
  Future<void> hapusTransaksi(int id) async {
    try {
      var dio = Dio();

      // Menambahkan token ke header jika token tersedia
      dio.options.headers['Authorization'] = 'Bearer $token';

      var response = await dio.delete(
        'https://74gslzvj-3000.asse.devtunnels.ms/api/deleteHistory/$id',
      );

      if (response.statusCode == 200) {
        setState(() {
          transaksiList.removeWhere((transaksi) => transaksi['id'] == id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transaksi berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Gagal menghapus transaksi');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus transaksi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
            color: Color(0xffE22323),
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
        padding: EdgeInsets.symmetric(vertical: 10),
        child: transaksiList.isEmpty
            ? Center(
                child:
                    CircularProgressIndicator(), // Tampilkan loader saat data masih kosong
              )
            : Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical, // Agar tabel bisa digulir
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      dataRowColor: MaterialStateColor.resolveWith(
                          (states) => Colors.grey[200]!),
                      headingRowColor: MaterialStateColor.resolveWith(
                          (states) => const Color(0xffE22323)),
                      columns: [
                        DataColumn(
                            label: Text(
                          'Order No',
                          style: TextStyle(color: Colors.white),
                        )),
                        DataColumn(
                            label: Text(
                          'Tanggal',
                          style: TextStyle(color: Colors.white),
                        )),
                        DataColumn(
                            label: Text(
                          'Atas Nama',
                          style: TextStyle(color: Colors.white),
                        )),
                        DataColumn(
                            label: Text(
                          'Kasir',
                          style: TextStyle(color: Colors.white),
                        )),
                        DataColumn(
                            label: Text(
                          'Catatan',
                          style: TextStyle(color: Colors.white),
                        )),
                        DataColumn(
                            label: Text(
                          'Layanan 10%',
                          style: TextStyle(color: Colors.white),
                        )),
                        DataColumn(
                            label: Text(
                          'PPN 5%',
                          style: TextStyle(color: Colors.white),
                        )),
                        DataColumn(
                            label: Text(
                          'Total',
                          style: TextStyle(color: Colors.white),
                        )),
                        DataColumn(
                            label: Text(
                          'Subtotal',
                          style: TextStyle(color: Colors.white),
                        )),
                        DataColumn(
                            label: Text(
                          'Aksi',
                          style: TextStyle(color: Colors.white),
                        )), // Kolom aksi
                      ],
                      rows: transaksiList.map((transaksi) {
                        return DataRow(cells: [
                          // Menggunakan indeks dari transaksiList untuk membuat auto increment
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
                          // Kolom aksi dengan tombol hapus
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
                                          hapusTransaksi(transaksi['id']);
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
      ),
    );
  }
}
