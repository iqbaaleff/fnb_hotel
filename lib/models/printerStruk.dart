import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class PdfGenerator {
  static Future<void> printInvoice({
    required String logoPath,
    required String namaHotel,
    required String alamat,
    required String tanggalTransaksi,
    required String atasNama,
    required List<Map<String, dynamic>> detailPesanan,
    required double Function(double) getBiayaLayanan,
    required double Function(double) getPpn,
    String? catatan,
  }) async {
    final pdf = pw.Document();
    final formatCurrency =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    Uint8List logoBytes =
        (await rootBundle.load(logoPath)).buffer.asUint8List();

    double subtotal = detailPesanan.fold(
        0, (sum, item) => sum + (item['harga'] * item['jumlah']));
    double layanan = getBiayaLayanan(subtotal);
    double ppn = getPpn(subtotal);
    double amountDue = subtotal + ppn + layanan;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            padding: pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.red, width: 2),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header Hotel
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Image(pw.MemoryImage(logoBytes), height: 100, width: 100),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(namaHotel,
                            style: pw.TextStyle(
                                fontSize: 24,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.red)),
                        pw.Text(alamat,
                            style: pw.TextStyle(fontSize: 14, color: PdfColors.black)),
                      ],
                    ),
                  ],
                ),
                pw.Divider(color: PdfColors.red, thickness: 2),
                pw.SizedBox(height: 10),

                // Info Transaksi
                pw.Text("Transaction Date: $tanggalTransaksi",
                    style: pw.TextStyle(fontSize: 16)),
                pw.Text("$atasNama",
                    style: pw.TextStyle(fontSize: 25, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),

                // Tabel Pesanan
                pw.Text("Order Details:",
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.red)),
                pw.SizedBox(height: 5),
                pw.Table.fromTextArray(
                  headers: ['Item', 'Price', 'Qty', 'Total'],
                  data: detailPesanan.map((item) {
                    return [
                      item['item'],
                      formatCurrency.format(item['harga']),
                      item['jumlah'].toString(),
                      formatCurrency.format(item['harga'] * item['jumlah'])
                    ];
                  }).toList(),
                  cellStyle: pw.TextStyle(fontSize: 14),
                  headerStyle: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white),
                  headerDecoration: pw.BoxDecoration(
                      color: PdfColors.red,
                      borderRadius: pw.BorderRadius.circular(5)),
                  border: pw.TableBorder.all(color: PdfColors.red),
                ),
                pw.SizedBox(height: 15),
                
                // Total Harga
                pw.Container(
                  padding: pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.red),
                    borderRadius: pw.BorderRadius.circular(5),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                            pw.Text("Subtotal:",
                          style: pw.TextStyle(fontSize: 16)),
                           pw.Text("${formatCurrency.format(subtotal)}",
                          style: pw.TextStyle(fontSize: 16)),
                        ]),
                    
                      pw.Text("Tax (10%): ${formatCurrency.format(ppn)}",
                          style: pw.TextStyle(fontSize: 16)),
                      pw.Text("Service (11%): ${formatCurrency.format(layanan)}",
                          style: pw.TextStyle(fontSize: 16)),
                      pw.Divider(color: PdfColors.red, thickness: 1),
                      pw.Text("Amount Due: ${formatCurrency.format(amountDue)}",
                          style: pw.TextStyle(
                              fontSize: 18,
                              fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // Ucapan Terima Kasih
                pw.Center(
                  child: pw.Text("Terima Kasih",
                      style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.red)),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save());
  }
}