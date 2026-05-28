import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fl_chart/fl_chart.dart'; // Grafik paketi
import '../utils/profile_state.dart';
import '../widgets/hizli_islemler.dart';
import '../widgets/son_islemler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _profilResmiSec() async {
    try {
      final XFile? resim = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (resim != null) {
        ProfileState.resimNotifier.value = File(resim.path);
      }
    } catch (e) {
      debugPrint("Resim secilirken hata olustu: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // 1. BÖLÜM: ÜST PROFIL VE HOŞ GELDİNİZ ALANI (DİNLEYİCİLİ)
              Row(
                children: [
                  GestureDetector(
                    onTap: _profilResmiSec,
                    child: ValueListenableBuilder<File?>(
                      valueListenable: ProfileState.resimNotifier,
                      builder: (context, mevcutResim, child) {
                        return Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 26,
                            backgroundColor: Colors.grey.shade300,
                            backgroundImage:
                                mevcutResim != null
                                    ? FileImage(mevcutResim) as ImageProvider
                                    : const NetworkImage(
                                      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
                                    ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ValueListenableBuilder<String>(
                            valueListenable: ProfileState.isimNotifier,
                            builder: (context, mevcutIsim, child) {
                              return Text(
                                "Merhaba, $mevcutIsim",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 4),
                          const Text("👋", style: TextStyle(fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        "Finansını kontrol et, geleceğini yönet.",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.notifications_none_rounded,
                        color: Colors.black87,
                      ),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 2. BÖLÜM: GERÇEK BOYUTLARINDAKİ AYLIK ÖZET KARTI
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(
                  24,
                ), // İç boşluğu genişleterek ferahlattık
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Başlık Alanı
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Aylık Özet",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              "Mayıs 2026",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 18,
                              color: Colors.grey.shade500,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // BÜYÜTÜLMÜŞ ORİJİNAL HALKA GRAFİK (Orijinal Ölçüler)
                    Center(
                      child: SizedBox(
                        width:
                            210, // Çapı 210'a çıkararak eski heybetine kavuşturduk
                        height: 210,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            PieChart(
                              PieChartData(
                                sectionsSpace: 5,
                                centerSpaceRadius:
                                    82, // İç beyaz boşluğu genişlettik
                                startDegreeOffset: -90,
                                sections: [
                                  PieChartSectionData(
                                    color: const Color(0xFF10B981),
                                    value: 50,
                                    radius: 12,
                                    showTitle: false,
                                  ), // Yeşil
                                  PieChartSectionData(
                                    color: const Color(0xFFF59E0B),
                                    value: 12,
                                    radius: 12,
                                    showTitle: false,
                                  ), // Turuncu
                                  PieChartSectionData(
                                    color: const Color(0xFF3B82F6),
                                    value: 23,
                                    radius: 12,
                                    showTitle: false,
                                  ), // Mavi
                                  PieChartSectionData(
                                    color: const Color(0xFFEF4444),
                                    value: 15,
                                    radius: 12,
                                    showTitle: false,
                                  ), // Kırmızı
                                ],
                              ),
                            ),
                            // Halkanın Tam Ortasındaki Büyük Yazılar
                            const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Toplam Bakiye",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black38,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  "₺24.560,00",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF0F172A),
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.trending_up_rounded,
                                      color: Color(0xFF10B981),
                                      size: 14,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      "%12 artış",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF10B981),
                                        fontWeight: FontWeight.w800,
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
                    const SizedBox(height: 28),

                    // GRAFİK ALTINDAKİ BEYAZ VE GENİŞ ÖZET KARTLARI
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _orijinalOzetKarti(
                          Icons.arrow_upward_rounded,
                          const Color(0xFF10B981),
                          "Gelir",
                          "₺38.500",
                        ),
                        _orijinalOzetKarti(
                          Icons.arrow_downward_rounded,
                          const Color(0xFFEF4444),
                          "Gider",
                          "₺13.940",
                        ),
                        _orijinalOzetKarti(
                          Icons.savings_outlined,
                          const Color(0xFF3B82F6),
                          "Tasarruf",
                          "₺24.560",
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 3. BÖLÜM: HIZLI İŞLEMLER WIDGETI
              const HizliIslemler(),

              const SizedBox(height: 24),

              // 4. BÖLÜM: SON İŞLEMLER WIDGETI
              const SonIslemler(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  // İlk tasarımındaki o büyük beyaz, temiz kutu mimarisi
  Widget _orijinalOzetKarti(
    IconData ikon,
    Color renk,
    String baslik,
    String tutar,
  ) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white, // Tamamen beyaz ve temiz arka plan
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0).withOpacity(0.7)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.005),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(ikon, color: renk, size: 20),
            const SizedBox(height: 8),
            Text(
              baslik,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              tutar,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
