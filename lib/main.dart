import 'package:flutter/material.dart';
import 'package:onyuz/screens/register_page.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Local kayıt için şart
import 'screens/main_layout.dart';
import 'screens/login_screen.dart'; // Yeni login ekranını import et
import 'services/api_service.dart';

void main() async {
  // Uygulama motorunu asenkron işlemlere hazırla
  WidgetsFlutterBinding.ensureInitialized();

  // 1. ADIM: Oturum Durumunu Kontrol Et
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  // 2. ADIM: Backend Bağlantı Testi
  try {
    print("---- BACKEND TESTİ BAŞLIYOR ----");
    var islemler = await ApiService.islemleriGetir();
    if (islemler.isNotEmpty) {
      print("BAŞARILI! Veri akışı aktif.");
    }
    print("--------------------------------");
  } catch (e) {
    print("---- BACKEND'E ULAŞILAMADI: $e ----");
  }

  // 3. ADIM: Arayüzü oturum durumuna göre başlat
  runApp(
    FinansApp(
      startScreen: isLoggedIn ? const MainLayout() : const LoginScreen(),
    ),
  );
}

class FinansApp extends StatelessWidget {
  final Widget startScreen;

  const FinansApp({super.key, required this.startScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finans App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        useMaterial3: true,
        // Projendeki koyu yeşil tonu (0xFF0C4D3E) ana tema rengi yapabilirsin
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0C4D3E)),
      ),
      // Oturum varsa MainLayout, yoksa LoginScreen açılır
      home: startScreen,
    );
  }
}
