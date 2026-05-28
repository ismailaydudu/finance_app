import 'package:flutter/material.dart';

class TasarrufHedeflerimScreen extends StatelessWidget {
  const TasarrufHedeflerimScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Modern ve lüks uygulamaların tercih ettiği özel slate arka planı
      backgroundColor: const Color(0xFFF8FAFC),

      // SIFIR KUSUR APPBAR
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF0F172A),
            size: 18,
          ),
          onPressed:
              () => Navigator.pop(context), // Pürüzsüzce home screene döner
        ),
        title: const Text(
          'Tasarruf Hedeflerim',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
            fontSize: 19,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {},
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: Color(0xFF0F172A),
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),

      // PREMIUM GÖVDE TASARIMI
      body: Column(
        children: [
          // 1. KISIM: KAYDIRILABİLİR HEDEF KARTLARI LİSTESİ
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                children: [
                  _premiumHedefKarti(
                    ikon: Icons.beach_access_rounded,
                    ikonRenk: const Color(0xFFF59E0B), // Canlı Amber
                    arkaPlanRenk: const Color(0xFFFEF3C7),
                    baslik: "Tatil",
                    mevcutTutar: "₺12.000",
                    hedefTutar: "₺20.000",
                    ilerlemeOrani: 0.60,
                    yuzdeYazisi: "%60",
                  ),
                  _premiumHedefKarti(
                    ikon: Icons.laptop_mac_rounded,
                    ikonRenk: const Color(0xFF3B82F6), // Canlı Mavi
                    arkaPlanRenk: const Color(0xFFDBEAFE),
                    baslik: "Yeni Laptop",
                    mevcutTutar: "₺8.500",
                    hedefTutar: "₺15.000",
                    ilerlemeOrani: 0.57,
                    yuzdeYazisi: "%57",
                  ),
                  _premiumHedefKarti(
                    ikon: Icons.shield_rounded,
                    ikonRenk: const Color(0xFF10B981), // Canlı Zümrüt Yeşili
                    arkaPlanRenk: const Color(0xFFD1FAE5),
                    baslik: "Acil Durum Fonu",
                    mevcutTutar: "₺5.000",
                    hedefTutar: "₺10.000",
                    ilerlemeOrani: 0.50,
                    yuzdeYazisi: "%50",
                  ),
                ],
              ),
            ),
          ),

          // 2. KISIM: BOTTOM DOCK - DEGRADE GEÇİŞLİ TOPLAM BİRİKİM KARTI
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  // Derin Gece Mavisi ve Kraliyet Mavisi geçişi (Görselin en asil hali)
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withOpacity(0.2),
                      blurRadius: 25,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Degrade Kısmın İçeriği
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Toplam Birikim",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.75),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                "₺25.500",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                          // İllüstrasyon Yerine Çok Estetik Katmanlı İkon Grubu
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.12),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Icon(
                                Icons.widgets_rounded,
                                color: Colors.amber.shade400,
                                size: 24,
                              ),
                              Transform.translate(
                                offset: const Offset(-8, -12),
                                child: const Icon(
                                  Icons.spa,
                                  color: Color(0xFF34D399),
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Beyaz Alt Panel Kapsülü
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(28),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Hedeflere ulaşma oranı",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              Text(
                                "%55",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Premium Kalın İlerleme Çubuğu
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: 0.55,
                              minHeight: 8,
                              backgroundColor: const Color(0xFFF1F5F9),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF10B981),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // YENİ NESİL PREMIUM HEDEF KARTI ŞABLONU
  Widget _premiumHedefKarti({
    required IconData ikon,
    required Color ikonRenk,
    required Color arkaPlanRenk,
    required String baslik,
    required String mevcutTutar,
    required String hedefTutar,
    required double ilerlemeOrani,
    required String yuzdeYazisi,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        // Yumuşatılmış pürüzsüz gölge haritası
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E293B).withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Sol Kısım: Estetik Köşeli Yuvarlak İkon Kutusu
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: arkaPlanRenk,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(ikon, color: ikonRenk, size: 26),
          ),
          const SizedBox(width: 16),

          // Orta ve Sağ İçerik Grubu
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Başlık Alanı
                Text(
                  baslik,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),

                // Tutar Kıyaslama Alanı
                Row(
                  children: [
                    Text(
                      mevcutTutar,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      " / $hedefTutar",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // İlerleme Barı ve Yüzde Yan Yana
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: ilerlemeOrani,
                          minHeight: 6,
                          backgroundColor: const Color(0xFFF1F5F9),
                          // Eğer mavi kartsa yeşil çiz, diğerlerinde kendi rengini koru (Görsel detayı)
                          valueColor: AlwaysStoppedAnimation<Color>(
                            ikonRenk == const Color(0xFF3B82F6)
                                ? const Color(0xFF10B981)
                                : ikonRenk,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      yuzdeYazisi,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF10B981),
                        letterSpacing: -0.2,
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
