import 'package:flutter/material.dart';

class DovizScreen extends StatefulWidget {
  const DovizScreen({super.key});

  @override
  State<DovizScreen> createState() => _DovizScreenState();
}

class _DovizScreenState extends State<DovizScreen> {
  // Hesaplayıcı için durum takip değişkenleri
  final TextEditingController _tutarController = TextEditingController(
    text: "1.000",
  );
  // Doğru değişken isimleri (Sonları 'i' ile bitiyor)
  String _kaynakParaBirimi = "USD";
  String _hedefParaBirimi = "TRY";
  String _hesaplananSonuc = "32.460,00";

  // Hızlı dönüşüm butonları takip indeksi
  int _seciliHizliDonusumIndex = 0;

  @override
  void dispose() {
    _tutarController.dispose();
    super.dispose();
  }

  // Hesaplama fonksiyonu (Temsili dinamik çalışma)
  void _hesapla() {
    double? girilenTutar = double.tryParse(
      _tutarController.text.replaceAll('.', '').replaceAll(',', '.'),
    );
    if (girilenTutar != null) {
      setState(() {
        // 1 USD = 32.46 TRY sabit kuru üzerinden hesaplama simülasyonu
        double sonuc = girilenTutar * 32.46;
        _hesaplananSonuc = sonuc.toStringAsFixed(2).replaceAll('.', ',');
      });
    }
  }

