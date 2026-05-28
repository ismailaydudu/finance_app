import 'package:flutter/material.dart';
import '../widgets/islem_karti.dart';

class IslemlerScreen extends StatefulWidget {
  // AKILLI TETİKLEYİCİ: Alt sekmeyken ana sayfaya dönmeyi sağlar
  final VoidCallback? onTabBack;

  const IslemlerScreen({super.key, this.onTabBack});

  @override
  State<IslemlerScreen> createState() => _IslemlerScreenState();
}

class _IslemlerScreenState extends State<IslemlerScreen> {
  int _seciliFiltreIndex = 0;
  final List<String> _filtreler = ["Tümü", "Gelir", "Gider", "Transfer"];

  final Map<String, List<Map<String, dynamic>>> _tumIslemler = {
    "Bugün": [
      {
        "baslik": "Freelance Proje",
        "saat": "09:30",
        "miktar": "+ ₺3.000",
        "tip": "Gelir",
        "ikon": Icons.card_travel,
        "renk": Colors.purple,
      },
      {
        "baslik": "Kahve",
        "saat": "08:45",
        "miktar": "- ₺95",
        "tip": "Gider",
        "ikon": Icons.apple,
        "renk": Colors.green,
      },
    ],
    "Dün": [
      {
        "baslik": "Market Alışverişi",
        "saat": "20:15",
        "miktar": "- ₺1.250",
        "tip": "Gider",
        "ikon": Icons.shopping_bag,
        "renk": Colors.blueAccent,
      },
      {
        "baslik": "Online Alışveriş",
        "saat": "18:40",
        "miktar": "- ₺650",
        "tip": "Gider",
        "ikon": Icons.shopping_bag,
        "renk": Colors.blueAccent,
      },
      {
        "baslik": "Aleyna'ya Borç",
        "saat": "14:00",
        "miktar": "- ₺500",
        "tip": "Transfer",
        "ikon": Icons.sync_alt,
        "renk": Colors.blue,
      },
    ],
    "2 Mayıs": [
      {
        "baslik": "Maaş",
        "saat": "09:00",
        "miktar": "+ ₺25.000",
        "tip": "Gelir",
        "ikon": Icons.work,
        "renk": Colors.green,
      },
      {
        "baslik": "Kira",
        "saat": "10:30",
        "miktar": "- ₺6.000",
        "tip": "Gider",
        "ikon": Icons.receipt_long,
        "renk": Colors.blue,
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // DUAL GERİ TUŞU MİMARİSİ
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black87,
            size: 18,
          ),
          onPressed: () {
            if (Navigator.canPop(context)) {
              // 1. Durum: "Tümünü Gör"den açıldıysa sayfayı normal şekilde kapatır
              Navigator.pop(context);
            } else if (widget.onTabBack != null) {
              // 2. Durum: Alt sekmeyken basıldıysa ana sayfa sekmesine (index 0) geçiş yaptırır
              widget.onTabBack!();
            }
          },
        ),
        title: const Text(
          'İşlemlerim',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: Colors.grey.shade500),
                        const SizedBox(width: 10),
                        Text(
                          "İşlem ara...",
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.filter_alt_outlined,
                        color: Colors.grey.shade700,
                      ),
                      Positioned(
                        right: 12,
                        top: 12,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_filtreler.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _seciliFiltreIndex = index;
                        });
                      },
                      child: _filtreCipi(
                        baslik: _filtreler[index],
                        seciliMi: _seciliFiltreIndex == index,
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 24),
            ..._tumIslemler.entries.map((grup) {
              var filtrelenmisIslemler =
                  grup.value.where((islem) {
                    if (_seciliFiltreIndex == 0) return true;
                    if (_seciliFiltreIndex == 1 && islem["tip"] == "Gelir")
                      return true;
                    if (_seciliFiltreIndex == 2 && islem["tip"] == "Gider")
                      return true;
                    if (_seciliFiltreIndex == 3 && islem["tip"] == "Transfer")
                      return true;
                    return false;
                  }).toList();

              if (filtrelenmisIslemler.isEmpty) return const SizedBox.shrink();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _tarihBasligi(grup.key),
                  _islemKartGrubu(
                    islemler:
                        filtrelenmisIslemler.map((islem) {
                          return IslemKarti(
                            ikon: islem["ikon"],
                            renk: islem["renk"],
                            baslik: islem["baslik"],
                            altBaslik: islem["saat"],
                            miktar: islem["miktar"],
                            miktarRengi:
                                islem["tip"] == "Gelir"
                                    ? Colors.green
                                    : (islem["tip"] == "Transfer"
                                        ? Colors.blue
                                        : Colors.red),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 20),
                ],
              );
            }),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _filtreCipi({required String baslik, required bool seciliMi}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: seciliMi ? const Color(0xFF0C4D3E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: seciliMi ? Colors.transparent : Colors.grey.shade300,
        ),
      ),
      child: Text(
        baslik,
        style: TextStyle(
          color: seciliMi ? Colors.white : Colors.black87,
          fontWeight: seciliMi ? FontWeight.bold : FontWeight.normal,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _tarihBasligi(String tarih) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        tarih,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _islemKartGrubu({required List<Widget> islemler}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: islemler),
    );
  }
}
