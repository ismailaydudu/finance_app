import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';

class RaporlarScreen extends StatefulWidget {
  final VoidCallback? onTabBack;

  const RaporlarScreen({super.key, this.onTabBack});

  @override
  State<RaporlarScreen> createState() => _RaporlarScreenState();
}

class _RaporlarScreenState extends State<RaporlarScreen> {
  int _seciliFiltreIndex = 0;
  final List<String> _filtreler = ["Genel Bakış", "Gelir", "Gider", "Tasarruf"];

  // AY SEÇİCİ İÇİN GEREKLİ DEĞİŞKENLER
  String _seciliAy = "Mayıs 2026";
  final List<String> _aylar = [
    "Ocak 2026", "Şubat 2026", "Mart 2026", "Nisan 2026", 
    "Mayıs 2026", "Haziran 2026", "Temmuz 2026", "Ağustos 2026", 
    "Eylül 2026", "Ekim 2026", "Kasım 2026", "Aralık 2026"
  ];

  final Map<String, Color> _kategoriRenkleri = {
    "Fatura": Colors.blue.shade600,
    "Gıda": Colors.green.shade400,
    "Alışveriş": Colors.blueAccent.shade400,
    "Eğlence": Colors.purple.shade400,
    "Ulaşım": Colors.orange.shade400,
    "Kira": Colors.teal.shade400,
    "Maaş": Colors.green.shade700,
    "Prim": Colors.blue.shade700,
    "Yatırım": Colors.indigo.shade400,
    "Diğer": Colors.grey.shade400,
  };

  final Map<String, IconData> _kategoriIkonlari = {
    "Fatura": Icons.receipt_long,
    "Gıda": Icons.apple,
    "Alışveriş": Icons.shopping_bag,
    "Eğlence": Icons.sports_esports_rounded,
    "Ulaşım": Icons.directions_car,
    "Kira": Icons.home,
    "Maaş": Icons.work,
    "Prim": Icons.star,
    "Yatırım": Icons.trending_up,
    "Diğer": Icons.category,
  };

