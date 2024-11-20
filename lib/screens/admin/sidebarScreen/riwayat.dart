import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:fnb_hotel/services/logoutFunction.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        'https://74gslzvj-3000.asse.devtunnels.ms/api/transaksiOrder',
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
            color: Color(0xFF22E284),
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
              backgroundColor: Color(0xFF22E284),
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
            color: Color(0xFF22E284), // Warna garis
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
                  scrollDirection: Axis
                      .vertical, // Agar tabel bisa digulir secara horizontal
                  child: transaksiList.isNotEmpty
                      ? DataTable(
                          dataRowColor: MaterialStateColor.resolveWith(
                              (states) => Colors.grey[200]!),
                          headingRowColor: MaterialStateColor.resolveWith(
                              (states) => const Color(0xFF22E284)),
                          columns: [
                            DataColumn(label: Text('Nama Pemesan')),
                            DataColumn(label: Text('Kasir')),
                            DataColumn(label: Text('Total Harga')),
                            DataColumn(label: Text('Biaya Layanan')),
                            DataColumn(label: Text('Subtotal')),
                            DataColumn(label: Text('Aksi')), // Kolom aksi
                          ],
                          rows: transaksiList.map((transaksi) {
                            return DataRow(cells: [
                              DataCell(Text(transaksi['atasNama'] ?? '-')),
                              DataCell(Text(transaksi['kasirName'] ?? '-')),
                              DataCell(Text('Rp ${transaksi['total']}')),
                              DataCell(Text('Rp ${transaksi['biayaLayanan']}')),
                              DataCell(Text('Rp ${transaksi['subTotal']}')),
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
                        )
                      : Center(child: Text('Tidak ada transaksi tersedia')),
                ),
              ),
      ),
    );
  }
}
