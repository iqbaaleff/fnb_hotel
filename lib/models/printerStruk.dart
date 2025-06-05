import 'package:drago_blue_printer/drago_blue_printer.dart';
import 'package:intl/intl.dart';

class PdfGenerator {
  static final DragoBluePrinter bluetooth = DragoBluePrinter.instance;

  static Future<void> printThermalInvoice({
    required String namaHotel,
    required String alamat,
    required String tanggalTransaksi,
    required String atasNama,
    required List<Map<String, dynamic>> detailPesanan,
    required double Function(double) getBiayaLayanan,
    required double Function(double) getPpn,
    String? catatan,
  }) async {
    final formatCurrency =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    double subtotal = detailPesanan.fold(
      0,
      (sum, item) => sum + (item['harga'] * item['jumlah']),
    );
    double layanan = getBiayaLayanan(subtotal);
    double ppn = getPpn(subtotal);
    double amountDue = subtotal + ppn + layanan;

    try {
      await bluetooth.printNewLine();
      await bluetooth.printCustom(namaHotel.toUpperCase(), 2, 1);
      await bluetooth.printCustom(alamat, 0, 1);
      await bluetooth.printCustom("Tanggal: $tanggalTransaksi", 0, 0);
      await bluetooth.printCustom("Atas Nama: $atasNama", 0, 0);
      await bluetooth.printNewLine();

      await bluetooth.printCustom("--------------------------------", 0, 0);
      await bluetooth.printCustom("Item         Qty   Harga   Total", 0, 0);
      await bluetooth.printCustom("--------------------------------", 0, 0);

      for (var item in detailPesanan) {
        String name = item['item'];
        int qty = item['jumlah'];
        int harga = item['harga'];
        int total = qty * harga;
        await bluetooth.printCustom(
          "${name.padRight(12)} ${qty}x  ${formatCurrency.format(harga)}",
          0,
          0,
        );
        await bluetooth.printCustom(
          "Total: ${formatCurrency.format(total)}",
          0,
          2,
        );
        await bluetooth.printCustom("--------------------------------", 0, 0);
      }

      await bluetooth.printCustom(
          "Subtotal     : ${formatCurrency.format(subtotal)}", 0, 2);
      await bluetooth.printCustom(
          "PPN (10%)    : ${formatCurrency.format(ppn)}", 0, 2);
      await bluetooth.printCustom(
          "Layanan (11%): ${formatCurrency.format(layanan)}", 0, 2);
      await bluetooth.printCustom("--------------------------------", 0, 0);
      await bluetooth.printCustom(
          "TOTAL        : ${formatCurrency.format(amountDue)}", 2, 2);

      if (catatan != null && catatan.isNotEmpty) {
        await bluetooth.printNewLine();
        await bluetooth.printCustom("Catatan:", 0, 0);
        await bluetooth.printCustom(catatan, 0, 0);
      }

      await bluetooth.printNewLine();
      await bluetooth.printCustom("Terima Kasih", 1, 1);
      await bluetooth.printCustom("Semoga Hari Anda Menyenangkan!", 0, 1);
      await bluetooth.printNewLine();
      await bluetooth.printNewLine();
    } catch (e) {
      print("Gagal print: $e");
    }
  }
}