  // ANA SAYFADAKİ ŞIK AY SEÇİCİ (BOTTOM SHEET)
  void _aySeciciyiAc() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: 400,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              const Text("Ay Seçin", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: _aylar.length,
                  itemBuilder: (context, index) {
                    bool seciliMi = _seciliAy == _aylar[index];
                    return ListTile(
                      title: Text(
                        _aylar[index], 
                        style: TextStyle(
                          fontSize: 16, 
                          fontWeight: seciliMi ? FontWeight.bold : FontWeight.normal,
                          color: seciliMi ? const Color(0xFF0C4D3E) : Colors.black87
                        ),
                        textAlign: TextAlign.center,
                      ),
                      tileColor: seciliMi ? const Color(0xFF0C4D3E).withAlpha(15) : Colors.transparent,
                      onTap: () {
                        setState(() => _seciliAy = _aylar[index]);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
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
        // YAZI SİLİNDİ, TERTEMİZ BAŞLIK YAPILDI
        title: const Text('Raporlar', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        actions: [
          // TAKVİM İKONUNA TIKLAMA ÖZELLİĞİ (AY SEÇİCİ) BAĞLANDI
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined, color: Colors.black87), 
            onPressed: _aySeciciyiAc,
          )
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: ApiService.islemleriGetir(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          double toplamDeger = 0.0;
          Map<String, double> kategoriDegerleri = {};
          String grafikBasligi = "Toplam";
          String listeBasligi = "En Çok Harcama Yapılan 3 Kategori";

          if (snapshot.hasData) {
            for (var islem in snapshot.data!) {
              String tip = islem['islemTipi'].toString().toUpperCase();
              double tutar = double.tryParse(islem['tutar'].toString()) ?? 0.0;
              String gelenKategoriRaw = islem['kategori']?.toString() ?? "Diğer";
              String kategori = gelenKategoriRaw.isNotEmpty 
                  ? gelenKategoriRaw[0].toUpperCase() + gelenKategoriRaw.substring(1).toLowerCase()
                  : "Diğer";

              if (_seciliFiltreIndex == 0) { 
                grafikBasligi = "Net Bakiye";
                listeBasligi = "En Yüksek İşlem Hacimleri";
                toplamDeger += tutar; 
                kategoriDegerleri[kategori] = (kategoriDegerleri[kategori] ?? 0) + tutar;
              } 
              else if (_seciliFiltreIndex == 1 && tip == 'GELIR') {
                grafikBasligi = "Toplam Gelir";
                listeBasligi = "En Çok Gelir Getiren 3 Kategori";
                toplamDeger += tutar;
                kategoriDegerleri[kategori] = (kategoriDegerleri[kategori] ?? 0) + tutar;
              } 
              else if (_seciliFiltreIndex == 2 && tip == 'GIDER') {
                grafikBasligi = "Toplam Gider";
                listeBasligi = "En Çok Harcama Yapılan 3 Kategori";
                toplamDeger += tutar;
                kategoriDegerleri[kategori] = (kategoriDegerleri[kategori] ?? 0) + tutar;
              }
            }
          }

          var siraliKategoriler = kategoriDegerleri.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          List<PieChartSectionData> pastaVerileri = [];
          if (toplamDeger == 0) {
            pastaVerileri.add(PieChartSectionData(color: Colors.grey.shade300, value: 1, radius: 14, showTitle: false));
          } else {
            for (var entry in siraliKategoriler) {
              double yuzde = (entry.value / toplamDeger) * 100;
              if (yuzde > 0) {
                pastaVerileri.add(
                  PieChartSectionData(
                    color: _kategoriRenkleri[entry.key] ?? Colors.grey.shade400,
                    value: yuzde,
                    radius: 14,
                    showTitle: false,
                  ),
                );
              }
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(_filtreler.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: GestureDetector(
                          onTap: () => setState(() => _seciliFiltreIndex = index),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: _seciliFiltreIndex == index ? const Color(0xFF0C4D3E) : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: _seciliFiltreIndex == index ? Colors.transparent : Colors.grey.shade200),
                            ),
                            child: Text(
                              _filtreler[index],
                              style: TextStyle(
                                color: _seciliFiltreIndex == index ? Colors.white : Colors.black87,
                                fontWeight: _seciliFiltreIndex == index ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: Colors.grey.withAlpha(8), blurRadius: 10, offset: const Offset(0, 5))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${_filtreler[_seciliFiltreIndex]} Dağılımı", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          SizedBox(
                            width: 140, height: 140,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                PieChart(PieChartData(sectionsSpace: 2, centerSpaceRadius: 50, sections: pastaVerileri)),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(grafikBasligi, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                    const SizedBox(height: 2),
                                    Text("₺${toplamDeger.toStringAsFixed(0)}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: Column(
                              children: siraliKategoriler.take(5).map((entry) {
                                double yuzde = (entry.value / toplamDeger) * 100;
                                return _pastaGosterge(
                                  _kategoriRenkleri[entry.key] ?? Colors.grey.shade400,
                                  entry.key,
                                  "%${yuzde.toStringAsFixed(0)}",
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: Colors.grey.withAlpha(8), blurRadius: 10, offset: const Offset(0, 5))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Gelir & Gider Trendi", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                          Row(
                            children: [
                              _trendEfsane(Colors.green, "Gelir"),
                              const SizedBox(width: 10),
                              _trendEfsane(Colors.red, "Gider"),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        height: 180,
                        child: LineChart(
                          LineChartData(
                            gridData: const FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                            titlesData: FlTitlesData(
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true, interval: 10000, reservedSize: 30,
                                  getTitlesWidget: (value, meta) {
                                    if (value == 0) return const Text('0', style: TextStyle(fontSize: 10, color: Colors.grey));
                                    return Text('${(value / 1000).toInt()}K', style: const TextStyle(fontSize: 10, color: Colors.grey));
                                  },
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true, interval: 1,
                                  getTitlesWidget: (value, meta) {
                                    switch (value.toInt()) {
                                      case 1: return const Text('1 May', style: TextStyle(fontSize: 9, color: Colors.grey));
                                      case 3: return const Text('7 May', style: TextStyle(fontSize: 9, color: Colors.grey));
                                      case 5: return const Text('14 May', style: TextStyle(fontSize: 9, color: Colors.grey));
                                      case 7: return const Text('21 May', style: TextStyle(fontSize: 9, color: Colors.grey));
                                      case 9: return const Text('31 May', style: TextStyle(fontSize: 9, color: Colors.grey));
                                    }
                                    return const Text('');
                                  },
                                ),
                              ),
                            ),
                            minX: 0, maxX: 10, minY: 0, maxY: 40000,
                            lineBarsData: [
                              LineChartBarData(
                                spots: const [FlSpot(0, 8000), FlSpot(2, 16000), FlSpot(4, 27000), FlSpot(5, 22000), FlSpot(6, 31000), FlSpot(8, 24000), FlSpot(10, 30000)],
                                isCurved: true, color: Colors.green, barWidth: 3, isStrokeCapRound: true, dotData: const FlDotData(show: false),
                              ),
                              LineChartBarData(
                                spots: const [FlSpot(0, 7000), FlSpot(2, 14000), FlSpot(4, 10000), FlSpot(5, 7000), FlSpot(6, 14000), FlSpot(8, 17000), FlSpot(10, 15000)],
                                isCurved: true, color: Colors.red, barWidth: 3, isStrokeCapRound: true, dotData: const FlDotData(show: false),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: Colors.grey.withAlpha(8), blurRadius: 10, offset: const Offset(0, 5))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(listeBasligi, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                      const SizedBox(height: 16),
                      if (toplamDeger == 0)
                        const Padding(padding: EdgeInsets.only(top: 10), child: Text("Bu filtreye uygun işlem bulunmuyor.", style: TextStyle(color: Colors.grey))),
                      ...siraliKategoriler.take(3).map((entry) {
                        double ilerleme = entry.value / toplamDeger;
                        return _enCokHarcamaSatiri(
                          _kategoriIkonlari[entry.key] ?? Icons.category,
                          _kategoriRenkleri[entry.key] ?? Colors.grey,
                          entry.key,
                          "₺${entry.value.toStringAsFixed(0)}",
                          ilerleme,
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _pastaGosterge(Color renk, String baslik, String yuzde) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: renk, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(baslik, style: const TextStyle(fontSize: 12, color: Colors.black87)),
          const Spacer(),
          Text(yuzde, style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _trendEfsane(Color renk, String baslik) {
    return Row(
      children: [
        Container(width: 12, height: 3, decoration: BoxDecoration(color: renk, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 6),
        Text(baslik, style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _enCokHarcamaSatiri(IconData ikon, Color renk, String baslik, String tutar, double ilerleme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: renk.withAlpha(26), borderRadius: BorderRadius.circular(12)), child: Icon(ikon, color: renk, size: 20)),
          const SizedBox(width: 14),
          SizedBox(width: 70, child: Text(baslik, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis)),
          const SizedBox(width: 10),
          Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: ilerleme, minHeight: 6, backgroundColor: Colors.grey.shade100, valueColor: AlwaysStoppedAnimation<Color>(renk)))),
          const SizedBox(width: 14),
          Text(tutar, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}