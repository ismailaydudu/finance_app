import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class RaporlarScreen extends StatefulWidget {
  // Alt sekmeyken ana sayfaya dönmeyi sağlayan akıllı tetikleyici
  final VoidCallback? onTabBack;

  const RaporlarScreen({super.key, this.onTabBack});

  @override
  State<RaporlarScreen> createState() => _RaporlarScreenState();
}

class _RaporlarScreenState extends State<RaporlarScreen> {
  int _seciliFiltreIndex = 0;
  final List<String> _filtreler = ["Genel Bakış", "Gelir", "Gider", "Tasarruf"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // DUAL GERİ OKU MİMARİSİ
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black87,
            size: 18,
          ),
          onPressed: () {
            if (Navigator.canPop(context)) {
              // 1. Durum: Sayfa başka bir yerden push edilerek açıldıysa normal kapatır
              Navigator.pop(context);
            } else if (widget.onTabBack != null) {
              // 2. Durum: Alt menüde sekmeyken basıldıysa Ana Sayfa sekmesine fırlatır
              widget.onTabBack!();
            }
          },
        ),
        title: Column(
          children: [
            const Text(
              'Raporlar',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Mayıs 2026",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 14,
                  color: Colors.grey.shade600,
                ),
              ],
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.calendar_month_outlined,
              color: Colors.black87,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                      onTap: () {
                        setState(() {
                          _seciliFiltreIndex = index;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color:
                              _seciliFiltreIndex == index
                                  ? const Color(0xFF0C4D3E)
                                  : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color:
                                _seciliFiltreIndex == index
                                    ? Colors.transparent
                                    : Colors.grey.shade200,
                          ),
                        ),
                        child: Text(
                          _filtreler[index],
                          style: TextStyle(
                            color:
                                _seciliFiltreIndex == index
                                    ? Colors.white
                                    : Colors.black87,
                            fontWeight:
                                _seciliFiltreIndex == index
                                    ? FontWeight.bold
                                    : FontWeight.normal,
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
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Gider Dağılımı",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      SizedBox(
                        width: 140,
                        height: 140,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            PieChart(
                              PieChartData(
                                sectionsSpace: 2,
                                centerSpaceRadius: 50,
                                sections: [
                                  PieChartSectionData(
                                    color: Colors.blue.shade600,
                                    value: 23,
                                    radius: 14,
                                    showTitle: false,
                                  ),
                                  PieChartSectionData(
                                    color: Colors.green.shade400,
                                    value: 18,
                                    radius: 14,
                                    showTitle: false,
                                  ),
                                  PieChartSectionData(
                                    color: Colors.blueAccent.shade400,
                                    value: 13,
                                    radius: 14,
                                    showTitle: false,
                                  ),
                                  PieChartSectionData(
                                    color: Colors.purple.shade400,
                                    value: 11,
                                    radius: 14,
                                    showTitle: false,
                                  ),
                                  PieChartSectionData(
                                    color: Colors.orange.shade400,
                                    value: 7,
                                    radius: 14,
                                    showTitle: false,
                                  ),
                                  PieChartSectionData(
                                    color: Colors.grey.shade400,
                                    value: 28,
                                    radius: 14,
                                    showTitle: false,
                                  ),
                                ],
                              ),
                            ),
                            const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Toplam Gider",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  "₺13.940",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          children: [
                            _pastaGosterge(
                              Colors.blue.shade600,
                              "Fatura",
                              "%23",
                            ),
                            _pastaGosterge(
                              Colors.green.shade400,
                              "Gıda",
                              "%18",
                            ),
                            _pastaGosterge(
                              Colors.blueAccent.shade400,
                              "Alışveriş",
                              "%13",
                            ),
                            _pastaGosterge(
                              Colors.purple.shade400,
                              "Eğlence",
                              "%11",
                            ),
                            _pastaGosterge(
                              Colors.orange.shade400,
                              "Ulaşım",
                              "%7",
                            ),
                            _pastaGosterge(
                              Colors.grey.shade400,
                              "Diğer",
                              "%28",
                            ),
                          ],
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
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Gelir & Gider Trendi",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
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
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 10000,
                              getTitlesWidget: (value, meta) {
                                if (value == 0)
                                  return const Text(
                                    '0',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  );
                                return Text(
                                  '${(value / 1000).toInt()}K',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                              reservedSize: 30,
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                switch (value.toInt()) {
                                  case 1:
                                    return const Text(
                                      '1 May',
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: Colors.grey,
                                      ),
                                    );
                                  case 3:
                                    return const Text(
                                      '7 May',
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: Colors.grey,
                                      ),
                                    );
                                  case 5:
                                    return const Text(
                                      '14 May',
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: Colors.grey,
                                      ),
                                    );
                                  case 7:
                                    return const Text(
                                      '21 May',
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: Colors.grey,
                                      ),
                                    );
                                  case 9:
                                    return const Text(
                                      '31 May',
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: Colors.grey,
                                      ),
                                    );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                        ),
                        minX: 0,
                        maxX: 10,
                        minY: 0,
                        maxY: 40000,
                        lineBarsData: [
                          LineChartBarData(
                            spots: [
                              const FlSpot(0, 8000),
                              const FlSpot(2, 16000),
                              const FlSpot(4, 27000),
                              const FlSpot(5, 22000),
                              const FlSpot(6, 31000),
                              const FlSpot(8, 24000),
                              const FlSpot(10, 30000),
                            ],
                            isCurved: true,
                            color: Colors.green,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: false),
                          ),
                          LineChartBarData(
                            spots: [
                              const FlSpot(0, 7000),
                              const FlSpot(2, 14000),
                              const FlSpot(4, 10000),
                              const FlSpot(5, 7000),
                              const FlSpot(6, 14000),
                              const FlSpot(8, 17000),
                              const FlSpot(10, 15000),
                            ],
                            isCurved: true,
                            color: Colors.red,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: false),
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
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "En Çok Harcama Yapılan 3 Kategori",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _enCokHarcamaSatiri(
                    Icons.receipt_long,
                    Colors.blue,
                    "Fatura",
                    "₺3.200",
                    0.9,
                  ),
                  _enCokHarcamaSatiri(
                    Icons.apple,
                    Colors.green,
                    "Gıda",
                    "₺2.450",
                    0.65,
                  ),
                  _enCokHarcamaSatiri(
                    Icons.shopping_bag,
                    Colors.blueAccent,
                    "Alışveriş",
                    "₺1.850",
                    0.45,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _pastaGosterge(Color renk, String baslik, String yuzde) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: renk, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            baslik,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
          const Spacer(),
          Text(
            yuzde,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _trendEfsane(Color renk, String baslik) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 3,
          decoration: BoxDecoration(
            color: renk,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          baslik,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _enCokHarcamaSatiri(
    IconData ikon,
    Color renk,
    String baslik,
    String tutar,
    double ilerleme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: renk.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(ikon, color: renk, size: 20),
          ),
          const SizedBox(width: 14),
          Text(
            baslik,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ilerleme,
                minHeight: 6,
                backgroundColor: Colors.grey.shade100,
                valueColor: AlwaysStoppedAnimation<Color>(renk),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Text(
            tutar,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
