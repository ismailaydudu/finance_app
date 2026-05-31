import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/profile_state.dart';
import '../widgets/hizli_islemler.dart';
import '../widgets/son_islemler.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _profilResmiSec() async {
    try {
      final XFile? resim = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (resim != null) ProfileState.resimNotifier.value = File(resim.path);
    } catch (e) { debugPrint("Hata: $e"); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: FutureBuilder<List<dynamic>>(
          future: ApiService.islemleriGetir(),
          builder: (context, snapshot) {
            double gelir = 0;
            double gider = 0;
            if (snapshot.hasData) {
              for (var i in snapshot.data!) {
                double tutar = double.tryParse(i['tutar'].toString()) ?? 0.0;
                if (i['islemTipi'].toString().toUpperCase() == 'GELIR') gelir += tutar;
                else gider += tutar;
              }
            }
            double bakiye = gelir - gider;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _profilAlani(),
                  const SizedBox(height: 24),
                  
                  // --- ORİJİNAL GRAFİK VE KART TASARIMI ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Aylık Özet", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                            Text("Mayıs 2026", style: TextStyle(fontSize: 13, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: SizedBox(
                            width: 210, height: 210,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                PieChart(PieChartData(
                                  sectionsSpace: 5, centerSpaceRadius: 82,
                                  sections: [
                                    PieChartSectionData(color: const Color(0xFF10B981), value: gelir > 0 ? gelir : 1, radius: 12, showTitle: false),
                                    PieChartSectionData(color: const Color(0xFFEF4444), value: gider > 0 ? gider : 1, radius: 12, showTitle: false),
                                  ],
                                )),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text("Toplam Bakiye", style: TextStyle(fontSize: 12, color: Colors.black38, fontWeight: FontWeight.w600)),
                                    Text("₺${bakiye.toStringAsFixed(2)}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                                    const SizedBox(height: 6),
                                    const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.trending_up_rounded, color: Color(0xFF10B981), size: 14),
                                        Text(" %12 artış", style: TextStyle(fontSize: 12, color: Color(0xFF10B981), fontWeight: FontWeight.w800)),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _orijinalOzetKarti(Icons.arrow_upward_rounded, const Color(0xFF10B981), "Gelir", "₺${gelir.toStringAsFixed(0)}"),
                            _orijinalOzetKarti(Icons.arrow_downward_rounded, const Color(0xFFEF4444), "Gider", "₺${gider.toStringAsFixed(0)}"),
                            _orijinalOzetKarti(Icons.savings_outlined, const Color(0xFF3B82F6), "Tasarruf", "₺${bakiye.toStringAsFixed(0)}"),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const HizliIslemler(),
                  const SizedBox(height: 24),
                  const SonIslemler(),
                  const SizedBox(height: 100),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _profilAlani() {
    return Row(
      children: [
        GestureDetector(
          onTap: _profilResmiSec,
          child: ValueListenableBuilder<File?>(
            valueListenable: ProfileState.resimNotifier,
            builder: (context, resim, _) => CircleAvatar(
              radius: 26,
              backgroundImage: resim != null ? FileImage(resim) : const NetworkImage('https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150') as ImageProvider,
            ),
          ),
        ),
        const SizedBox(width: 14),
        ValueListenableBuilder<String>(
          valueListenable: ProfileState.isimNotifier,
          builder: (context, isim, _) => Text("Merhaba, $isim 👋", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _orijinalOzetKarti(IconData ikon, Color renk, String baslik, String tutar) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE2E8F0).withOpacity(0.7))),
        child: Column(
          children: [
            Icon(ikon, color: renk, size: 20),
            const SizedBox(height: 8),
            Text(baslik, style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(tutar, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
          ],
        ),
      ),
    );
  }
}