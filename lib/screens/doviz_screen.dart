import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DovizScreen extends StatefulWidget {
  const DovizScreen({super.key});

  @override
  State<DovizScreen> createState() => _DovizScreenState();
}

class _DovizScreenState extends State<DovizScreen> {
  Map<String, Map<String, dynamic>> _kurlarMap = {};
  bool _isLoading = true;
  String _hataMesaji = "";

  String _seciliGidenKur = "USD";
  int _seciliHizliDonusum = 0;
  final TextEditingController _tutarController = TextEditingController(
    text: "1",
  );
  double _hesaplananTutar = 0.0;
  double _guncelOran = 0.0;

  @override
  void initState() {
    super.initState();
    _verileriCek();
  }

  Future<void> _verileriCek() async {
    try {
      var response = await ApiService.kurlariGetir();
      Map<String, Map<String, dynamic>> geciciMap = {};

      // 1. API'nin gönderdiği saçma sapan meta verilerden kurtulup, asıl "kurlar" klasörünü buluyoruz
      Map<String, dynamic> asilKurlar = response;

      // Standart API'ler kurları genelde 'rates' veya 'conversion_rates' içine koyar
      if (response.containsKey('rates') && response['rates'] is Map) {
        asilKurlar = response['rates'];
      } else if (response.containsKey('conversion_rates') &&
          response['conversion_rates'] is Map) {
        asilKurlar = response['conversion_rates'];
      } else if (response.containsKey('data') && response['data'] is Map) {
        asilKurlar = response['data'];
      }

      // 2. Sadece GERÇEK döviz kurlarını okuyoruz
      asilKurlar.forEach((key, value) {
        String k = key.toUpperCase();

        // Eğer yanlışlıkla hala time, update gibi veriler geldiyse onları atla
        if (k.contains('TIME') ||
            k.contains('DATE') ||
            k == 'SUCCESS' ||
            k == 'BASE')
          return;

        if (value is num) {
          geciciMap[k] = {
            "alis": value.toDouble(),
            "satis": value.toDouble(),
            "oran": value.toDouble(),
            "degisim":
                0.0, // Standart API'lerde değişim yüzdesi olmaz, 0 atıyoruz
          };
        } else if (value is Map) {
          geciciMap[k] = {
            "alis": double.tryParse(value['alis']?.toString() ?? '0') ?? 0.0,
            "satis": double.tryParse(value['satis']?.toString() ?? '0') ?? 0.0,
            "oran":
                double.tryParse(
                  value['oran']?.toString() ?? value['alis']?.toString() ?? '0',
                ) ??
                0.0,
            "degisim":
                double.tryParse(value['degisim']?.toString() ?? '0') ?? 0.0,
          };
        }
      });

      // API 160 tane saçma kur gönderiyorsa sadece en önemlilerini filtrele (Opsiyonel ama şık durur)
      List<String> onemliKurlar = [
        'USD',
        'EUR',
        'GBP',
        'TRY',
        'XAU',
        'CHF',
        'CAD',
        'JPY',
      ];
      Map<String, Map<String, dynamic>> filtrelenmisMap = {};

      for (var kod in onemliKurlar) {
        if (geciciMap.containsKey(kod)) {
          filtrelenmisMap[kod] = geciciMap[kod]!;
        }
      }

      setState(() {
        // Eğer API'de önemli kurlar yoksa hepsini göster, varsa sadece önemlileri göster
        _kurlarMap = filtrelenmisMap.isNotEmpty ? filtrelenmisMap : geciciMap;
        _isLoading = false;
      });

      _hesapla();
    } catch (e) {
      setState(() {
        _hataMesaji = "Kurlar çekilemedi: $e";
        _isLoading = false;
      });
    }
  }

  void _hesapla() {
    if (_kurlarMap.isEmpty) return;

    double tutar =
        double.tryParse(_tutarController.text.replaceAll(',', '.')) ?? 0.0;

    // Seçilen giden kurun oranını al (örn USD = 1.0)
    double gidenOran = _kurlarMap[_seciliGidenKur]?['oran'] ?? 1.0;

    // Hedef TRY'nin oranını al (örn TRY = 32.50)
    double gelenOran = _kurlarMap['TRY']?['oran'] ?? 1.0;

    // Base USD ise formül: (Tutar / GidenOran) * GelenOran
    double oran = gelenOran / gidenOran;

    setState(() {
      _guncelOran = oran;
      _hesaplananTutar = tutar * oran;
    });
  }

