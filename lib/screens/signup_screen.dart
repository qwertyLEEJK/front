import 'package:flutter/material.dart';
import 'package:midas_project/theme/app_colors.dart';
import 'package:midas_project/theme/app_theme.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _idController = TextEditingController();
  final _pwController = TextEditingController();
  final _confirmPwController = TextEditingController();

  bool _obscurePw = true;
  bool _obscureConfirmPw = true;

  @override
  void dispose() {
    _idController.dispose();
    _pwController.dispose();
    _confirmPwController.dispose();
    super.dispose();
  }

  void _signup() {
    // TODO: 서버와 연동해서 회원가입 처리
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grayscale.s30,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              children: [
                const SizedBox(height: 80),
                Text(
                  '회원가입',
                  style: AppTextStyles.title1.copyWith(
                    color: AppColors.primary.s500,
                  ),
                ),
                const SizedBox(height: 40),

                _buildTextField(
                  controller: _idController,
                  hintText: '아이디',
                ),
                _buildTextField(
                  controller: _pwController,
                  hintText: '비밀번호',
                  obscureText: _obscurePw,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePw ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePw = !_obscurePw;
                      });
                    },
                  ),
                ),
                _buildTextField(
                  controller: _confirmPwController,
                  hintText: '비밀번호 확인',
                  obscureText: _obscureConfirmPw,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPw ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPw = !_obscureConfirmPw;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 32),

                GestureDetector(
                  onTap: _signup,
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primary.s500,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '회원가입',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.title7.copyWith(color: AppColors.grayscale.s30, height: 1.0),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('이미 계정이 있으신가요?'),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                      },
                      child: const Text('로그인'),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: AppColors.grayscale.s500),
          filled: true,
          fillColor: AppColors.grayscale.s30,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.grayscale.s500, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.grayscale.s500, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.grayscale.s500, width: 2),
          ),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}