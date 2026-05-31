import 'package:flutter/material.dart';
import '../widgets/islem_karti.dart';
import '../services/api_service.dart';

class IslemlerScreen extends StatefulWidget {
  final VoidCallback? onTabBack;
  const IslemlerScreen({super.key, this.onTabBack});

  @override
  State<IslemlerScreen> createState() => _IslemlerScreenState();
}

class _IslemlerScreenState extends State<IslemlerScreen> {
  late Future<List<dynamic>> _islemlerFuture;

  int _seciliFiltreIndex = 0;
  final List<String> _filtreler = ["Tümü", "Gelir", "Gider"];

  final TextEditingController _aramaController = TextEditingController();
  String _aramaMetni = "";
  String? _seciliFiltreTarih;
  String? _seciliFiltreKategori;

  @override
  void initState() {
    super.initState();
    _islemlerFuture = ApiService.islemleriGetir();
  }

  @override
  void dispose() {
    _aramaController.dispose();
    super.dispose();
  }

  IconData _ikonSec(String kategori, String tip) {
    String k = kategori.toLowerCase();
    if (k.contains('fatura')) return Icons.receipt_long;
    if (k.contains('gıda')) return Icons.apple;
    if (k.contains('alışveriş')) return Icons.shopping_bag;
    if (k.contains('eğlence')) return Icons.sports_esports_rounded;
    if (k.contains('ulaşım')) return Icons.directions_car;
    if (k.contains('kira')) return Icons.home;
    
    return tip == 'GELIR' ? Icons.work : Icons.category;
  }

  Color _renkSec(String kategori, String tip) {
    String k = kategori.toLowerCase();
    if (k.contains('fatura')) return Colors.blue.shade600;
    if (k.contains('gıda')) return Colors.green.shade400;
    if (k.contains('alışveriş')) return Colors.blueAccent.shade400;
    if (k.contains('eğlence')) return Colors.purple.shade400;
    if (k.contains('ulaşım')) return Colors.orange.shade400;
    if (k.contains('kira')) return Colors.teal.shade400;
    
    return tip == 'GELIR' ? Colors.green : Colors.redAccent;
  }

  // --- GELİŞMİŞ TARİH MOTORU (Bugün, Dün, 31 Mayıs formatı) ---
  String _tarihFormatla(String rawTarih) {
    DateTime? dt;
    
    // Spring Boot bazen tarihleri Liste olarak [2026, 5, 31, 19, 37] gönderebilir, bazen String. İkisini de çözeriz!
    if (rawTarih.contains('T') || rawTarih.contains('-')) {
      dt = DateTime.tryParse(rawTarih);
    }
    if (dt == null) return "Bilinmeyen Tarih";

    DateTime now = DateTime.now();
    DateTime bugun = DateTime(now.year, now.month, now.day);
    DateTime dun = bugun.subtract(const Duration(days: 1));
    DateTime target = DateTime(dt.year, dt.month, dt.day);

    if (target == bugun) return "Bugün";
    if (target == dun) return "Dün";

    List<String> aylar = ["", "Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran", "Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım", "Aralık"];
    return "${dt.day} ${aylar[dt.month]}";
  }

  // --- SAAT ÇIKARTMA MOTORU (Sadece 09:30 formatını alır) ---
  String _saatCikart(dynamic rawTarihObj) {
    String rawTarih = rawTarihObj?.toString() ?? "";
    
    // Eğer ISO formatındaysa (2026-05-31T09:30:15)
    if (rawTarih.contains('T') && rawTarih.length >= 16) {
      return rawTarih.substring(11, 16); // Tam olarak HH:mm kısmını keser
    } 
    return ""; // Saat bulunamazsa boş döner
  }

