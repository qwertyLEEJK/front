import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:midas_project/theme/app_theme.dart';  // 텍스트 스타일 테마 파일
import 'package:midas_project/theme/app_colors.dart'; // 색상 테마 파일
import 'login_screen.dart';
import 'signup_screen.dart';

class AuthChoiceScreen extends StatelessWidget {
  const AuthChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grayscale.s30,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Text(
              'Title',
              style: GoogleFonts.pacifico(
                fontSize: 64,
                color: AppColors.primary.s500,
              ),
            ),
            const Spacer(),

            // 로그인 버튼
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primary.s500,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '로그인',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.title7.copyWith(color: AppColors.grayscale.s30, height: 1.0),
                  ),
                ),
              ),
            ),

            // 회원가입 버튼
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SignupScreen()),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primary.s50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '회원가입',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.title7.copyWith(color: AppColors.primary.s500, height: 1.0),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
