import 'package:flutter/material.dart';
import 'screens/main_layout.dart';
import 'services/api_service.dart'; // KÖPRÜMÜZÜ BURAYA BAĞLADIK!

void main() async {
  // Uygulama motorunu asenkron işlemlere hazırla
  WidgetsFlutterBinding.ensureInitialized();

  // BACKEND BAĞLANTI TESTİ (Uygulama açılırken çalışır)
  try {
    print("---- BACKEND TESTİ BAŞLIYOR ----");
    var islemler = await ApiService.islemleriGetir();
    print("BAŞARILI! Veritabanından gelen veri: \${islemler[0]['baslik']} - \${islemler[0]['tutar']} TL");
    print("--------------------------------");
  } catch (e) {
    print("---- BACKEND'E ULAŞILAMADI: \$e ----");
  }

  // Arayüzü çalıştır
  runApp(const FinansApp());
}

class FinansApp extends StatelessWidget {
  const FinansApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finans App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        useMaterial3: true,
      ),
      home: const MainLayout(),
    );
  }
}