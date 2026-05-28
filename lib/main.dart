import 'package:flutter/material.dart';
import 'screens/main_layout.dart'; // Birazdan bu dosyayı oluşturacağız

void main() {
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
        // Tasarımdaki çok açık buz mavisi/gri arka plan rengi
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        useMaterial3: true,
      ),
      home: const MainLayout(),
    );
  }
}
