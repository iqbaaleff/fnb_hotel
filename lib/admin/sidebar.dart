import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fnb_hotel/admin/sidebarScreen/addProduct.dart';
import 'package:fnb_hotel/admin/sidebarScreen/akun.dart';
import 'package:fnb_hotel/admin/sidebarScreen/logout.dart';
import 'package:fnb_hotel/admin/sidebarScreen/riwayat.dart';

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
  final List<String> _titles = ['Product', 'Riwayat', 'Akun', 'Logout'];
  final List<IconData> _icons = [
    Icons.production_quantity_limits,
    Icons.history,
    Icons.account_circle,
    Icons.logout_outlined
  ];

  // Membuat variabel untuk menyimpan halaman yang dipilih
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _getToken(); // Mengambil token dari SharedPreferences

    // Inisialisasi _pages setelah widget.isAdmin tersedia
    _pages = [
      AddProduct(),
      Riwayat(),
      Akun(),
      LogoutAdmin(),
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
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 80,
            color: Colors.blueGrey[900],
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
                      color: isSelected
                          ? Colors.blueGrey[700]
                          : Colors.transparent,
                      borderRadius:
                          isSelected ? BorderRadius.circular(16) : null,
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      children: [
                        Icon(
                          _icons[index],
                          color: isSelected ? Colors.amber : Colors.white,
                          size: 28,
                        ),
                        const SizedBox(height: 4),
                        if (isSelected)
                          Text(
                            _titles[index],
                            style: const TextStyle(
                              color: Colors.amber,
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
