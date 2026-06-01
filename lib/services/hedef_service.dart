import 'dart:convert';
import 'package:http/http.dart' as http;

class TasarrufHedefi {
  final int? id;
  final String baslik;
  final double hedefTutar;
  final double birikenTutar;
  final DateTime sonTarih;
  final String gorselYolu;
  final String renkKodu;

  TasarrufHedefi({
    this.id,
    required this.baslik,
    required this.hedefTutar,
    required this.birikenTutar,
    required this.sonTarih,
    required this.gorselYolu,
    required this.renkKodu,
  });

  factory TasarrufHedefi.fromJson(Map<String, dynamic> json) {
    return TasarrufHedefi(
      id: json['id'],
      baslik: json['baslik'] ?? '',
      hedefTutar: (json['hedefTutar'] as num?)?.toDouble() ?? 0.0,
      birikenTutar: (json['birikenTutar'] as num?)?.toDouble() ?? 0.0,
      sonTarih: DateTime.parse(
        json['sonTarih'] ?? DateTime.now().toIso8601String(),
      ),
      gorselYolu: json['gorselYolu'] ?? 'Alışveriş', // Varsayılan kategori
      renkKodu: json['renkKodu'] ?? '#3B82F6',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'baslik': baslik,
      'hedefTutar': hedefTutar,
      'birikenTutar': birikenTutar,
      'sonTarih': sonTarih.toIso8601String().split('T')[0],
      'gorselYolu': gorselYolu,
      'renkKodu': renkKodu,
    };
  }

  double get ilerlemeOrani =>
      hedefTutar > 0 ? (birikenTutar / hedefTutar).clamp(0.0, 1.0) : 0.0;
}

class HedefService {
  // Emülatör kullandığın için adres bu şekilde kalmalı
  static const String _baseUrl = 'http://10.0.2.2:8080/api/hedefler';

  static Future<List<TasarrufHedefi>> hedefleriGetir() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        return body
            .map((dynamic item) => TasarrufHedefi.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      print("Hedef çekme hatası: $e");
      return [];
    }
  }

  static Future<bool> hedefEkle(TasarrufHedefi hedef) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(hedef.toJson()),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Hedef ekleme hatası: $e");
      return false;
    }
  }

  // services/hedef_service.dart içine ekle:
  static Future<bool> hedefEkleRaw(Map<String, dynamic> veri) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.19:8080/api/hedefler'), // IP'ni kontrol et!
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(veri),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Servis Hatası: $e");
      return false;
    }
  }
}
