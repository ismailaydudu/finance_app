import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DovizScreen extends StatefulWidget {
  const DovizScreen({super.key});

  @override
  State<DovizScreen> createState() => _DovizScreenState();
}

class _DovizScreenState extends State<DovizScreen> {
  final TextEditingController _tutarController = TextEditingController(text: "1.000");
  String _kaynakParaBirimi = "USD";
  String _hesaplananSonuc = "0,00";

  @override
  void dispose() {
    _tutarController.dispose();
    super.dispose();
  }

  void _hesapla(Map<String, dynamic> rates) {
    double? girilenTutar = double.tryParse(_tutarController.text.replaceAll('.', '').replaceAll(',', '.'));
    if (girilenTutar != null) {
      double tryKur = double.tryParse(rates['TRY']?.toString() ?? "32.46") ?? 32.46;
      double sonuc;
      
      if (_kaynakParaBirimi == "XAU") {
        sonuc = girilenTutar * 2410.0;
      } else {
        double kaynakKur = double.tryParse(rates[_kaynakParaBirimi]?.toString() ?? "1.0") ?? 1.0;
        sonuc = (girilenTutar / kaynakKur) * tryKur;
      }
      
      setState(() {
        _hesaplananSonuc = sonuc.toStringAsFixed(2).replaceAll('.', ',');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: ApiService.kurlariGetir(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Scaffold(backgroundColor: Color(0xFFF5F7FA), body: Center(child: CircularProgressIndicator()));
        var rates = snapshot.data!['rates'] ?? {};
        double tryKur = double.tryParse(rates['TRY']?.toString() ?? "32.46") ?? 32.46;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          appBar: _appBar(),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                _sonGuncellemeKarti(),
                const SizedBox(height: 24),
                const Text("Anlık Kurlar", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10, offset: const Offset(0, 4))]),
                  child: Column(children: [
                    _canliKurSatiri("🇺🇸", "USD", "Amerikan Doları", (tryKur / (double.tryParse(rates['USD']?.toString() ?? "1.0") ?? 1.0)).toStringAsFixed(2)),
                    _canliKurSatiri("🇪🇺", "EUR", "Euro", (tryKur / (double.tryParse(rates['EUR']?.toString() ?? "0.85") ?? 0.85)).toStringAsFixed(2)),
                    _canliKurSatiri("🇬🇧", "GBP", "İngiliz Sterlini", (tryKur / (double.tryParse(rates['GBP']?.toString() ?? "0.75") ?? 0.75)).toStringAsFixed(2)),
                    _canliKurSatiri("🟡", "XAU", "Gram Altın", "2410,00", sonElemanMi: true),
                  ]),
                ),
                const SizedBox(height: 24),
                _hesaplamaAlani(rates),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  AppBar _appBar() => AppBar(backgroundColor: Colors.transparent, elevation: 0, leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 18), onPressed: () => Navigator.pop(context)), title: const Text('Kur Hesaplayıcı', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)), centerTitle: true);

  Widget _sonGuncellemeKarti() => Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10, offset: const Offset(0, 4))]), child: const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Son Güncelleme", style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)), Text("Anlık Veriler", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87))]), Icon(Icons.check_circle, color: Colors.green, size: 16)]));

  Widget _canliKurSatiri(String b, String k, String i, String d, {bool sonElemanMi = false}) => Column(children: [Padding(padding: const EdgeInsets.all(16), child: Row(children: [Text(b, style: const TextStyle(fontSize: 24)), const SizedBox(width: 14), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(k, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)), Text(i, style: const TextStyle(fontSize: 11, color: Colors.grey))]), const Spacer(), Text("₺$d", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87))])), if (!sonElemanMi) const Divider(height: 1)]);

  Widget _hesaplamaAlani(Map<String, dynamic> rates) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(children: [
        TextField(controller: _tutarController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Tutar")),
        DropdownButton<String>(
          value: _kaynakParaBirimi,
          isExpanded: true,
          items: ['USD', 'EUR', 'GBP', 'XAU'].map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
          onChanged: (y) => setState(() => _kaynakParaBirimi = y!),
        ),
        const SizedBox(height: 10),
        Text("Sonuç: $_hesaplananSonuc TRY", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ElevatedButton(onPressed: () => _hesapla(rates), child: const Text("Hesapla")),
      ]),
    );
  }
}