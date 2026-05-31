import 'package:flutter/material.dart';
import '../widgets/islem_karti.dart';
import '../services/api_service.dart';

class IslemlerScreen extends StatefulWidget {
  final VoidCallback? onTabBack;
  const IslemlerScreen({super.key, this.onTabBack});

  @override
  State<IslemlerScreen> createState() => _IslemlerScreenState();
}

class _IslemlerScreenState extends State<IslemlerScreen> {
  int _seciliFiltreIndex = 0;
  final List<String> _filtreler = ["Tümü", "Gelir", "Gider", "Transfer"];

  // Ana Sayfadaki akıllı ikon motoru
  IconData _ikonSec(String kategori, String tip) {
    String k = kategori.toLowerCase();
    if (k.contains('fatura')) return Icons.receipt_long;
    if (k.contains('gıda')) return Icons.apple;
    if (k.contains('alışveriş')) return Icons.shopping_bag;
    if (k.contains('eğlence')) return Icons.sports_esports_rounded;
    if (k.contains('ulaşım')) return Icons.directions_car;
    if (k.contains('kira')) return Icons.home;
    
    return tip == 'GELIR' ? Icons.work : Icons.category;
  }

  // Ana Sayfadaki akıllı renk motoru
  Color _renkSec(String kategori, String tip) {
    String k = kategori.toLowerCase();
    if (k.contains('fatura')) return Colors.blue.shade600;
    if (k.contains('gıda')) return Colors.green.shade400;
    if (k.contains('alışveriş')) return Colors.blueAccent.shade400;
    if (k.contains('eğlence')) return Colors.purple.shade400;
    if (k.contains('ulaşım')) return Colors.orange.shade400;
    if (k.contains('kira')) return Colors.teal.shade400;
    
    return tip == 'GELIR' ? Colors.green : Colors.redAccent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: _appBar(),
      body: FutureBuilder<List<dynamic>>(
        future: ApiService.islemleriGetir(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Henüz hiç işlem girmediniz."));
          }

          var tumIslemler = snapshot.data!;
          
          // FİLTRELEME MANTIĞI
          var filtrelenmis = tumIslemler.where((i) {
            String tip = (i['islemTipi'] ?? 'GIDER').toString().toUpperCase();
            if (_seciliFiltreIndex == 0) return true;
            if (_seciliFiltreIndex == 1) return tip == "GELIR";
            if (_seciliFiltreIndex == 2) return tip == "GIDER";
            if (_seciliFiltreIndex == 3) return tip == "TRANSFER"; // Transfer mantığı eklendi
            return false;
          }).toList();

          // Tarihe göre gruplama (Orijinal yapı)
          Map<String, List<dynamic>> gruplu = {};
          for (var i in filtrelenmis) {
            String tarih = i['tarih'] ?? "Bilinmeyen Tarih";
            if (!gruplu.containsKey(tarih)) gruplu[tarih] = [];
            gruplu[tarih]!.add(i);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _filtreCubugu(),
                const SizedBox(height: 24),
                
                // BOŞ DURUM (EMPTY STATE) KONTROLÜ - BEYAZ EKRAN SORUNUNUN ÇÖZÜMÜ
                if (filtrelenmis.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 100.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          "Bu kategoride henüz bir\nişleminiz bulunmuyor.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  )
                else
                  // İŞLEMLER LİSTESİ
                  ...gruplu.entries.map((grup) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _tarihBasligi(grup.key),
                      _islemKartGrubu(islemler: grup.value),
                      const SizedBox(height: 20),
                    ],
                  )),
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- Yardımcı Widget'lar (Tasarımı korumak için) ---
  AppBar _appBar() => AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 18),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else if (widget.onTabBack != null) {
              widget.onTabBack!();
            }
          },
        ),
        title: const Text('İşlemlerim', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      );

  Widget _filtreCubugu() => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(_filtreler.length, (index) => Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => setState(() => _seciliFiltreIndex = index),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: _seciliFiltreIndex == index ? const Color(0xFF0C4D3E) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(_filtreler[index], style: TextStyle(color: _seciliFiltreIndex == index ? Colors.white : Colors.black87, fontWeight: _seciliFiltreIndex == index ? FontWeight.bold : FontWeight.normal)),
              ),
            ),
          )),
        ),
      );

  Widget _tarihBasligi(String tarih) => Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Text(tarih, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
      );

  Widget _islemKartGrubu({required List<dynamic> islemler}) => Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
        child: Column(
          children: islemler.map((i) {
            String tip = i['islemTipi'].toString().toUpperCase();
            bool gelirMi = tip == 'GELIR';
            String baslikRaw = i['baslik']?.toString() ?? "İşlem";
            String kategori = i['kategori']?.toString() ?? "Diğer";
            double tutarValue = double.tryParse(i['tutar']?.toString() ?? "0") ?? 0.0;

            String baslikGosterilen = baslikRaw.isNotEmpty ? baslikRaw[0].toUpperCase() + baslikRaw.substring(1) : baslikRaw;
            
            // Eğer kategori boşsa veya belirsizse ilk harfini büyüt
            String kategoriGosterilen = kategori.isNotEmpty ? kategori[0].toUpperCase() + kategori.substring(1).toLowerCase() : "Diğer";

            return IslemKarti(
              ikon: _ikonSec(kategori, tip),
              renk: _renkSec(kategori, tip),
              baslik: baslikGosterilen,
              altBaslik: kategoriGosterilen,
              miktar: "${gelirMi ? '+' : '-'} ₺${tutarValue.toStringAsFixed(0)}",
              miktarRengi: gelirMi ? Colors.green : Colors.red,
            );
          }).toList(),
        ),
      );
}