import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class KitchenReceipt {
  static Future<void> printKitchenReceipt({
    required String logoPath,
    required String atasNama,
    required List<Map<String, dynamic>> detailPesanan,
  }) async {
    final pdf = pw.Document();

    // Format angka ke Rupiah
    final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    // Load logo dari assets
    Uint8List logoBytes = (await rootBundle.load(logoPath)).buffer.asUint8List();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Image(pw.MemoryImage(logoBytes), height: 80),
              ),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text("-- KIRIM KE DAPUR --",
                    style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.red)),
              ),
              pw.SizedBox(height: 15),
              pw.Text("Pesanan untuk: $atasNama",
                  style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                headers: ['Item', 'Jumlah', 'Catatan'],
                data: detailPesanan.map((item) {
                  return [
                    item['item'],
                    item['jumlah'].toString(),
                    item['note'] ?? '-',
                  ];
                }).toList(),
                cellStyle: pw.TextStyle(fontSize: 16),
                headerStyle: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 20),
              pw.Center(
                child: pw.Text("--- SELESAIKAN DENGAN CEPAT ---",
                    style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.red)),
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
