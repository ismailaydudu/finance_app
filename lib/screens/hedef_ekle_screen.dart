import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/hedef_service.dart';

class HedefEkleScreen extends StatefulWidget {
  const HedefEkleScreen({super.key});

  @override
  State<HedefEkleScreen> createState() => _HedefEkleScreenState();
}

class _HedefEkleScreenState extends State<HedefEkleScreen> {
  final _tutarController = TextEditingController();
  final _baslikController = TextEditingController();

  DateTime? _secilenTarih;
  String _secilenKategori = 'Alışveriş';
  String _secilenFrekans = 'Aylık';
  bool _isSaving = false;

  // Kategoriler ve onlara özel ikon/renk eşleştirmeleri
  final Map<String, Map<String, dynamic>> _kategoriler = {
    'Alışveriş': {
      'ikon': Icons.shopping_cart_rounded,
      'renk': const Color(0xFFC084FC),
    }, // Mor
    'Teknoloji': {
      'ikon': Icons.laptop_mac_rounded,
      'renk': const Color(0xFF3B82F6),
    }, // Mavi
    'Tatil': {
      'ikon': Icons.flight_takeoff_rounded,
      'renk': const Color(0xFFF59E0B),
    }, // Turuncu
    'Eğitim': {
      'ikon': Icons.school_rounded,
      'renk': const Color(0xFF10B981),
    }, // Yeşil
    'Araç': {
      'ikon': Icons.directions_car_rounded,
      'renk': const Color(0xFFEF4444),
    }, // Kırmızı
  };

  @override
  void initState() {
    super.initState();
    // Tutar değiştikçe alttaki hesaplamanın güncellenmesi için dinleyici ekliyoruz
    _tutarController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tutarController.dispose();
    _baslikController.dispose();
    super.dispose();
  }

  void _tarihSeciciAc(BuildContext context) async {
    final secilen = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1B4332),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );
    if (secilen != null) {
      setState(() => _secilenTarih = secilen);
    }
  }

  // --- DİNAMİK HESAPLAMA MOTORU ---
  int _ayFarkiHesapla() {
    if (_secilenTarih == null) return 1;
    int aylar =
        (_secilenTarih!.year - DateTime.now().year) * 12 +
        _secilenTarih!.month -
        DateTime.now().month;
    return aylar > 0 ? aylar : 1; // En az 1 ay
  }

  double _aylikTutarHesapla(double toplamTutar) {
    int ay = _ayFarkiHesapla();
    return toplamTutar / ay;
  }

  void _kaydet() async {
    double tutar =
        double.tryParse(
          _tutarController.text.replaceAll('.', '').replaceAll(',', '.'),
        ) ??
        0.0;

    if (_baslikController.text.isEmpty || tutar <= 0 || _secilenTarih == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lütfen tutar, başlık ve tarih bilgilerini doldurun."),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    // Kategoriye göre renk ve ikon belirliyoruz (Backend hata vermesin diye)
    Color kategoriRengi = _kategoriler[_secilenKategori]!['renk'];
    String hexRenk =
        '#${kategoriRengi.value.toRadixString(16).substring(2).toUpperCase()}';

    TasarrufHedefi yeni = TasarrufHedefi(
      baslik: _baslikController.text,
      hedefTutar: tutar,
      birikenTutar: 0.0,
      sonTarih: _secilenTarih!,
      gorselYolu: _secilenKategori, // Backend'de kategori ismini tutuyoruz
      renkKodu: hexRenk,
    );

    bool basarili = await HedefService.hedefEkle(yeni);
    setState(() => _isSaving = false);

    if (basarili) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Backend bağlantı hatası: Hedef kaydedilemedi."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double toplamTutar =
        double.tryParse(
          _tutarController.text.replaceAll('.', '').replaceAll(',', '.'),
        ) ??
        0.0;
    int hesaplananAy = _ayFarkiHesapla();
    double aylikTutar = _aylikTutarHesapla(toplamTutar);

    final formatter = NumberFormat('#,##0', 'tr_TR');
    String anlikTarihFormatli = DateFormat(
      'dd MMM, hh:mm a',
      'en_US',
    ).format(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(
        0xFFEAF4F4,
      ), // Fotoğraftaki çok açık yeşil/mavi arka plan
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Yeni Hedef Ekle',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. ÜST KART: TUTAR GİRİŞ ALANI (Krem rengi)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFFDF8EE), // Krem / açık sarı
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text(
                    "Hedef Tutarını Girin",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "₺ ",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      IntrinsicWidth(
                        child: TextField(
                          controller: _tutarController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            border: InputBorder.none,
                            hintText: "0",
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 8, bottom: 16),
                    height: 2,
                    width: 100,
                    color: Colors.grey.shade300,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        size: 14,
                        color: Color(0xFF1B4332),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Bugün, $anlikTarihFormatli",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. BAŞLIK ALANI
            _formKutusu(
              child: TextField(
                controller: _baslikController,
                style: const TextStyle(fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelText: "Hedef Adı",
                  labelStyle: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.normal,
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  hintText: "Örn: Yeni Telefon Almak",
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 3. KATEGORİ SEÇİCİ
            _formKutusu(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Kategori",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _secilenKategori,
                      icon:
                          const SizedBox.shrink(), // Kendi ikonumuzu yapacağımız için varsayılanı gizle
                      alignment: Alignment.centerRight,
                      items:
                          _kategoriler.keys.map((String kategori) {
                            return DropdownMenuItem<String>(
                              value: kategori,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _kategoriler[kategori]!['renk']
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _kategoriler[kategori]!['ikon'],
                                      size: 16,
                                      color: _kategoriler[kategori]!['renk'],
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      kategori,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null)
                          setState(() => _secilenKategori = newValue);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 4. BİTİŞ TARİHİ
            GestureDetector(
              onTap: () => _tarihSeciciAc(context),
              child: _formKutusu(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Bitiş Tarihi",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_month_rounded,
                          size: 18,
                          color: Colors.black87,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _secilenTarih == null
                              ? "Seçiniz"
                              : DateFormat(
                                'dd MMM yyyy',
                              ).format(_secilenTarih!),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 5. SIKLIK (Aylık/Haftalık)
            _formKutusu(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Sıklık",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _secilenFrekans,
                      icon: const Icon(
                        Icons.arrow_drop_down_rounded,
                        color: Colors.black87,
                      ),
                      items:
                          <String>['Aylık', 'Haftalık'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            );
                          }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null)
                          setState(() => _secilenFrekans = newValue);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 6. AYLIK BİRİKİM TUTARI (Otomatik Hesaplanır)
            _formKutusu(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "$_secilenFrekans Birikim",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(bottom: 2),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey, width: 1),
                      ),
                    ),
                    child: Text(
                      "₺ ${formatter.format(aylikTutar)}",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 7. BİLGİ KUTUSU (Yeşil)
            if (toplamTutar > 0 && _secilenTarih != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2F1E9), // Açık nane yeşili
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFCDE4DA)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: Color(0xFF1B4332),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "₺${formatter.format(toplamTutar)} hedefine ulaşmak için $hesaplananAy ay boyunca her ay ₺${formatter.format(aylikTutar)} biriktirmelisiniz.",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1B4332),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 30),

            // 8. KAYDET BUTONU
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B4332), // Koyu Orman Yeşili
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                onPressed: _isSaving ? null : _kaydet,
                child:
                    _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                          "Hedefi Kaydet",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Beyaz form kutularını oluşturan yardımcı widget
  Widget _formKutusu({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: child,
    );
  }
}
