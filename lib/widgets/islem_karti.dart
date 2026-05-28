import 'package:flutter/material.dart';

class IslemKarti extends StatelessWidget {
  // Dışarıdan alacağımız değişkenleri tanımlıyoruz
  final IconData ikon;
  final Color renk;
  final String baslik;
  final String altBaslik; // Saat veya Tarih olabilir
  final String miktar;
  final Color miktarRengi;

  // Constructor (Yapıcı Metot) - Bu widget çağrıldığında bu bilgilerin girilmesini zorunlu kılıyoruz
  const IslemKarti({
    super.key,
    required this.ikon,
    required this.renk,
    required this.baslik,
    required this.altBaslik,
    required this.miktar,
    required this.miktarRengi,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: renk.withOpacity(
            0.1,
          ), // Rengin saydam halini arka plan yapıyoruz
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(ikon, color: renk),
      ),
      title: Text(
        baslik,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      subtitle: Text(
        altBaslik,
        style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
      ),
      trailing: Text(
        miktar,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: miktarRengi,
        ),
      ),
    );
  }
}
