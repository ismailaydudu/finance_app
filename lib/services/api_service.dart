import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://192.168.1.19:8080/api';

  // İşlemleri çek
  static Future<List<dynamic>> islemleriGetir() async {
    final response = await http.get(Uri.parse('$baseUrl/verileri-getir'));
    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('İşlemler sunucudan çekilemedi!');
    }
  }

  // --- HESAPLAMA MOTORU (ANA SAYFA İÇİN) ---
  static Future<double> toplamBakiyeHesapla() async {
    try {
      List<dynamic> islemler = await islemleriGetir();
      double bakiye = 0.0;

      for (var i in islemler) {
        // Tutar null veya hatalıysa 0 al
        double tutar = double.tryParse(i['tutar'].toString()) ?? 0.0;
        String tip = (i['islemTipi'] ?? 'GIDER').toString().toUpperCase();

        if (tip == 'GELIR') {
          bakiye += tutar;
        } else {
          bakiye -= tutar;
        }
      }
      return bakiye;
    } catch (e) {
      print("BAKİYE HESAPLAMA HATASI: $e");
      return 0.0;
    }
  }

  // Döviz Kurları
  static Future<Map<String, dynamic>> kurlariGetir() async {
    final response = await http.get(Uri.parse('$baseUrl/kurlar'));
    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Döviz kurları sunucudan çekilemedi!');
    }
  }

  // Java'ya POST gönder
  static Future<bool> islemEkle(Map<String, dynamic> yeniIslem) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/islemler'),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(yeniIslem),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("BAŞARILI: Veri Java'ya ulaştı!");
        return true;
      } else {
        print("HATA: Sunucu reddetti. Kod: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("BAĞLANTI HATASI: $e");
      return false;
    }
  }
}
