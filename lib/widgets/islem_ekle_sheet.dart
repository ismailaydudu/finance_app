import 'package:flutter/material.dart';
import '../services/api_service.dart'; // JAVA KÖPRÜSÜNÜ BURAYA DA BAĞLADIK!

class IslemEkleSheet extends StatefulWidget {
  // Dışarıdan hangi sekmenin açık geleceğini parametre olarak alıyoruz
  final bool initialIsGelir;

  const IslemEkleSheet({
    super.key,
    this.initialIsGelir = true, // Varsayılan olarak Gelir açık gelsin
  });

  @override
  State<IslemEkleSheet> createState() => _IslemEkleSheetState();
}

class _IslemEkleSheetState extends State<IslemEkleSheet> {
  late bool _isGelir; 
  late String _secilenKategori;

  String _secilenOdemeYontemi = "Kart";
  DateTime _secilenTarih = DateTime.now();

  // KULLANICININ YAZDIKLARINI HAFIZADA TUTAN KONTROLCÜLER (SİHİR BURADA)
  final TextEditingController _tutarController = TextEditingController();
  final TextEditingController _aciklamaController = TextEditingController();

  final List<String> _aylar = [
    "Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran",
    "Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım", "Aralık",
  ];

  final List<Map<String, dynamic>> _gelirKategorileri = [
    {"baslik": "Maaş", "ikon": Icons.work, "renk": Colors.green},
    {"baslik": "Freelance", "ikon": Icons.card_travel, "renk": Colors.purple},
    {"baslik": "Yatırım", "ikon": Icons.trending_up, "renk": Colors.teal},
    {"baslik": "Diğer", "ikon": Icons.more_horiz, "renk": Colors.grey},
  ];

  final List<Map<String, dynamic>> _giderKategorileri = [
    {"baslik": "Fatura", "ikon": Icons.receipt_long, "renk": Colors.blue},
    {"baslik": "Gıda", "ikon": Icons.apple, "renk": Colors.green},
    {"baslik": "Eğlence", "ikon": Icons.sports_esports, "renk": Colors.purple},
    {"baslik": "Ulaşım", "ikon": Icons.directions_car, "renk": Colors.orange},
    {"baslik": "Alışveriş", "ikon": Icons.shopping_bag, "renk": Colors.blueAccent},
    {"baslik": "Sağlık", "ikon": Icons.medical_services, "renk": Colors.red},
    {"baslik": "Diğer", "ikon": Icons.more_horiz, "renk": Colors.grey},
  ];

  @override
  void initState() {
    super.initState();
    _isGelir = widget.initialIsGelir;
    _secilenKategori = _isGelir ? "Maaş" : "Fatura";
  }

  // Sayfa kapanırken hafızayı temizlemek iyi bir mühendislik prensibidir
  @override
  void dispose() {
    _tutarController.dispose();
    _aciklamaController.dispose();
    super.dispose();
  }

