import 'package:flutter/material.dart';

class ButceScreen extends StatelessWidget {
  const ButceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            const Text(
              'Aylık Bütçem',
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
            icon: const Icon(Icons.more_horiz, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0C4D3E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    "Bütçe Ekle",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
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
                      _ozetMetinGrup("Toplam Bütçe", "₺20.000"),
                      _ozetMetinGrup("Harcanan", "₺13.940"),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: 0.69,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade100,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.green,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "%69 kullanıldı",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // KATEGORİ LİSTESİ (YENİ REHBERE GÖRE GÜNCELLENDİ)
            _butceSatiri(
              Icons.receipt_long,
              Colors.blue,
              "Fatura",
              "₺3.200",
              "₺4.000",
              0.80,
              "%80",
            ),
            _butceSatiri(
              Icons.apple,
              Colors.green,
              "Gıda",
              "₺2.450",
              "₺3.500",
              0.70,
              "%70",
            ),
            _butceSatiri(
              Icons.sports_esports,
              Colors.purple,
              "Eğlence",
              "₺1.120",
              "₺2.000",
              0.56,
              "%56",
            ),
            _butceSatiri(
              Icons.directions_car,
              Colors.orange,
              "Ulaşım",
              "₺980",
              "₺1.500",
              0.65,
              "%65",
            ),
            _butceSatiri(
              Icons.shopping_bag,
              Colors.blueAccent,
              "Alışveriş",
              "₺1.850",
              "₺2.500",
              0.74,
              "%74",
            ),
            _butceSatiri(
              Icons.more_horiz,
              Colors.grey,
              "Diğer",
              "₺2.340",
              "₺2.500",
              0.94,
              "%94",
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _ozetMetinGrup(String baslik, String miktar) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          baslik,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 4),
        Text(
          miktar,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _butceSatiri(
    IconData ikon,
    Color renk,
    String baslik,
    String harcanan,
    String limit,
    double ilerlemeOrani,
    String yuzde,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: renk.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(ikon, color: renk, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      baslik,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      "$harcanan / $limit",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: ilerlemeOrani,
                          minHeight: 6,
                          backgroundColor: Colors.grey.shade100,
                          valueColor: AlwaysStoppedAnimation<Color>(renk),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      yuzde,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
