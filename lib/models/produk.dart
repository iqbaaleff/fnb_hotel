class Product {
  final int? id;
  final String judulProduk;
  final String deskripsiProduk;
  final String? fotoProduk;
  final int? harga;
  final int? jumlah;
  final String kategoriProduk;

  Product({
    this.id,
    required this.judulProduk,
    required this.deskripsiProduk,
    this.fotoProduk,
    this.harga,
    this.jumlah,
    required this.kategoriProduk,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int?,
      judulProduk: json['judul_produk'] ?? 'Tanpa Judul',
      deskripsiProduk: json['deskripsi_produk'] ?? '',
      fotoProduk: json['foto_produk'],
      harga: json['harga'] ?? 0,
      jumlah: json['jumlah'] ?? 1,
      kategoriProduk: json['kategori_produk'] ?? 'Tanpa Kategori',
    );
  }
}