import 'package:flutter/material.dart';
import 'home_screen.dart'; // Dosya ismini home_screen.dart olarak düzelttik
import 'islemler_screen.dart';
import 'raporlar_screen.dart';
import 'profil_screen.dart';
import '../widgets/islem_ekle_sheet.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  void _islemEkleSheetAc(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => const IslemEkleSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> sayfalar = [
      const HomeScreen(), // Sınıf ismini HomeScreen() yaptık

      IslemlerScreen(
        onTabBack: () {
          setState(() {
            _currentIndex = 0; // İşlemlerde basınca Home'a döner
          });
        },
      ),

      RaporlarScreen(
        onTabBack: () {
          setState(() {
            _currentIndex = 0; // Raporlarda basınca Home'a döner
          });
        },
      ),

      const ProfilScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _islemEkleSheetAc(context),
        backgroundColor: const Color(0xFF0C4D3E),
        shape: const CircleBorder(),
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.white,
        elevation: 10,
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navBarButonu(Icons.home_filled, "Ana Sayfa", 0),
              _navBarButonu(Icons.assignment_turned_in_rounded, "İşlemler", 1),
              const SizedBox(width: 40),
              _navBarButonu(Icons.bar_chart_rounded, "Raporlar", 2),
              _navBarButonu(Icons.person_rounded, "Profil", 3),
            ],
          ),
        ),
      ),
      body: sayfalar[_currentIndex],
    );
  }

  Widget _navBarButonu(IconData ikon, String etiket, int index) {
    bool aktifMi = _currentIndex == index;
    Color aktifRenk = const Color(0xFF0C4D3E);
    Color pasifRenk = Colors.grey.shade400;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(ikon, color: aktifMi ? aktifRenk : pasifRenk, size: 24),
          const SizedBox(height: 4),
          Text(
            etiket,
            style: TextStyle(
              fontSize: 11,
              fontWeight: aktifMi ? FontWeight.bold : FontWeight.w500,
              color: aktifMi ? aktifRenk : pasifRenk,
            ),
          ),
        ],
      ),
    );
  }
}
