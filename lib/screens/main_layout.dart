import 'package:flutter/material.dart';
import 'home_screen.dart';
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

  // 1. DOKUNUŞ: async ve await eklendi. Pop-up'ın kapanmasını dinliyoruz.
  void _islemEkleSheetAc(BuildContext context) async {
    final sonuc = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => const IslemEkleSheet(),
    );

    // 2. DOKUNUŞ: Eğer IslemEkleSheet "true" döndürdüyse (işlem kaydedildiyse) ekranı yenile!
    if (sonuc == true) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> sayfalar = [
      // 3. DOKUNUŞ: Baştaki const silindi ve UniqueKey eklendi.
      // Bu sayede setState tetiklendiğinde ekran mecburen API'den güncel parayı çekecek.
      HomeScreen(key: UniqueKey()),

      IslemlerScreen(onTabBack: () => setState(() => _currentIndex = 0)),
      RaporlarScreen(onTabBack: () => setState(() => _currentIndex = 0)),
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
        shape: const AutomaticNotchedShape(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          CircleBorder(),
        ),
        notchMargin: 8.0,
        color: Colors.white,
        elevation: 15,
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
    bool aktifMi = _currentIndex == index && index != 3;
    Color aktifRenk = const Color(0xFF0C4D3E);
    Color pasifRenk = Colors.grey.shade400;

    return GestureDetector(
      onTap: () {
        if (index == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfilScreen()),
          );
        } else {
          setState(() {
            _currentIndex = index;
          });
        }
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
