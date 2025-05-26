import 'package:flutter/material.dart';
import 'package:fnb_hotel/screens/admin/sidebarScreen/produkList/ProductList.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fnb_hotel/screens/admin/sidebarScreen/addProduct.dart';
import 'package:fnb_hotel/screens/admin/sidebarScreen/akun.dart';
import 'package:fnb_hotel/screens/admin/sidebarScreen/riwayat.dart';

class SidebarAdmin extends StatefulWidget {
  final bool isAdmin;

  const SidebarAdmin({Key? key, required this.isAdmin}) : super(key: key);

  @override
  _SidebarAdminState createState() => _SidebarAdminState();
}

class _SidebarAdminState extends State<SidebarAdmin> {
  int _selectedIndex = 0;
  String? _token; // Variabel untuk menyimpan token

  // Daftar untuk judul, ikon, dan halaman yang akan dipilih
  final List<String> _titles = [
    'Product',
    'Riwayat',
    'Akun',
  ];
  final List<IconData> _icons = [
    Icons.production_quantity_limits,
    Icons.history,
    Icons.account_circle,
  ];

  // Membuat variabel untuk menyimpan halaman yang dipilih
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _getToken(); // Mengambil token dari SharedPreferences

    // Inisialisasi _pages setelah widget.isAdmin tersedia
    _pages = [
      ProductList(),
      Riwayat(),
      Akun(),
    ];
  }

  // Fungsi untuk mengambil token dari SharedPreferences
  void _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('token');
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: size.width * 0.1,
            color: Color(0xffE22323),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_titles.length, (index) {
                final isSelected = _selectedIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.transparent,
                      borderRadius: isSelected
                          ? BorderRadius.only(
                              bottomLeft: Radius.circular(30),
                              topLeft: Radius.circular(30))
                          : null,
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _icons[index],
                          color: isSelected ? Color(0xffE22323) : Colors.white,
                          size: 28,
                        ),
                        const SizedBox(width: 4),
                        if (isSelected)
                          Text(
                            _titles[index],
                            style: const TextStyle(
                              color: Color(0xffE22323),
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          // Content Area
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _pages[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }
}
