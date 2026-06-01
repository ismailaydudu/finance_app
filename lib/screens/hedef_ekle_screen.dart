import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert'; // jsonEncode için lazım
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

  final Map<String, Map<String, dynamic>> _kategoriler = {
    'Alışveriş': {
      'ikon': Icons.shopping_cart_rounded,
      'renk': const Color(0xFFC084FC),
    },
    'Teknoloji': {
      'ikon': Icons.laptop_mac_rounded,
      'renk': const Color(0xFF3B82F6),
    },
    'Tatil': {
      'ikon': Icons.flight_takeoff_rounded,
      'renk': const Color(0xFFF59E0B),
    },
    'Eğitim': {'ikon': Icons.school_rounded, 'renk': const Color(0xFF10B981)},
    'Araç': {
      'ikon': Icons.directions_car_rounded,
      'renk': const Color(0xFFEF4444),
    },
  };

  @override
  void initState() {
    super.initState();
    _tutarController.addListener(() => setState(() {}));
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
    );
    if (secilen != null) setState(() => _secilenTarih = secilen);
  }

  int _ayFarkiHesapla() {
    if (_secilenTarih == null) return 1;
    int aylar =
        (_secilenTarih!.year - DateTime.now().year) * 12 +
        _secilenTarih!.month -
        DateTime.now().month;
    return aylar > 0 ? aylar : 1;
  }

  void _kaydet() async {
    // Tutar formatlama (Nokta/Virgül karmaşasını çözüyoruz)
    double tutar =
        double.tryParse(
          _tutarController.text.replaceAll('.', '').replaceAll(',', '.'),
        ) ??
        0.0;

    if (_baslikController.text.isEmpty || tutar <= 0 || _secilenTarih == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Lütfen tutar, başlık ve tarih bilgilerini doldurun kanka.",
          ),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    // Kategori rengini hex'e çevir
    Color kategoriRengi = _kategoriler[_secilenKategori]!['renk'];
    String hexRenk =
        '#${kategoriRengi.value.toRadixString(16).substring(2).toUpperCase()}';

    // DİKKAT: Backend'e gönderilecek JSON paketini burada elle oluşturuyoruz (En garantisi bu)
    final Map<String, dynamic> hedefVerisi = {
      "baslik": _baslikController.text,
      "hedefTutar": tutar,
      "birikenTutar": 0.0,
      // Tarihi Java'nın sevdiği formatta (yyyy-MM-dd) gönderiyoruz:
      "sonTarih": DateFormat('yyyy-MM-dd').format(_secilenTarih!),
      "gorselYolu": _secilenKategori,
      "renkKodu": hexRenk,
    };

    // HedefService'e artık direkt map gönderiyoruz ki modeldeki hatalardan kaçalım
    bool basarili = await HedefService.hedefEkleRaw(hedefVerisi);

    setState(() => _isSaving = false);

    if (basarili) {
      if (mounted) Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Backend hatası: Iso server'ı mı kapattı n'aptı?"),
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
    double aylikTutar = toplamTutar / _ayFarkiHesapla();
    final formatter = NumberFormat('#,##0', 'tr_TR');

    return Scaffold(
      backgroundColor: const Color(0xFFEAF4F4),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Yeni Hedef Ekle',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          children: [
            _tutarGirisKarti(),
            const SizedBox(height: 16),
            _formKutusu(
              child: TextField(
                controller: _baslikController,
                decoration: const InputDecoration(
                  labelText: "Hedef Adı",
                  border: InputBorder.none,
                  hintText: "Örn: MacBook Air M3",
                ),
              ),
            ),
            const SizedBox(height: 16),
            _kategoriSecici(),
            const SizedBox(height: 16),
            _tarihSecici(),
            const SizedBox(height: 16),
            _bilgiKutusu(toplamTutar, aylikTutar, formatter),
            const SizedBox(height: 30),
            _kaydetButonu(),
          ],
        ),
      ),
    );
  }

  // YARDIMCI WIDGETLAR (MİMARİYİ KORUDUK)
  Widget _tutarGirisKarti() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF8EE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            "Hedef Tutarını Girin",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "₺ ",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              IntrinsicWidth(
                child: TextField(
                  controller: _tutarController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "0",
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _kategoriSecici() {
    return _formKutusu(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Kategori", style: TextStyle(fontWeight: FontWeight.w500)),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _secilenKategori,
              items:
                  _kategoriler.keys
                      .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                      .toList(),
              onChanged: (val) => setState(() => _secilenKategori = val!),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tarihSecici() {
    return GestureDetector(
      onTap: () => _tarihSeciciAc(context),
      child: _formKutusu(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Bitiş Tarihi",
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            Text(
              _secilenTarih == null
                  ? "Seçiniz"
                  : DateFormat('dd MMM yyyy').format(_secilenTarih!),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bilgiKutusu(double toplam, double aylik, NumberFormat f) {
    if (toplam <= 0 || _secilenTarih == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE2F1E9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        "₺${f.format(toplam)} hedefine ulaşmak için ${f.format(aylik)} ₺/ay biriktirmelisin.",
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF1B4332),
        ),
      ),
    );
  }

  Widget _kaydetButonu() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1B4332),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: _isSaving ? null : _kaydet,
        child:
            _isSaving
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                  "Hedefi Kaydet",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
      ),
    );
  }

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
