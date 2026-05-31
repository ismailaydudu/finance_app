import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'hedef_ekle_screen.dart';
import '../services/hedef_service.dart'; // Backend modelimiz ve servisimiz

class TasarrufHedeflerimScreen extends StatefulWidget {
  const TasarrufHedeflerimScreen({super.key});

  @override
  State<TasarrufHedeflerimScreen> createState() =>
      _TasarrufHedeflerimScreenState();
}

class _TasarrufHedeflerimScreenState extends State<TasarrufHedeflerimScreen> {
  late Future<List<TasarrufHedefi>> _hedeflerFuture;
  final formatPara = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '₺',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _yenile(); // Sayfa açıldığında verileri çek
  }

  void _yenile() {
    setState(() {
      _hedeflerFuture = HedefService.hedefleriGetir();
    });
  }

  // Backend'den gelen HEX renk kodunu Flutter Color nesnesine çevirir
  Color _renkDonustur(String hexLink) {
    String temizHex = hexLink.replaceFirst('#', '');
    if (temizHex.length == 6) temizHex = 'FF$temizHex';
    // Eğer backend'den geçersiz bir renk gelirse varsayılan mavi yap
    try {
      return Color(int.parse(temizHex, radix: 16));
    } catch (e) {
      return const Color(0xFF3B82F6);
    }
  }

  // Backend'de "gorselYolu" olarak tuttuğumuz kategori ismini İkona çevirir
  IconData _kategoriIkonuBul(String kategori) {
    switch (kategori) {
      case 'Alışveriş':
        return Icons.shopping_cart_rounded;
      case 'Teknoloji':
        return Icons.laptop_mac_rounded;
      case 'Tatil':
        return Icons.flight_takeoff_rounded;
      case 'Eğitim':
        return Icons.school_rounded;
      case 'Araç':
        return Icons.directions_car_rounded;
      default:
        return Icons.savings_rounded; // Varsayılan
    }
  }

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
              onTap: () async {
                // YENİ HEDEF EKLEME SAYFASINA GİDİŞ
                final sonuc = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HedefEkleScreen(),
                  ),
                );

                // Eğer sayfadan "true" döndüyse (başarıyla kaydedildiyse) listeyi yenile
                if (sonuc == true) {
                  _yenile();
                }
              },
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

      // PREMIUM GÖVDE TASARIMI - FUTURE BUILDER İLE DİNAMİK VERİ ÇEKİMİ
      body: FutureBuilder<List<TasarrufHedefi>>(
        future: _hedeflerFuture,
        builder: (context, snapshot) {
          // Yükleniyorsa dönen çember göster
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF3B82F6)),
            );
          }
          // Hata varsa mesaj göster
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Hata oluştu: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final aktifHedefler = snapshot.data ?? [];

          // Alt taraftaki mavi kart için matematiksel toplamlar
          double toplamBiriken = aktifHedefler.fold(
            0,
            (sum, item) => sum + item.birikenTutar,
          );
          double toplamHedef = aktifHedefler.fold(
            0,
            (sum, item) => sum + item.hedefTutar,
          );
          double genelYuzde =
              toplamHedef > 0
                  ? (toplamBiriken / toplamHedef).clamp(0.0, 1.0)
                  : 0.0;

          return Column(
            children: [
              // 1. KISIM: KAYDIRILABİLİR HEDEF KARTLARI LİSTESİ
              Expanded(
                child: RefreshIndicator(
                  color: const Color(0xFF3B82F6),
                  onRefresh:
                      () async =>
                          _yenile(), // Aşağı kaydırarak yenileme özelliği
                  child:
                      aktifHedefler.isEmpty
                          ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(height: 100),
                              Center(
                                child: Text(
                                  "Henüz bir hedefiniz yok.\nSağ üstteki + butonundan ekleyebilirsiniz.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          )
                          : ListView.builder(
                            physics: const BouncingScrollPhysics(
                              parent: AlwaysScrollableScrollPhysics(),
                            ),
                            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                            itemCount: aktifHedefler.length,
                            itemBuilder: (context, index) {
                              var hedef = aktifHedefler[index];
                              Color anaRenk = _renkDonustur(hedef.renkKodu);
                              IconData ikon = _kategoriIkonuBul(
                                hedef.gorselYolu,
                              );

                              return _premiumHedefKarti(
                                ikon: ikon,
                                ikonRenk: anaRenk,
                                arkaPlanRenk: anaRenk.withOpacity(
                                  0.12,
                                ), // Rengin çok saydam hali arka plan olur
                                baslik: hedef.baslik,
                                mevcutTutar: formatPara.format(
                                  hedef.birikenTutar,
                                ),
                                hedefTutar: formatPara.format(hedef.hedefTutar),
                                ilerlemeOrani: hedef.ilerlemeOrani,
                                yuzdeYazisi:
                                    "%${(hedef.ilerlemeOrani * 100).toInt()}",
                              );
                            },
                          ),
                ),
              ),

              // 2. KISIM: BOTTOM DOCK - DEGRADE GEÇİŞLİ TOPLAM BİRİKİM KARTI
              _toplamBirikimKarti(toplamBiriken, genelYuzde),
            ],
          );
        },
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
                            ikonRenk.value == const Color(0xFF3B82F6).value
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

  // ALTT KISIMDAKİ MAVİ DEGRADE KART
  Widget _toplamBirikimKarti(double toplamBiriken, double genelYuzde) {
    int yuzdeTamSayi = (genelYuzde * 100).toInt();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            // Derin Gece Mavisi ve Kraliyet Mavisi geçişi
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
                        Text(
                          formatPara.format(toplamBiriken), // DİNAMİK TUTAR
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    // Çok Estetik Katmanlı İkon Grubu
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
                          "%$yuzdeTamSayi", // DİNAMİK YÜZDE YAZISI
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
                        value: genelYuzde, // DİNAMİK YÜZDE BARI
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
    );
  }
}
