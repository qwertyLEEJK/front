import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main_scaffold.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _idController = TextEditingController();
  final _pwController = TextEditingController();
  bool _obscureText = true;

  @override
  void dispose() {
    _idController.dispose();
    _pwController.dispose();
    super.dispose();
  }

  void _login() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const MainScaffold(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              children: [
                const SizedBox(height: 80),
                Text(
                  '환영합니다!',
                  style: GoogleFonts.pacifico(
                    fontSize: 32,
                    color: const Color(0xFF2ECC9B),
                  ),
                ),
                const SizedBox(height: 40),
                // 아이디 인풋박스
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: TextField(
                    controller: _idController,
                    decoration: InputDecoration(
                      hintText: '아이디',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.black, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.black, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.black, width: 2),
                      ),
                    ),
                  ),
                ),
                // 비밀번호 인풋박스
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: TextField(
                    controller: _pwController,
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      hintText: '비밀번호',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.black, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.black, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.black, width: 2),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2ECC9B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      '로그인',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 카카오
                    _SocialCircleButton(
                      backgroundColor: const Color(0xFFFEE500),
                      onTap: () {},
                      child: Image.asset(
                        'lib/카카오톡.png',
                        width: 40,
                        height: 40,
                      ),
                    ),
                    const SizedBox(width: 20),
                    // 구글
                    _SocialCircleButton(
                      backgroundColor: Colors.white,
                      border: Border.all(color: Colors.grey),
                      onTap: () {},
                      child: Image.asset(
                        'lib/구글.png',
                        width: 28,
                        height: 28,
                      ),
                    ),
                    const SizedBox(width: 20),
                    // 네이버
                    _SocialCircleButton(
                      backgroundColor: Colors.white,
                      onTap: () {},
                      child: Image.asset(
                        'lib/네이버.png',
                        width: 55,
                        height: 55,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 동그란 소셜 로그인 버튼 위젯
class _SocialCircleButton extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final Border? border;
  final VoidCallback onTap;

  const _SocialCircleButton({
    required this.child,
    required this.backgroundColor,
    required this.onTap,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          border: border,
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}
