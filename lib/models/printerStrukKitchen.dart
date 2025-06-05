import 'package:drago_blue_printer/drago_blue_printer.dart';

class KitchenPrinter {
  static final DragoBluePrinter bluetooth = DragoBluePrinter.instance;

  static Future<void> printKitchenOrder({
    required String atasNama,
    required List<Map<String, dynamic>> detailPesanan,
  }) async {
    try {
      await bluetooth.printNewLine();
      await bluetooth.printCustom("==== KIRIM KE DAPUR ====", 1, 1);
      await bluetooth.printNewLine();
      await bluetooth.printCustom("Pesanan Untuk: $atasNama", 1, 0);
      await bluetooth.printCustom("--------------------------------", 0, 0);
      await bluetooth.printCustom("Item           Qty   Catatan", 0, 0);
      await bluetooth.printCustom("--------------------------------", 0, 0);

      for (var item in detailPesanan) {
        String name = item['item'];
        int qty = item['jumlah'];
        String note = item['note'] ?? '-';

        await bluetooth.printCustom(
          "${name.padRight(14)} ${qty.toString().padRight(5)} ${note}",
          0,
          0,
        );
      }

      await bluetooth.printCustom("--------------------------------", 0, 0);
      await bluetooth.printNewLine();
      await bluetooth.printCustom("*** SELESAIKAN DENGAN CEPAT ***", 1, 1);
      await bluetooth.printNewLine();
      await bluetooth.printNewLine();
    } catch (e) {
      print("Gagal print ke dapur: $e");
    }
  }
}
