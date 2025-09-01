import 'package:flutter/material.dart';

class AppColors {
  // 이 클래스는 인스턴스화해서 사용하는 것이 아니므로 private 생성자를 만듭니다.
  AppColors._();

  // Primary Color Palette
  static const grayscale = _Grayscale();

  // Primary Color Palette
  static const primary = _Primary();

  // Secondary Color Palette
  static const secondary = _Secondary();

  // 기타 색상들
  // 이건 일단은 넣어 놨는데, 혹시나 해당 이름으로 색상 설정해 둔 게 있다면 피그마 보고 해당 색상으로 다 수정해 둘 것
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color textColor = Color(0xFF2c3e50);
  static const Color errorColor = Color(0xFFe74c3c);
}

// Grayscale 색상들을 정의하는 private 클래스
class _Grayscale {
  const _Grayscale();
  final Color s900 = const Color(0xFF212529);
  final Color s800 = const Color(0xFF343A40);
  final Color s700 = const Color(0xFF495057);
  final Color s600 = const Color(0xFF868E96);
  final Color s500 = const Color(0xFFADB5BD); // 기본 Grayscale 색상
  final Color s400 = const Color(0xFFCED4DA);
  final Color s300 = const Color(0xFFDEE2E6);
  final Color s200 = const Color(0xFFE9ECEF);
  final Color s100 = const Color(0xFFF1F3F5);
  final Color s50 = const Color(0xFFF8F9FA);
  final Color s30 = const Color(0xFFFFFFFF);
}

// Primary 색상들을 정의하는 private 클래스
class _Primary {
  const _Primary();
  final Color s900 = const Color(0xFF087F5B);
  final Color s800 = const Color(0xFF099268);
  final Color s700 = const Color(0xFF0CA678);
  final Color s600 = const Color(0xFF12B886);
  final Color s500 = const Color(0xFF20C997); // 기본 Primary 색상
  final Color s400 = const Color(0xFF38D9A9);
  final Color s300 = const Color(0xFF63E6BE);
  final Color s200 = const Color(0xFF96F2D7);
  final Color s100 = const Color(0xFFC3FAE8);
  final Color s50 = const Color(0xFFE6FCF5);
}

// Secondary 색상들을 정의하는 private 클래스
class _Secondary {
  const _Secondary();
  final Color s900 = const Color(0xFFE67700);
  final Color s800 = const Color(0xFFF08C00);
  final Color s700 = const Color(0xFFF59F00);
  final Color s600 = const Color(0xFFFAB005);
  final Color s500 = const Color(0xFFFCC419); // 기본 Secondary 색상
  final Color s400 = const Color(0xFFFFD43B);
  final Color s300 = const Color(0xFFFFE066);
  final Color s200 = const Color(0xFFFFEC99);
  final Color s100 = const Color(0xFFFFF3BF);
  final Color s50 = const Color(0xFFFFF9DB);
}