  Future<void> _takvimAc(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _secilenTarih,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0C4D3E),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _secilenTarih) {
      setState(() {
        _secilenTarih = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final aktifKategoriler = _isGelir ? _gelirKategorileri : _giderKategorileri;

    return Padding(
      padding: EdgeInsets.only(
        top: 16,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "İptal",
                  style: TextStyle(
                    color: Color(0xFF0C4D3E),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Text(
                "İşlem Ekle",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              // İŞTE ASIL SİHİR BURADA: DİNAMİK KAYDET BUTONU
              TextButton(
                onPressed: () async {
                  // 1. Ekrandaki yazıları al
                  String tutarMetin = _tutarController.text.trim();
                  String baslik = _aciklamaController.text.trim();

                  // 2. Boş bırakıldıysa uyarı ver ve işlemi durdur
                  if (tutarMetin.isEmpty || baslik.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Lütfen tutar ve açıklama girin!")),
                    );
                    return; 
                  }

                  // 3. Tutarı metinden ondalıklı sayıya çevir (Örn: "150" -> 150.0)
                  double tutar = double.tryParse(tutarMetin) ?? 0.0;

                  // 4. Java'nın anlayacağı formatta (JSON) paketi hazırla!
                  Map<String, dynamic> yeniIslem = {
                    "baslik": baslik,
                    "tutar": tutar,
                    "kategori": _secilenKategori,
                    "islemTipi": _isGelir ? "GELIR" : "GIDER",
                    // Tarihi YYYY-MM-DD formatına çeviriyoruz ki Spring Boot anlayabilsin
                    "tarih": _secilenTarih.toIso8601String().split('T')[0]
                  };

                  // 5. Füzeyi Ateşle!
                  bool basarili = await ApiService.islemEkle(yeniIslem);

                  if (basarili) {
                    // Kayıt başarılıysa pencereyi kapat
                    if (context.mounted) {
                      Navigator.pop(context, true); // true değeri göndererek ana sayfanın yenilenmesini sağlayabiliriz
                    }
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Sunucuya bağlanılamadı!")),
                      );
                    }
                  }
                },
                child: const Text(
                  "Kaydet",
                  style: TextStyle(
                    color: Color(0xFF0C4D3E),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap:
                      () => setState(() {
                        _isGelir = true;
                        _secilenKategori = _gelirKategorileri[0]["baslik"];
                      }),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color:
                          _isGelir
                              ? const Color(0xFF10B981)
                              : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.sync_alt,
                          color: _isGelir ? Colors.white : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Gelir",
                          style: TextStyle(
                            color:
                                _isGelir ? Colors.white : Colors.grey.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap:
                      () => setState(() {
                        _isGelir = false;
                        _secilenKategori = _giderKategorileri[0]["baslik"];
                      }),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color:
                          !_isGelir
                              ? const Color(0xFFEF4444)
                              : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.sync_alt,
                          color: !_isGelir ? Colors.white : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Gider",
                          style: TextStyle(
                            color:
                                !_isGelir ? Colors.white : Colors.grey.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Tutar",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextField(
                  controller: _tutarController, // CONTROLLER BAĞLANDI
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    prefixText: "₺ ",
                    prefixStyle: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    border: InputBorder.none,
                    hintText: "0.00",
                    hintStyle: TextStyle(color: Colors.grey.shade300),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Kategori",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children:
                  aktifKategoriler.map((kat) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 18.0),
                      child: _kategoriButonu(
                        kat["ikon"],
                        kat["renk"],
                        kat["baslik"],
                      ),
                    );
                  }).toList(),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Açıklama",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          TextField(
            controller: _aciklamaController, // CONTROLLER BAĞLANDI
            decoration: InputDecoration(
              hintText: "İşlem detayını yazın...",
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF0C4D3E)),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Tarih",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          InkWell(
            onTap: () => _takvimAc(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${_secilenTarih.day} ${_aylar[_secilenTarih.month - 1]} ${_secilenTarih.year}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Icon(Icons.calendar_month, color: Colors.grey.shade700),
                ],
              ),
            ),
          ),
          Divider(color: Colors.grey.shade200, height: 1),
          const SizedBox(height: 24),
          const Text(
            "Ödeme Yöntemi",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _odemeYontemiButonu(
                  "Kart",
                  Icons.credit_card,
                  Colors.orange.shade700,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _odemeYontemiButonu(
                  "Nakit",
                  Icons.payments_outlined,
                  Colors.green.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _kategoriButonu(IconData ikon, Color renk, String baslik) {
    bool seciliMi = _secilenKategori == baslik;
    return GestureDetector(
      onTap: () => setState(() => _secilenKategori = baslik),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: seciliMi ? renk : renk.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(ikon, color: seciliMi ? Colors.white : renk, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            baslik,
            style: TextStyle(
              fontSize: 12,
              fontWeight: seciliMi ? FontWeight.bold : FontWeight.w500,
              color: seciliMi ? Colors.black87 : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _odemeYontemiButonu(String baslik, IconData ikon, Color ikonRenk) {
    bool seciliMi = _secilenOdemeYontemi == baslik;
    return GestureDetector(
      onTap: () => setState(() => _secilenOdemeYontemi = baslik),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: seciliMi ? const Color(0xFF0C4D3E) : Colors.black87,
            width: seciliMi ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(ikon, color: ikonRenk, size: 20),
            const SizedBox(width: 10),
            Text(
              baslik,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: seciliMi ? const Color(0xFF0C4D3E) : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}