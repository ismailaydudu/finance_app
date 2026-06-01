import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Hafıza yönetimi için
import '../utils/profile_state.dart';
import 'register_page.dart'; // Çıkış için lazım

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  final ImagePicker _picker = ImagePicker();
  String _kullaniciEmail = "Yükleniyor...";

  @override
  void initState() {
    super.initState();
    _bilgileriGetir();
  }

  // Hafızadaki e-posta ve ismi formatlı yükle
  Future<void> _bilgileriGetir() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _kullaniciEmail = prefs.getString('userEmail') ?? "e-posta bulunamadı";
      String? hamIsim = prefs.getString('userName');

      if (hamIsim != null && hamIsim.isNotEmpty) {
        // İsim formatlama: İlk harf büyük, gerisi küçük (BORA -> Bora)
        String formatli =
            hamIsim[0].toUpperCase() + hamIsim.substring(1).toLowerCase();
        ProfileState.isimNotifier.value = formatli;
      }
    });
  }

  // GÜVENLİ ÇIKIŞ YAP (Hafızayı siler ve Register'a atar)
  Future<void> _cikisYap() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Her şeyi sıfırla
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const RegisterPage()),
        (route) => false,
      );
    }
  }

  Future<void> _galeridenResimSec() async {
    try {
      final XFile? resim = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (resim != null) {
        ProfileState.resimNotifier.value = File(resim.path);
      }
    } catch (e) {
      debugPrint("Resim hatası: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // 1. BÖLÜM: ÜST PANEL (Geri dönüş oku eklendi)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 55, 24, 32),
              decoration: const BoxDecoration(
                color: Color(0xFF0C4D3E),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(36),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // GERİ DÖNÜŞ OKU
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const Text(
                        "Profilim",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      // AYARLAR (Simetri için)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.settings_suggest_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: _galeridenResimSec,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: ValueListenableBuilder<File?>(
                            valueListenable: ProfileState.resimNotifier,
                            builder: (context, mevcutResim, child) {
                              return CircleAvatar(
                                radius: 46,
                                backgroundColor: Colors.grey.shade200,
                                backgroundImage:
                                    mevcutResim != null
                                        ? FileImage(mevcutResim)
                                        : const NetworkImage(
                                              'https://i1.rgstatic.net/ii/profile.image/11431281796811820-1765961137549_Q512/Emir-Oeztuerk.jpg',
                                            )
                                            as ImageProvider,
                              );
                            },
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ValueListenableBuilder<String>(
                    valueListenable: ProfileState.isimNotifier,
                    builder: (context, mevcutIsim, child) {
                      return Text(
                        mevcutIsim,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _kullaniciEmail,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.65),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            // 2. BÖLÜM: KARTLAR VE MENÜ
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  _finansalSkorKarti(),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _menuSatiri(
                          Icons.account_balance_wallet_rounded,
                          "Hesaplarım",
                        ),
                        _menuSatiri(
                          Icons.credit_card_rounded,
                          "Bütçe Ayarlarım",
                        ),
                        _menuSatiri(
                          Icons.alarm_on_rounded,
                          "Fatura Hatırlatıcıları",
                        ),
                        _menuSatiri(
                          Icons.track_changes_rounded,
                          "Tasarruf Hedeflerim",
                        ),
                        _menuSatiri(
                          Icons.shield_outlined,
                          "Güvenlik ve Gizlilik",
                        ),
                        _menuSatiri(
                          Icons.headset_mic_rounded,
                          "Destek Merkezi",
                          sonMu: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // ÇIKIŞ BUTONU
                  _cikisButonu(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _finansalSkorKarti() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Finansal Skorum",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        "85",
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF10B981),
                        ),
                      ),
                      Text(
                        " /100",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Icon(Icons.stars_rounded, color: Colors.amber.shade600, size: 35),
            ],
          ),
          const SizedBox(height: 14),
          const LinearProgressIndicator(
            value: 0.85,
            minHeight: 6,
            backgroundColor: Color(0xFFF1F5F9),
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
          ),
        ],
      ),
    );
  }

  Widget _menuSatiri(IconData ikon, String baslik, {bool sonMu = false}) {
    return Column(
      children: [
        ListTile(
          leading: Icon(ikon, color: const Color(0xFF64748B), size: 22),
          title: Text(
            baslik,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12),
        ),
        if (!sonMu) const Divider(height: 1, indent: 20, endIndent: 20),
      ],
    );
  }

  Widget _cikisButonu() {
    return InkWell(
      onTap: _cikisYap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 20),
            SizedBox(width: 8),
            Text(
              "Güvenli Çıkış Yap",
              style: TextStyle(
                color: Color(0xFFEF4444),
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
