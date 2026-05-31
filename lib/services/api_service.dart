import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Mevcut IP adresinizi koruyoruz
  static const String baseUrl = 'http://192.168.1.19:8080/api';

  // --- LOGIN METODU (YENİ EKLENDİ) ---
  static Future<dynamic> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/login'),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        // Başarılı giriş: Gelen kullanıcı verisini (JSON) dön
        return json.decode(utf8.decode(response.bodyBytes));
      } else if (response.statusCode == 401) {
        print("HATA: Yetkisiz giriş. E-posta veya şifre hatalı.");
        return null;
      } else {
        print("HATA: Sunucu hatası. Kod: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("LOGIN BAĞLANTI HATASI: $e");
      // Iso salak olduğu için ya server kapalı ya da IP yanlış
      throw Exception("Sunucuya bağlanılamadı!");
    }
  }

  // --- İŞLEMLERİ ÇEK (MEVCUT) ---
  static Future<List<dynamic>> islemleriGetir() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/verileri-getir'));
      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('İşlemler sunucudan çekilemedi!');
      }
    } catch (e) {
      print("VERİ ÇEKME HATASI: $e");
      return [];
    }
  }

  // --- HESAPLAMA MOTORU (MEVCUT) ---
  static Future<double> toplamBakiyeHesapla() async {
    try {
      List<dynamic> islemler = await islemleriGetir();
      double bakiye = 0.0;

      for (var i in islemler) {
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

  static Future<bool> register(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse(
          '$baseUrl/users/register',
        ), // Backend'de bu endpoint'i açmalısın
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(userData),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("REGISTER HATASI: $e");
      return false;
    }
  }

  // --- DÖVİZ KURLARI (MEVCUT) ---
  static Future<Map<String, dynamic>> kurlariGetir() async {
    final response = await http.get(Uri.parse('$baseUrl/kurlar'));
    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Döviz kurları sunucudan çekilemedi!');
    }
  }

  // --- JAVA'YA POST GÖNDER (MEVCUT) ---
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
