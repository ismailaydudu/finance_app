import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../screens/butce_screen.dart'; // Bütçe ekranını buraya tanıttık

class AylikOzetKarti extends StatelessWidget {
  const AylikOzetKarti({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. BÖLÜM: Üst Başlık Satırı
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Aylık Ozet",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        "Mayıs 2026",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        size: 18,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ],
              ),

              // Sağ Taraftaki 4 Noktalı İkon (Artık Tıklanabilir!)
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ButceScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.grid_view_rounded,
                    size: 20,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),

          // 2. BÖLÜM: Grafik ve Merkez Alan
          Center(
            child: SizedBox(
              width: 220,
              height: 220,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      sectionsSpace: 4,
                      centerSpaceRadius: 85,
                      startDegreeOffset: -90,
                      sections: [
                        PieChartSectionData(
                          color: const Color(0xFF00BFA5),
                          value: 50,
                          radius: 12,
                          showTitle: false,
                        ),
                        PieChartSectionData(
                          color: Colors.red.shade400,
                          value: 25,
                          radius: 12,
                          showTitle: false,
                        ),
                        PieChartSectionData(
                          color: Colors.blue.shade400,
                          value: 15,
                          radius: 12,
                          showTitle: false,
                        ),
                        PieChartSectionData(
                          color: Colors.orange.shade400,
                          value: 10,
                          radius: 12,
                          showTitle: false,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Toplam Bakiye",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "₺24.560,00",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.arrow_outward,
                            color: Colors.green,
                            size: 16,
                          ),
                          const SizedBox(width: 2),
                          const Text(
                            "%12 artış",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),

          // 3. BÖLÜM: Alt Kutular
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _bilgiKutusu(
                  ikon: Icons.arrow_upward,
                  ikonRengi: const Color(0xFF00BFA5),
                  baslik: "Gelir",
                  miktar: "₺38.500",
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _bilgiKutusu(
                  ikon: Icons.arrow_downward,
                  ikonRengi: Colors.red.shade400,
                  baslik: "Gider",
                  miktar: "₺13.940",
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _bilgiKutusu(
                  ikon: Icons.savings_outlined,
                  ikonRengi: Colors.blue.shade400,
                  baslik: "Tasarruf",
                  miktar: "₺24.560",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bilgiKutusu({
    required IconData ikon,
    required Color ikonRengi,
    required String baslik,
    required String miktar,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(ikon, color: ikonRengi, size: 20),
          const SizedBox(height: 6),
          Text(
            baslik,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: ikonRengi,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            miktar,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
