import 'package:flutter/material.dart';
import 'islem_karti.dart';
import '../screens/islemler_screen.dart';
import '../services/api_service.dart';

class SonIslemler extends StatelessWidget {
  const SonIslemler({super.key});

  // Backend'den gelen işleme göre dinamik ikon belirleyen motor
  IconData _ikonSec(String baslik, String tip) {
    String b = baslik.toLowerCase();
    if (b.contains('maaş') || b.contains('prim') || b.contains('kupon')) return Icons.work;
    if (b.contains('market') || b.contains('alışveriş') || b.contains('gıda')) return Icons.shopping_bag;
    if (b.contains('kira')) return Icons.receipt_long;
    if (b.contains('yakıt') || b.contains('araba') || b.contains('ulaşım')) return Icons.directions_car;
    if (b.contains('gym') || b.contains('spor') || b.contains('fıtnas')) return Icons.fitness_center;
    if (b.contains('fatura') || b.contains('borc') || b.contains('kredi')) return Icons.receipt_sharp;
    
    return tip == 'GELIR' ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded;
  }

  // Backend'den gelen işleme göre dinamik renk belirleyen motor
  Color _renkSec(String baslik, String tip) {
    String b = baslik.toLowerCase();
    if (b.contains('maaş') || b.contains('prim')) return Colors.green;
    if (b.contains('market') || b.contains('alışveriş')) return Colors.blueAccent;
    if (b.contains('kira')) return Colors.blue;
    if (b.contains('yakıt') || b.contains('ulaşım')) return Colors.orange;
    if (b.contains('gym') || b.contains('spor')) return Colors.purple;
    
    // HATA DÜZELTİLDİ: Colors.emerald yerine Colors.green kullanıldı.
    return tip == 'GELIR' ? Colors.green : Colors.redAccent;
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
          // BAŞLIK ALANI (ORİJİNAL)
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
              GestureDetector(
                onTap: () {
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

          // CANLI VERİTABANI BAĞLANTISI
          FutureBuilder<List<dynamic>>(
            future: ApiService.islemleriGetir(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      "Henüz bir hesap hareketi bulunmuyor.",
                      style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ),
                );
              }

              // HATA DÜZELTİLDİ: Türkçe karakter 'ı' kaldırılarak 'canliIslemler' yapıldı.
              var canliIslemler = snapshot.data!.reversed.take(4).toList();

              return Column(
                children: canliIslemler.map((islem) {
                  String baslikRaw = islem['baslik']?.toString() ?? "Belirsiz İşlem";
                  String islemTipi = islem['islemTipi']?.toString().toUpperCase() ?? "GIDER";
                  double tutarValue = double.tryParse(islem['tutar']?.toString() ?? "0") ?? 0.0;

                  // Başlığın ilk harfini büyütme işlemi
                  String baslikGosterilen = baslikRaw.isNotEmpty 
                      ? baslikRaw[0].toUpperCase() + baslikRaw.substring(1) 
                      : baslikRaw;

                  bool gelirMi = islemTipi == 'GELIR';
                  String miktarMetni = "${gelirMi ? '+' : '-'} ₺${tutarValue.toStringAsFixed(0)}";
                  Color miktarRengi = gelirMi ? Colors.green : Colors.red;

                  return IslemKarti(
                    ikon: _ikonSec(baslikRaw, islemTipi),
                    renk: _renkSec(baslikRaw, islemTipi),
                    baslik: baslikGosterilen,
                    altBaslik: gelirMi ? "Gelir Kaydı" : "Gider Kaydı",
                    miktar: miktarMetni,
                    miktarRengi: miktarRengi,
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}