  void _kurSeciciyiAc() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return ListView(
          padding: const EdgeInsets.all(20),
          children:
              _kurlarMap.keys.where((k) => k != 'TRY').map((kod) {
                return ListTile(
                  leading: Text(
                    _bayrakGetir(kod),
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(
                    kod,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(_isimGetir(kod)),
                  onTap: () {
                    setState(() => _seciliGidenKur = kod);
                    _hesapla();
                    Navigator.pop(context);
                  },
                );
              }).toList(),
        );
      },
    );
  }

  String _bayrakGetir(String kod) {
    switch (kod.toUpperCase()) {
      case 'USD':
        return "🇺🇸";
      case 'EUR':
        return "🇪🇺";
      case 'GBP':
        return "🇬🇧";
      case 'TRY':
        return "🇹🇷";
      case 'XAU':
        return "🪙";
      case 'CHF':
        return "🇨🇭";
      case 'CAD':
        return "🇨🇦";
      case 'JPY':
        return "🇯🇵";
      case 'SAR':
        return "🇸🇦";
      default:
        return "💱";
    }
  }

  String _isimGetir(String kod) {
    switch (kod.toUpperCase()) {
      case 'USD':
        return "Amerikan Doları";
      case 'EUR':
        return "Euro";
      case 'GBP':
        return "İngiliz Sterlini";
      case 'TRY':
        return "Türk Lirası";
      case 'XAU':
        return "Gram Altın";
      case 'CHF':
        return "İsviçre Frangı";
      case 'CAD':
        return "Kanada Doları";
      case 'JPY':
        return "Japon Yeni";
      default:
        return "Döviz Kuru";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black87,
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Kur Hesaplayıcı',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF0C4D3E)),
              )
              : _hataMesaji.isNotEmpty
              ? Center(
                child: Text(
                  _hataMesaji,
                  style: const TextStyle(color: Colors.red),
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    _sonGuncellemeKarti(),
                    const SizedBox(height: 24),
                    const Text(
                      "Anlık Kurlar",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _anlikKurlarListesi(),
                    const SizedBox(height: 24),
                    _hesaplayiciKarti(),
                    const SizedBox(height: 24),
                    const Text(
                      "Hızlı Dönüşümler",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _hizliDonusumler(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
    );
  }

  Widget _sonGuncellemeKarti() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(10),
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
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 4),
              const Text(
                "Anlık API Verisi",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                "Bağlantı Aktif",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _anlikKurlarListesi() {
    if (_kurlarMap.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Text("Gösterilecek veri yok."),
      );
    }

    // Listede kendisiyle çarpışmasın diye TRY'yi çıkartabiliriz (eğer Base USD ise)
    List<String> keys = _kurlarMap.keys.where((k) => k != 'TRY').toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: keys.length,
        separatorBuilder:
            (context, index) => Divider(color: Colors.grey.shade100, height: 1),
        itemBuilder: (context, index) {
          String kod = keys[index];
          var kur = _kurlarMap[kod]!;

          // Matematik: Bütün kurları TRY karşılığına çeviriyoruz (API bazen 1 USD = x EUR gönderir)
          double tryOrani = _kurlarMap['TRY']?['oran'] ?? 1.0;
          double kendiOrani = kur['oran'] ?? 1.0;
          double gercekDeger = tryOrani / kendiOrani;

          double degisim = kur['degisim'] ?? 0.0;
          bool isUp = degisim >= 0;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text(_bayrakGetir(kod), style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        kod,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        _isimGetir(kod),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  "₺${gercekDeger.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isUp
                            ? Colors.green.withAlpha(20)
                            : Colors.red.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isUp ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                        color: isUp ? Colors.green : Colors.red,
                        size: 18,
                      ),
                      Text(
                        "%${degisim.abs().toStringAsFixed(2)}",
                        style: TextStyle(
                          color: isUp ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _hesaplayiciKarti() {
    return GestureDetector(
      onTap: _kurSeciciyiAc,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(10),
              blurRadius: 15,
              offset: const Offset(0, 8),
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
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.sync, color: Colors.black87, size: 20),
                  onPressed: _verileriCek,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _tutarController,
                      keyboardType: TextInputType.number,
                      onChanged: (val) => _hesapla(),
                      decoration: InputDecoration(
                        labelText: "Tutar",
                        labelStyle: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Text(
                          _bayrakGetir(_seciliGidenKur),
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _seciliGidenKur,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(16),
                color: Colors.grey.shade50,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Karşılık Gelen Tutar",
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "₺${_hesaplananTutar.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Text("🇹🇷", style: TextStyle(fontSize: 16)),
                        SizedBox(width: 6),
                        Text(
                          "TRY",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "1 $_seciliGidenKur = ${_guncelOran.toStringAsFixed(2)} TRY",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hizliDonusumler() {
    List<String> aktifKurlar =
        _kurlarMap.keys.where((k) => k != 'TRY').take(4).toList();
    if (aktifKurlar.isEmpty) aktifKurlar = ["USD", "EUR"];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(aktifKurlar.length, (index) {
          bool isActive = _seciliHizliDonusum == index;
          String kurKodu = aktifKurlar[index];

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _seciliHizliDonusum = index;
                  _seciliGidenKur = kurKodu;
                });
                _hesapla();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFF0C4D3E) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive ? Colors.transparent : Colors.grey.shade200,
                  ),
                ),
                child: Text(
                  "$kurKodu → TRY",
                  style: TextStyle(
                    color: isActive ? Colors.white : Colors.black87,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
