import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfGenerator {
  static Future<void> printInvoice({
    required String namaHotel,
    required String alamat,
    required String tanggalTransaksi,
    required String atasNama,
    required List<Map<String, dynamic>>
        detailPesanan, // Contoh: [{'item': 'Kopi', 'harga': 10000, 'jumlah': 2}]
    required double total,
    required double Function(double) getBiayaLayanan,
    required double Function(double) getPpn,
    required double subtotal,
    String? catatan, // Parameter baru untuk catatan
  }) async {
    final pdf = pw.Document();

    // Hitung biaya layanan dan PPN menggunakan fungsi yang diterima
    double layanan = getBiayaLayanan(total);
    double ppn = getPpn(total);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                namaHotel,
                style: pw.TextStyle(
                  fontSize: 30, // Ukuran font lebih besar
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10), // Jarak antar elemen
              pw.Text(
                alamat,
                style: pw.TextStyle(fontSize: 18), // Ukuran font lebih besar
              ),
              pw.SizedBox(height: 15), // Jarak lebih banyak
              pw.Text(
                "Tanggal Transaksi: $tanggalTransaksi",
                style: pw.TextStyle(fontSize: 18), // Ukuran font lebih besar
              ),
              pw.SizedBox(height: 5), // Jarak tambahan
              pw.Text(
                "Atas Nama: $atasNama",
                style: pw.TextStyle(fontSize: 18), // Ukuran font lebih besar
              ),
              pw.SizedBox(height: 15), // Jarak antar elemen
              pw.Divider(),
              pw.SizedBox(height: 10), // Jarak setelah Divider
              pw.Text(
                "Detail Pesanan:",
                style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold), // Ukuran font lebih besar
              ),
              pw.SizedBox(
                  height: 10), // Jarak antar judul detail pesanan dan tabel
              pw.Table.fromTextArray(
                headers: ['Item', 'Harga', 'Jumlah', 'Catatan'],
                data: detailPesanan.map((item) {
                  return [
                    item['item'],
                    item['harga'].toString(),
                    item['jumlah'].toString(),
                    item['note'],
                  ];
                }).toList(),
                cellStyle:
                    pw.TextStyle(fontSize: 16), // Ukuran font lebih besar
                headerStyle: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ), // Ukuran font header lebih besar
              ),
              pw.SizedBox(height: 15), // Jarak setelah tabel
              pw.Divider(),
              pw.SizedBox(height: 10), // Jarak setelah Divider
              pw.Text(
                "Total: Rp${total.toStringAsFixed(0)}",
                style: pw.TextStyle(fontSize: 18), // Ukuran font lebih besar
              ),
              pw.SizedBox(height: 5), // Jarak antar elemen
              pw.Text(
                "PPN (5%): Rp${ppn.toStringAsFixed(0)}",
                style: pw.TextStyle(fontSize: 18), // Ukuran font lebih besar
              ),
              pw.SizedBox(height: 5), // Jarak antar elemen
              pw.Text(
                "Layanan (10%): Rp${layanan.toStringAsFixed(0)}",
                style: pw.TextStyle(fontSize: 18), // Ukuran font lebih besar
              ),
              pw.SizedBox(height: 5), // Jarak antar elemen
              pw.Text(
                "Subtotal: Rp${subtotal.toStringAsFixed(0)}",
                style: pw.TextStyle(fontSize: 18), // Ukuran font lebih besar
              ),
              pw.SizedBox(
                  height: 20), // Jarak lebih besar sebelum ucapan terima kasih
              pw.Text(
                "Terima Kasih",
                style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold), // Ukuran font lebih besar
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save());
  }
}
