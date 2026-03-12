import 'package:bbs_sales_app/features/profile/presentation/pages/profile_page.dart';
import 'package:bbs_sales_app/features/reimburse/presentation/pages/list_reimburse_page.dart';
import 'package:flutter/material.dart';

class HomeSpv extends StatefulWidget {
  const HomeSpv({super.key});

  @override
  State<HomeSpv> createState() => _HomeSpvState();
}

class _HomeSpvState extends State<HomeSpv> {
  int _selectedIndex = 0;

  // List halaman yang akan ditampilkan
  final List<Widget> _pages = [
    const ReimburseListPage(),
    const ProfilePage(), // Pastikan Anda sudah membuat atau mengimpor widget ini
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue, // Sesuaikan dengan tema aplikasi Anda
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Reimburse',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
