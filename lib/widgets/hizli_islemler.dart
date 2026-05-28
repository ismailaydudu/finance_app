import 'package:flutter/material.dart';
import 'islem_ekle_sheet.dart';
import '../screens/doviz_screen.dart';
import '../screens/tasarruf_hedeflerim_screen.dart';

class HizliIslemler extends StatelessWidget {
  const HizliIslemler({super.key});

  void _sheetAc(BuildContext context, bool gelirMi) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => IslemEkleSheet(initialIsGelir: gelirMi),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Hızlı İşlemler",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 1. GELİR EKLE
              _islemButonu(
                ikon: Icons.add_circle,
                renk: Colors.green,
                baslik: "Gelir Ekle",
                onTap: () => _sheetAc(context, true),
              ),

              // 2. GİDER EKLE
              _islemButonu(
                ikon: Icons.remove_circle,
                renk: Colors.red,
                baslik: "Gider Ekle",
                onTap: () => _sheetAc(context, false),
              ),

              // 3. ANLIK KUR
              _islemButonu(
                ikon: Icons.currency_exchange_rounded,
                renk: Colors.purple,
                baslik: "Anlık Kur",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DovizScreen(),
                    ),
                  );
                },
              ),

              // 4. HEDEFLERİM (YENİ MODERN İKON)
              _islemButonu(
                ikon:
                    Icons
                        .track_changes_rounded, // Klasik kumbara yerine lüks hedef/odak ikonu
                renk: Colors.orange,
                baslik: "Hedeflerim",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TasarrufHedeflerimScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _islemButonu({
    required IconData ikon,
    required Color renk,
    required String baslik,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: renk.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(ikon, color: renk, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            baslik,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
