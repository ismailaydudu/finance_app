import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'main_layout.dart';
import 'login_screen.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _isimController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureText = true;

  final Color primaryGreen = const Color(0xFF06412D);
  final Color brandGreen = const Color(0xFF10B981);

  Future<void> _handleRegister() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar("E-posta ve şifre girmeden nereye kanka? Doldur buraları.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Backend'e kaydı at
      await ApiService.register({
        "isim":
            _isimController.text.isEmpty
                ? "Yeni Kullanıcı"
                : _isimController.text,
        "email": _emailController.text,
        "password": _passwordController.text,
        "finansalSkor": 0.0,
      });

      // 2. Local'e oturum bilgisini kaydet
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userEmail', _emailController.text);
      await prefs.setString('userName', _isimController.text);
      // 3. Beklemeden ana sayfaya uç
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainLayout()),
        );
      }
    } catch (e) {
      _showSnackBar("Sunucu hatası! Ama seni içeri alıyorum...");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainLayout()),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Icon(Icons.person_add_rounded, size: 70, color: brandGreen),
              const SizedBox(height: 16),
              Text(
                "Hesap Oluştur",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: primaryGreen,
                ),
              ),
              const Text(
                "Finansio ailesine katıl ve yönetmeye başla.",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 40),
              _inputField(
                controller: _isimController,
                hint: "Adınız Soyadınız",
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              _inputField(
                controller: _emailController,
                hint: "E-posta Adresiniz",
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 16),
              _inputField(
                controller: _passwordController,
                hint: "Şifreniz",
                icon: Icons.lock_outline,
                isPassword: true,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            "Kayıt Ol",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Zaten hesabın var mı? ",
                    style: TextStyle(color: Colors.grey),
                  ),
                  GestureDetector(
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        ),
                    child: Text(
                      "Giriş Yap",
                      style: TextStyle(
                        color: brandGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? _obscureText : false,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.grey.shade400),
          suffixIcon:
              isPassword
                  ? IconButton(
                    icon: Icon(
                      _obscureText
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed:
                        () => setState(() => _obscureText = !_obscureText),
                  )
                  : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}
