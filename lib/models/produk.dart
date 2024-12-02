class Product {
  final num? id;
  final String judulProduk;
  final String? fotoProduk;
  final num? harga;
  final String? kategoriProduk;
  final String? subKategoriProduk;
  final num? hargaAwal;
  final num? hargaJual;
  final num? stok;
  int quantity;

  Product({
    required this.id,
    required this.judulProduk,
    required this.fotoProduk,
    required this.harga,
    required this.kategoriProduk,
    required this.subKategoriProduk,
    required this.hargaAwal,
    required this.hargaJual,
    required this.stok,
    this.quantity = 1,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int?,
      judulProduk: json['judul_produk'] ?? 'Tanpa Judul',
      fotoProduk: json['foto_produk'],
      harga: json['harga'] ?? 0,
      kategoriProduk: json['kategori_produk'] ?? 'Tanpa Kategori',
      subKategoriProduk: json['sub_kategori_produk'] ?? 'Tanpa Sub Kategori',
      hargaAwal: json['hargaAwal'] ?? 0,
      hargaJual: json['hargaJual'] ?? 0,
      stok: json['stok'] ?? 0,
      quantity: 1,
    );
  }
}


// class Product {
//   final int? id;
//   final String judulProduk;
//   final String deskripsiProduk;
//   final String? fotoProduk;
//   final int? harga;
//   final int? jumlah;
//   final String kategoriProduk;
//    int quantity;

//   Product({
//     this.id,
//     required this.judulProduk,
//     required this.deskripsiProduk,
//     this.fotoProduk,
//     this.harga,
//     this.jumlah,
//     required this.kategoriProduk,
//     this.quantity = 1,
    
//   });

//   factory Product.fromJson(Map<String, dynamic> json) {
//     return Product(
//       id: json['id'] as int?,
//       judulProduk: json['judul_produk'] ?? 'Tanpa Judul',
//       deskripsiProduk: json['deskripsi_produk'] ?? '',
//       fotoProduk: json['foto_produk'],
//       harga: json['harga'] ?? 0,
//       jumlah: json['jumlah'] ?? 1,
//       kategoriProduk: json['kategori_produk'] ?? 'Tanpa Kategori',
//       quantity: 1,
//     );
//   }
// }