  // İki para birimini yer değiştirme fonksiyonu
  // 1. Fonksiyon ismindeki 'ı' ve 'ş' harflerini 'i' ve 's' yaptık
  void _paraBirimleriniKaristir() {
    setState(() {
      // 2. Değişken isimlerinin sonundaki 'ı' harflerini 'i' yapmayı unutma
      String temp = _kaynakParaBirimi;
      _kaynakParaBirimi = _hedefParaBirimi;
      _hedefParaBirimi = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      // 1. ÜST BAR (AppBar - Görseldeki Bildirim Rozetiyle Birlikte)
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black87,
            size: 18,
          ),
          onPressed:
              () => Navigator.pop(context), // Doğrudan home screene uçurur
        ),
        title: const Text(
          'Kur Hesaplayıcı',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          // Sağ üstteki kırmızı bildirim rozetli buton
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_none_outlined,
                  color: Colors.black87,
                  size: 26,
                ),
                onPressed: () {},
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
        ],
      ),

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // 2. SON GÜNCELLEME KARTI
            // 2. SON GÜNCELLEME KARTI
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.01),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Son Güncelleme",
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade400,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "20 Mayıs 2024  •  09:41",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    // İŞTE BURASI: children: [ eksik olduğu için hata veriyordu
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 30, 203, 117),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        "Anlık Veriler",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 3. ANLIK KURLAR BÖLÜMÜ
            const Text(
              "Anlık Kurlar",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.01),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _canliKurSatiri(
                    "🇺🇸",
                    "USD",
                    "Amerikan Doları",
                    "32,46",
                    "32,40",
                    "32,52",
                    "%0,25",
                    true,
                  ),
                  _canliKurSatiri(
                    "🇪🇺",
                    "EUR",
                    "Euro",
                    "35,12",
                    "35,04",
                    "35,20",
                    "%0,32",
                    true,
                  ),
                  _canliKurSatiri(
                    "🇬🇧",
                    "GBP",
                    "İngiliz Sterlini",
                    "41,25",
                    "41,10",
                    "41,40",
                    "%0,18",
                    true,
                  ),
                  _canliKurSatiri(
                    "🟡",
                    "XAU",
                    "Gram Altın",
                    "2.415,30",
                    "2.410,20",
                    "2.420,40",
                    "%0,41",
                    true,
                  ),
                  _canliKurSatiri(
                    "🇸🇦",
                    "SAR",
                    "Suudi Arabistan Riyali",
                    "8,65",
                    "8,63",
                    "8,67",
                    "%0,07",
                    false,
                    sonElemanMi: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 4. KUR HESAPLAMA BÖLÜMÜ
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.01),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
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
                        "Kur Hesapla",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.refresh,
                          color: Colors.black54,
                          size: 22,
                        ),
                        onPressed:
                            () =>
                                setState(() => _tutarController.text = "1.000"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Column(
                        children: [
                          // Giriş Kutusu (Tutar)
                          _hesaplamaGirisAlani(
                            etiket: "Tutar",
                            controller: _tutarController,
                            paraBirimi: _kaynakParaBirimi,
                            bayrak:
                                _kaynakParaBirimi == "USD" ? "🇺🇸" : "🇹🇷",
                          ),
                          const SizedBox(height: 12),
                          // Çıkış Kutusu (Karşılık Gelen Tutar)
                          _hesaplamaGirisAlani(
                            etiket: "Karşılık Gelen Tutar",
                            okumaModu: true,
                            deger: _hesaplananSonuc,
                            paraBirimi: _hedefParaBirimi,
                            bayrak: _hedefParaBirimi == "TRY" ? "🇹🇷" : "🇺🇸",
                          ),
                        ],
                      ),
                      // Ortadaki Yuvarlak Karıştırma/Swap Butonu
                      GestureDetector(
                        onTap: _paraBirimleriniKaristir,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F7FA),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: const Icon(
                            Icons.swap_vert_rounded,
                            color: Colors.black87,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Bilgi Satırı
                  const Text(
                    "1 USD = 32,46 TRY",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black45,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Hesapla Butonu
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _hesapla,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0C4D3E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Hesapla",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 5. HIZLI DÖNÜŞÜMLER BÖLÜMÜ
            const Text(
              "Hızlı Dönüşümler",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _hizliDonusumButonu("USD → TRY", 0),
                _hizliDonusumButonu("EUR → TRY", 1),
                _hizliDonusumButonu("GBP → TRY", 2),
                _hizliDonusumButonu("ALTIN → TRY", 3),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Canlı kur listesindeki her bir satır için şablon widget
  Widget _canliKurSatiri(
    String bayrak,
    String kod,
    String isim,
    String anaDeger,
    String alis,
    String satis,
    String yuzde,
    bool yukselisMi, {
    bool sonElemanMi = false,
  }) {
    Color trendRenk =
        yukselisMi ? const Color(0xFF10B981) : const Color(0xFFEF4444);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              // Sol Kısım: Bayrak ve İsim Grubu
              Text(bayrak, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    kod,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isim,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade400,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const Spacer(),

              // Orta Kısım: Alış/Satış Detayları ve Ana Fiyat
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    anaDeger,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Alış: $alis  •  Satış: $satis",
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade400,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),

              // Sağ Kısım: Yüzdelik Hap Göstergesi ve Ok
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: trendRenk.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      yukselisMi ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                      color: trendRenk,
                      size: 16,
                    ),
                    Text(
                      yuzde,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: trendRenk,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios,
                size: 12,
                color: Colors.grey.shade300,
              ),
            ],
          ),
        ),
        if (!sonElemanMi)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(color: Colors.grey.shade100, height: 1),
          ),
      ],
    );
  }

  // Hesaplayıcı içindeki giriş/çıkış textfield kart mimarisi
  Widget _hesaplamaGirisAlani({
    required String etiket,
    TextEditingController? controller,
    bool okumaModu = false,
    String? deger,
    required String paraBirimi,
    required String bayrak,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            etiket,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w600,
            ),
          ),
          Row(
            children: [
              Expanded(
                child:
                    okumaModu
                        ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 13.0),
                          child: Text(
                            deger ?? "0,00",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        )
                        : TextField(
                          controller: controller,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
              ),
              // Para Birimi Seçim Kapsülü (Açılır menü görünümlü)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Text(bayrak, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      paraBirimi,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      size: 14,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // En alttaki hızlı dönüşüm buton şablonu
  Widget _hizliDonusumButonu(String baslik, int index) {
    bool seciliMi = _seciliHizliDonusumIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _seciliHizliDonusumIndex = index;
          if (index == 0) {
            _kaynakParaBirimi = "USD";
            _hedefParaBirimi = "TRY";
          }
          _hesapla();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: seciliMi ? const Color(0xFF0C4D3E) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: seciliMi ? Colors.transparent : Colors.grey.shade200,
          ),
        ),
        child: Text(
          baslik,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: seciliMi ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}
