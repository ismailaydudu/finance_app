import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:onyuz/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Hafıza yönetimi için şart
import '../utils/profile_state.dart';
import 'register_page.dart'; // Çıkış yaptıktan sonra fırlatacağımız sayfa

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  final ImagePicker _picker = ImagePicker();
  String _kullaniciEmail = "E-posta yükleniyor..."; // Dinamik e-posta için alan

  @override
  void initState() {
    super.initState();
    _kullaniciBilgileriniYukle();
  }

  // Giriş/Kayıt esnasında saklanan e-postayı hafızadan çeken fonksiyon
  Future<void> _kullaniciBilgileriniYukle() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('userEmail');
    if (email != null && email.isNotEmpty) {
      setState(() {
        _kullaniciEmail = email;
      });
    }
  }

  // BOMBA GİBİ ÇIKIŞ YAPMA FONKSİYONU
  Future<void> _cikisYap() async {
    setState(() {}); // Loading koymak istersen tetiklesin diye

    final prefs = await SharedPreferences.getInstance();
    // Hafızadaki bütün kilitleri patlatıyoruz
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('userName');
    await prefs.remove('userEmail');

    if (mounted) {
      // Geçmişteki tüm sayfaları (MainLayout, HomeScreen vb.) hafızadan kazıyoruz
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) =>
            false, // Geri tuşuna basınca uygulamaya kaçak girmesini engeller
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
      debugPrint("Resim secilirken hata olustu: $e");
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
            // 1. BÖLÜM: ÜST ENTEGRE KOYU YEŞİL PROFİL PANELİ
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
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
                      const SizedBox(width: 40),
                      const Text(
                        "Profilim",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.settings_suggest_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () {},
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
                          letterSpacing: -0.5,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  // Dinamik olarak hafızadan gelen e-postayı buraya basıyoruz
                  Text(
                    _kullaniciEmail,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.65),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // 2. BÖLÜM: İÇERİK ALANI
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withOpacity(0.02),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Finansial Skorum",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    const Text(
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
                                        color: Colors.grey.shade400,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade50,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.stars_rounded,
                                color: Colors.amber.shade600,
                                size: 28,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: const LinearProgressIndicator(
                            value: 0.85,
                            minHeight: 6,
                            backgroundColor: Color(0xFFF1F5F9),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF10B981),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withOpacity(0.02),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _premiumMenuSatiri(
                          Icons.account_balance_wallet_rounded,
                          "Hesaplarım",
                        ),
                        _premiumMenuSatiri(
                          Icons.credit_card_rounded,
                          "Bütçe Ayarlarım",
                        ),
                        _premiumMenuSatiri(
                          Icons.alarm_on_rounded,
                          "Fatura Hatırlatıcıları",
                        ),
                        _premiumMenuSatiri(
                          Icons.track_changes_rounded,
                          "Tasarruf Hedeflerim",
                        ),
                        _premiumMenuSatiri(
                          Icons.shield_outlined,
                          "Güvenlik ve Gizlilik",
                        ),
                        _premiumMenuSatiri(
                          Icons.headset_mic_rounded,
                          "Destek Merkezi",
                          sonElemanMi: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // AKTİF VE YENİLENMİŞ ÇIKIŞ YAPMA ALANI
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withOpacity(0.01),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: InkWell(
                      onTap: _cikisYap, // Buraya köprüyü çaktık!
                      borderRadius: BorderRadius.circular(20),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.logout_rounded,
                              color: Color(0xFFEF4444),
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Güvenli Çıkış Yap",
                              style: TextStyle(
                                color: Color(0xFFEF4444),
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _premiumMenuSatiri(
    IconData ikon,
    String baslik, {
    bool sonElemanMi = false,
  }) {
    return Column(
      children: [
        ListTile(
          onTap: () {},
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 3,
          ),
          leading: Icon(ikon, color: const Color(0xFF64748B), size: 22),
          title: Text(
            baslik,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 12,
            color: Color(0xFF94A3B8),
          ),
        ),
        if (!sonElemanMi)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Divider(color: Color(0xFFF1F5F9), height: 1),
          ),
      ],
    );
  }
}