  void _detayliFiltreMenusuAc(List<dynamic> tumIslemler) {
    List<String> tarihler = ["Tümü", ...tumIslemler.map((e) => e['gosterimTarihi'].toString()).toSet()];
    List<String> kategoriler = ["Tümü", ...tumIslemler.map((e) => e['kategori']?.toString() ?? "Diğer").toSet()];

    String geciciTarih = _seciliFiltreTarih ?? "Tümü";
    String geciciKategori = _seciliFiltreKategori ?? "Tümü";

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder( 
          builder: (context, setModalState) {
            return Container(
              height: 400,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)))),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Detaylı Filtreleme", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                      GestureDetector(
                        onTap: () {
                          setModalState(() {
                            geciciTarih = "Tümü";
                            geciciKategori = "Tümü";
                          });
                        },
                        child: const Text("Temizle", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                  const SizedBox(height: 30),
                  
                  const Text("Tarihe Göre", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: geciciTarih,
                        icon: const Icon(Icons.keyboard_arrow_down),
                        items: tarihler.map((String val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
                        onChanged: (val) => setModalState(() => geciciTarih = val!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text("Kategoriye Göre", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: geciciKategori,
                        icon: const Icon(Icons.keyboard_arrow_down),
                        items: kategoriler.map((String val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
                        onChanged: (val) => setModalState(() => geciciKategori = val!),
                      ),
                    ),
                  ),
                  
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0C4D3E),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        setState(() {
                          _seciliFiltreTarih = geciciTarih == "Tümü" ? null : geciciTarih;
                          _seciliFiltreKategori = geciciKategori == "Tümü" ? null : geciciKategori;
                        });
                        Navigator.pop(context);
                      },
                      child: const Text("Uygula", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _appBar(),
      body: FutureBuilder<List<dynamic>>(
        future: _islemlerFuture, 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF0C4D3E)));
          }

          List<dynamic> tumIslemler = snapshot.hasData ? snapshot.data! : [];

          // 1. ADIM: İŞLEMLERİ TARİHE GÖRE EN YENİDEN EN ESKİYE SIRALAMA
          tumIslemler.sort((a, b) {
            DateTime dateA = DateTime.tryParse(a['tarih'].toString()) ?? DateTime(2000);
            DateTime dateB = DateTime.tryParse(b['tarih'].toString()) ?? DateTime(2000);
            return dateB.compareTo(dateA); 
          });
          
          // Her işleme formatlanmış "gosterimTarihi" ve "saat" ekliyoruz
          for (var i in tumIslemler) {
            i['gosterimTarihi'] = _tarihFormatla(i['tarih'].toString());
            i['gosterimSaati'] = _saatCikart(i['tarih']);
          }

          // 2. ADIM: FİLTRELEME
          var filtrelenmis = tumIslemler.where((i) {
            String tip = (i['islemTipi'] ?? 'GIDER').toString().toUpperCase();
            if (_seciliFiltreIndex == 1 && tip != "GELIR") return false;
            if (_seciliFiltreIndex == 2 && tip != "GIDER") return false;

            String baslik = (i['baslik'] ?? "").toString().toLowerCase();
            if (_aramaMetni.isNotEmpty && !baslik.contains(_aramaMetni.toLowerCase())) return false;

            if (_seciliFiltreTarih != null && i['gosterimTarihi'] != _seciliFiltreTarih) return false;

            String kategori = i['kategori']?.toString() ?? "Diğer";
            if (_seciliFiltreKategori != null && kategori != _seciliFiltreKategori) return false;

            return true;
          }).toList();

          // 3. ADIM: GRUPLAMA (Sıralama bozulmadan)
          Map<String, List<dynamic>> gruplu = {};
          for (var i in filtrelenmis) {
            String tarih = i['gosterimTarihi'];
            if (!gruplu.containsKey(tarih)) gruplu[tarih] = [];
            gruplu[tarih]!.add(i);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _aramaVeFiltreCubugu(tumIslemler),
                const SizedBox(height: 20),
                _filtreSekmeleri(),
                const SizedBox(height: 32),
                
                if (filtrelenmis.isEmpty)
                  _bosDurumEkrani()
                else
                  ...gruplu.entries.map((grup) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _tarihBasligi(grup.key),
                      _islemKartGrubu(islemler: grup.value),
                      const SizedBox(height: 20),
                    ],
                  )),
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }

  AppBar _appBar() => AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 18),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else if (widget.onTabBack != null) {
              widget.onTabBack!();
            }
          },
        ),
        title: const Text('İşlemlerim', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      );

  Widget _aramaVeFiltreCubugu(List<dynamic> tumIslemler) {
    bool filtreAktifMi = _seciliFiltreTarih != null || _seciliFiltreKategori != null;

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.grey.shade400, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _aramaController, 
                    onChanged: (deger) {
                      setState(() {
                        _aramaMetni = deger; 
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "İşlem ara...",
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.only(bottom: 12),
                    ),
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () => _detayliFiltreMenusuAc(tumIslemler),
          child: Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: filtreAktifMi ? const Color(0xFF0C4D3E).withAlpha(15) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: filtreAktifMi ? const Color(0xFF0C4D3E) : Colors.grey.shade200),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.filter_alt_outlined, color: filtreAktifMi ? const Color(0xFF0C4D3E) : Colors.black87, size: 22),
                if (filtreAktifMi)
                  Positioned(
                    top: 14,
                    right: 14,
                    child: Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _filtreSekmeleri() => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(_filtreler.length, (index) => Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => setState(() => _seciliFiltreIndex = index),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: _seciliFiltreIndex == index ? const Color(0xFF0C4D3E) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(_filtreler[index], style: TextStyle(color: _seciliFiltreIndex == index ? Colors.white : Colors.grey.shade600, fontWeight: _seciliFiltreIndex == index ? FontWeight.bold : FontWeight.w600, fontSize: 13)),
              ),
            ),
          )),
        ),
      );

  Widget _bosDurumEkrani() {
    return Padding(
      padding: const EdgeInsets.only(top: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.grey.withAlpha(10), blurRadius: 20, offset: const Offset(0, 10))]),
            child: Center(child: Icon(Icons.search_off_rounded, size: 40, color: Colors.grey.shade300)),
          ),
          const SizedBox(height: 32),
          const Text("İşlem Bulunamadı", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 12),
          Text("Yaptığınız aramaya veya filtrelere uygun\nherhangi bir kayıt bulunmuyor.", textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.grey.shade500, height: 1.5)),
        ],
      ),
    );
  }

  Widget _tarihBasligi(String tarih) => Padding(
        padding: const EdgeInsets.only(bottom: 12.0, top: 10.0),
        child: Text(tarih, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.black87)),
      );

  Widget _islemKartGrubu({required List<dynamic> islemler}) => Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.withAlpha(12), blurRadius: 10, offset: const Offset(0, 4))]),
        child: Column(
          children: islemler.map((i) {
            String tip = i['islemTipi'].toString().toUpperCase();
            bool gelirMi = tip == 'GELIR';
            String baslikRaw = i['baslik']?.toString() ?? "İşlem";
            String kategori = i['kategori']?.toString() ?? "Diğer";
            double tutarValue = double.tryParse(i['tutar']?.toString() ?? "0") ?? 0.0;

            String baslikGosterilen = baslikRaw.isNotEmpty ? baslikRaw[0].toUpperCase() + baslikRaw.substring(1) : baslikRaw;
            
            // SADECE SAATİ GÖSTERİYORUZ (Tasarımda olduğu gibi)
            String saatGosterimi = i['gosterimSaati'] ?? "";
            String altBaslikSon = saatGosterimi.isNotEmpty ? saatGosterimi : kategori;

            return IslemKarti(
              ikon: _ikonSec(kategori, tip),
              renk: _renkSec(kategori, tip),
              baslik: baslikGosterilen,
              altBaslik: altBaslikSon,
              miktar: "${gelirMi ? '+' : '-'} ₺${tutarValue.toStringAsFixed(0)}",
              miktarRengi: gelirMi ? Colors.green : Colors.red,
            );
          }).toList(),
        ),
      );
}