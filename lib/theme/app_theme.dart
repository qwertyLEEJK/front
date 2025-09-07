import 'package:flutter/material.dart';
import 'package:midas_project/theme/app_colors.dart';

// --- 폰트 Family 이름 ---
const String pretendardFontFamily = 'Pretendard';

// --- 텍스트 스타일 정의 ---
class AppTextStyles {
  // Title
  static final TextStyle title1 = TextStyle(
    fontFamily: pretendardFontFamily,
    fontSize: 40,
    fontWeight: FontWeight.w700, // Bold
    //height: 0.16, // 행간 16%
  );

  static final TextStyle title2 = TextStyle(
    fontFamily: pretendardFontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w700, // Bold
    //height: 0.16,
  );

  static final TextStyle title3 = TextStyle(
    fontFamily: pretendardFontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700, // Bold
    //height: 0.16,
  );

  static final TextStyle title4 = TextStyle(
    fontFamily: pretendardFontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700, // Bold
    //height: 0.16,
  );

  static final TextStyle title5 = TextStyle(
    fontFamily: pretendardFontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700, // Bold
    //height: 0.16,
  );

  static final TextStyle title6 = TextStyle(
    fontFamily: pretendardFontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700, // Bold
    //height: 0.16,
  );

  static final TextStyle title7 = TextStyle(
    fontFamily: pretendardFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700, // Bold
    //height: 0.16,
  );

  // Body
  static final TextStyle body1_1 = TextStyle(
    fontFamily: pretendardFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400, // Regular
    //height: 0.16,
  );

  static final TextStyle body1_2 = TextStyle(
    fontFamily: pretendardFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600, // SemiBold
    //height: 0.16,
  );

  static final TextStyle body1_3 = TextStyle(
    fontFamily: pretendardFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700, // Bold
    //height: 0.16,
  );

  static final TextStyle body2_1 = TextStyle(
    fontFamily: pretendardFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400, // Regular
    //height: 0.16,
  );

  static final TextStyle body2_2 = TextStyle(
    fontFamily: pretendardFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600, // SemiBold
    //height: 0.16,
  );

  static final TextStyle body2_3 = TextStyle(
    fontFamily: pretendardFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w700, // Bold
    //height: 0.16,
  );

  // Caption
  static final TextStyle caption1_1 = TextStyle(
    fontFamily: pretendardFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400, // Regular
    //height: 0.16,
  );

  static final TextStyle caption1_2 = TextStyle(
    fontFamily: pretendardFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600, // SemiBold
    //height: 0.16,
  );

  static final TextStyle caption2_1 = TextStyle(
    fontFamily: pretendardFontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w400, // Regular
    //height: 0.16,
  );

  static final TextStyle caption2_2 = TextStyle(
    fontFamily: pretendardFontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w600, // SemiBold
    //height: 0.16,
  );
}


// --- 앱 테마 정의 ---
final ThemeData appThemeData = ThemeData(
  primaryColor: AppColors.primary.s500,
  scaffoldBackgroundColor: AppColors.grayscale.s30,
  // 앱 전체의 기본 폰트를 Pretendard로 설정
  fontFamily: pretendardFontFamily,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primary.s500,
    secondary: AppColors.secondary.s500,
    error: AppColors.secondary.s500,
    background: AppColors.grayscale.s30,
  ),
  textTheme: TextTheme().apply(
    bodyColor: AppColors.grayscale.s900,
    displayColor: AppColors.grayscale.s900
  ),

  // 앱바 테마 설정
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.primary.s500,
    titleTextStyle: TextStyle(
      fontFamily: pretendardFontFamily,
      fontSize: 18,
      fontWeight: FontWeight.w700, // Bold
      color: Colors.white,
    ),
    iconTheme: IconThemeData(color: Colors.white),
  ),

  // 버튼 테마 설정
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary.s500,
      foregroundColor: Colors.white,
      textStyle: AppTextStyles.body1_3, // Body1_3 (Bold) 스타일 사용
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  ),
);