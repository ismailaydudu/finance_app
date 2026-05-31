import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/profile_state.dart';
import '../widgets/hizli_islemler.dart';
import '../widgets/son_islemler.dart';
import '../services/api_service.dart';

// Yönlendirmeler için gerekli ekranların importları
import 'raporlar_screen.dart';
import 'tasarruf_hedeflerim_screen.dart';
import 'profil_screen.dart'; // PROFİL SAYFASI İÇİN EKLENDİ

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 2026 Ayları için Dropdown state değişkeni
  String _seciliAy = "Mayıs 2026";
  final List<String> _aylar = [
    "Ocak 2026",
    "Şubat 2026",
    "Mart 2026",
    "Nisan 2026",
    "Mayıs 2026",
    "Haziran 2026",
    "Temmuz 2026",
    "Ağustos 2026",
    "Eylül 2026",
    "Ekim 2026",
    "Kasım 2026",
    "Aralık 2026",
  ];

  // EFSANEVİ VE ŞIK AY SEÇİCİ EKRANI (BOTTOM SHEET)
  void _aySeciciyiAc() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: 400,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Ay Seçin",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
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
                          fontWeight:
                              seciliMi ? FontWeight.bold : FontWeight.normal,
                          color:
                              seciliMi
                                  ? const Color(0xFF0C4D3E)
                                  : Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      tileColor:
                          seciliMi
                              ? const Color(0xFF0C4D3E).withAlpha(15)
                              : Colors.transparent,
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
      body: SafeArea(
        child: FutureBuilder<List<dynamic>>(
          future: ApiService.islemleriGetir(),
          builder: (context, snapshot) {
            double gelir = 0;
            double gider = 0;
            if (snapshot.hasData) {
              for (var i in snapshot.data!) {
                double tutar = double.tryParse(i['tutar'].toString()) ?? 0.0;
                if (i['islemTipi'].toString().toUpperCase() == 'GELIR')
                  gelir += tutar;
                else
                  gider += tutar;
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
                  _profilAlani(), // PROFİL ALANI BURADA ÇAĞRILIYOR
                  const SizedBox(height: 24),

                  // --- AYLIK ÖZET KARTI ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Aylık Özet",
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 4),

                                // ŞIK VE MİNİMAL AY SEÇİCİ BUTONU
                                GestureDetector(
                                  onTap: _aySeciciyiAc,
                                  child: Row(
                                    children: [
                                      Text(
                                        _seciliAy,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade600,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        size: 16,
                                        color: Colors.grey.shade600,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => const RaporlarScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                child: const Icon(
                                  Icons.grid_view_rounded,
                                  color: Colors.black54,
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: SizedBox(
                            width: 210,
                            height: 210,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                PieChart(
                                  PieChartData(
                                    sectionsSpace: 5,
                                    centerSpaceRadius: 82,
                                    sections: [
                                      PieChartSectionData(
                                        color: const Color(0xFF10B981),
                                        value: gelir > 0 ? gelir : 1,
                                        radius: 12,
                                        showTitle: false,
                                      ),
                                      PieChartSectionData(
                                        color: const Color(0xFFEF4444),
                                        value: gider > 0 ? gider : 1,
                                        radius: 12,
                                        showTitle: false,
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "Toplam Bakiye",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black38,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      "₺${bakiye.toStringAsFixed(2)}",
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.trending_up_rounded,
                                          color: Color(0xFF10B981),
                                          size: 14,
                                        ),
                                        Text(
                                          " %12 artış",
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _orijinalOzetKarti(
                              Icons.arrow_upward_rounded,
                              const Color(0xFF10B981),
                              "Gelir",
                              "₺${gelir.toStringAsFixed(0)}",
                            ),
                            _orijinalOzetKarti(
                              Icons.arrow_downward_rounded,
                              const Color(0xFFEF4444),
                              "Gider",
                              "₺${gider.toStringAsFixed(0)}",
                            ),
                            _orijinalOzetKarti(
                              Icons.savings_outlined,
                              const Color(0xFF3B82F6),
                              "Tasarruf",
                              "₺${bakiye.toStringAsFixed(0)}",
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            const TasarrufHedeflerimScreen(),
                                  ),
                                );
                              },
                            ),
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
        // FOTOĞRAFA TIKLAYINCA PROFİLE GİTME İŞLEMİ
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfilScreen()),
            );
          },
          child: ValueListenableBuilder<File?>(
            valueListenable: ProfileState.resimNotifier,
            builder:
                (context, resim, _) => CircleAvatar(
                  radius: 26,
                  backgroundImage:
                      resim != null
                          ? FileImage(resim)
                          : const NetworkImage(
                                'https://i1.rgstatic.net/ii/profile.image/11431281796811820-1765961137549_Q512/Emir-Oeztuerk.jpg',
                              )
                              as ImageProvider,
                ),
          ),
        ),
        const SizedBox(width: 14),
        // YENİ SLOGANLI YAZI ALANI
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ValueListenableBuilder<String>(
              valueListenable: ProfileState.isimNotifier,
              builder:
                  (context, isim, _) => Text(
                    "Merhaba, $isim 👋",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              "Finansını kontrol et, geleceğini yönet.",
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _orijinalOzetKarti(
    IconData ikon,
    Color renk,
    String baslik,
    String tutar, {
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0).withOpacity(0.7)),
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
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
