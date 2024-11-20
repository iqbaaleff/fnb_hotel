import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class Riwayat extends StatefulWidget {
  @override
  _RiwayatState createState() => _RiwayatState();
}

class _RiwayatState extends State<Riwayat> {
  List<dynamic> transaksiList = [];

  // Fungsi untuk mengambil data transaksi dari backend
  Future<void> getTransaksi() async {
    try {
      var dio = Dio();
      var response = await dio.get(
          'https://74gslzvj-3000.asse.devtunnels.ms/api/transaksiOrder'); // URL backend Anda

      if (response.statusCode == 200) {
        setState(() {
          transaksiList = response.data;
        });
      } else {
        throw Exception('Failed to load transaksi');
      }
    } catch (e) {
      print('Error: $e');
      // Menangani error, bisa ditampilkan dalam dialog atau snackbar
    }
  }

  @override
  void initState() {
    super.initState();
    getTransaksi(); // Memanggil fungsi untuk mengambil transaksi saat halaman pertama kali dibuka
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Daftar Transaksi')),
      body: transaksiList.isEmpty
          ? Center(
              child:
                  CircularProgressIndicator()) // Tampilkan loader saat data masih kosong
          : Center(
              child: SingleChildScrollView(
                scrollDirection:
                    Axis.vertical, // Agar tabel bisa digulir secara horizontal
                child: DataTable(
                  dataRowColor: MaterialStateColor.resolveWith(
                      (states) => Colors.grey[200]!),
                  headingRowColor: MaterialStateColor.resolveWith(
                      (states) => const Color(0xffE22323)),
                  columns: [
                    DataColumn(label: Text('Nama Pemesan')),
                    DataColumn(label: Text('Kasir')),
                    DataColumn(label: Text('Total Harga')),
                    DataColumn(label: Text('Biaya Layanan')),
                    DataColumn(label: Text('Subtotal')),
                  ],
                  rows: transaksiList.map((transaksi) {
                    return DataRow(cells: [
                      DataCell(Text(transaksi['atasNama'] ?? '-')),
                      DataCell(Text(transaksi['kasirName'] ?? '-')),
                      DataCell(Text('Rp ${transaksi['total']}')),
                      DataCell(Text('Rp ${transaksi['biayaLayanan']}')),
                      DataCell(Text('Rp ${transaksi['subTotal']}')),
                    ]);
                  }).toList(),
                ),
              ),
            ),
    );
  }
}
