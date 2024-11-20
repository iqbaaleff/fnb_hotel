import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PemasukanPage extends StatefulWidget {
  @override
  _PemasukanPageState createState() => _PemasukanPageState();
}

class _PemasukanPageState extends State<PemasukanPage> {
  List<dynamic> pemasukanList = [];
  String? savedToken;

  // Fungsi untuk menyimpan token
  Future<void> saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    setState(() {
      savedToken = token;
    });
  }

  // Fungsi untuk mengambil token
  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Fungsi untuk menghapus token
  Future<void> removeToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    setState(() {
      savedToken = null;
    });
  }

  // Fungsi untuk mengambil data pemasukan dari backend
  Future<void> getPemasukan() async {
    try {
      var dio = Dio();
      String? token = await getToken();

      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      var response = await dio.get(
        'https://74gslzvj-3000.asse.devtunnels.ms/api/pemasukan',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        if (response.data is Map) {
          setState(() {
            pemasukanList = response.data['data'] ?? [];
          });
        } else {
          setState(() {
            pemasukanList = response.data ?? [];
          });
        }
      } else {
        throw Exception('Failed to load pemasukan');
      }
    } catch (e) {
      print('Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat pemasukan')),
        );
      }
    }
  }

  // Fungsi untuk mengecek token
  Future<void> checkToken() async {
    String? token = await getToken();
    setState(() {
      savedToken = token;
    });
    if (token != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Token: $token')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Token tidak ditemukan')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    getToken().then((token) {
      setState(() {
        savedToken = token;
      });
      if (token != null) {
        getPemasukan();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pemasukan'),
        actions: [
          IconButton(
            icon: Icon(Icons.token),
            onPressed: checkToken, // Tombol untuk mengecek token
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: removeToken, // Tombol untuk logout (hapus token)
          ),
        ],
      ),
      body: pemasukanList.isEmpty
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: DataTable(
                dataRowColor: MaterialStateColor.resolveWith(
                    (states) => Colors.grey[200]!),
                headingRowColor: MaterialStateColor.resolveWith(
                    (states) => const Color(0xffE22323)),
                columns: [
                  DataColumn(label: Text('Pemasukan')),
                  DataColumn(label: Text('Biaya Layanan')),
                  DataColumn(label: Text('Biaya Sebelum')),
                ],
                rows: pemasukanList.map((pemasukan) {
                  return DataRow(cells: [
                    DataCell(Text('Rp ${pemasukan['pemasukkan']}')),
                    DataCell(Text('Rp ${pemasukan['biayaLayanan']}')),
                    DataCell(Text('Rp ${pemasukan['totalSebelum']}')),
                  ]);
                }).toList(),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: getPemasukan,
        child: Icon(Icons.refresh),
        tooltip: 'Refresh Data',
      ),
    );
  }
}
