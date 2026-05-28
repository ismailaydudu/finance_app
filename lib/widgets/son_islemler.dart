import 'package:flutter/material.dart';
import 'islem_karti.dart';
import '../screens/islemler_screen.dart'; // Tümünü gör için işlemler ekranını içeri aktardık

class SonIslemler extends StatelessWidget {
  const SonIslemler({super.key});

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
          // BAŞLIK ALANI
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Son İşlemler",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              // "Tümünü Gör" Butonunun Tıklama Alanı
              GestureDetector(
                onTap: () {
                  // Tıklandığında sayfayı pürüzsüzce İşlemlerim ekranına yönlendiriyoruz
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const IslemlerScreen(),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Text(
                      "Tümünü Gör",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 10,
                      color: Colors.grey.shade600,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // LİSTE İÇERİĞİ (Merkezi Kategori Rehberine Tam Uyumlu)
          const Column(
            children: [
              IslemKarti(
                ikon: Icons.work,
                renk: Colors.green,
                baslik: "Maaş",
                altBaslik: "Bugün",
                miktar: "+ ₺25.000",
                miktarRengi: Colors.green,
              ),
              IslemKarti(
                ikon: Icons.shopping_bag,
                renk: Colors.blueAccent,
                baslik: "Market Alışverişi",
                altBaslik: "Dün",
                miktar: "- ₺1.250",
                miktarRengi: Colors.red,
              ),
              IslemKarti(
                ikon: Icons.receipt_long,
                renk: Colors.blue,
                baslik: "Kira",
                altBaslik: "2 Mayıs",
                miktar: "- ₺6.000",
                miktarRengi: Colors.red,
              ),
              IslemKarti(
                ikon: Icons.directions_car,
                renk: Colors.orange,
                baslik: "Yakıt",
                altBaslik: "1 Mayıs",
                miktar: "- ₺850",
                miktarRengi: Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
