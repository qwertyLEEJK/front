import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:midas_project/theme/app_theme.dart';
import 'screens/auth_choice_screen.dart';         // 로그인/회원가입 선택 화면
import 'screens/main_scaffold.dart';                      // ✅ 홈: MainScaffold 로 이동

import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  KakaoSdk.init(nativeAppKey: 'd3d5da14ab19ade1029f19a41f04e173');
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Login UI',
      theme: appThemeData,
      debugShowCheckedModeBanner: false,
      home: const AuthGate(), // 부팅 시 토큰 검사
    );
  }
}

/// 부팅 시 토큰 검사 후 자동 라우팅
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  static const _baseUrl = "http://3.36.52.161:8000";
  final _secure = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      final token = await _secure.read(key: 'access_token');
      final rawType = await _secure.read(key: 'token_type') ?? 'Bearer';
      // 서버가 'bearer'로 준 경우를 위해 헤더 표기 통일
      final type = (rawType.toLowerCase() == 'bearer') ? 'Bearer' : rawType;

      if (token == null || token.isEmpty) {
        _go(const AuthChoiceScreen());
        return;
      }

      // 토큰 유효성 체크
      final res = await http.get(
        Uri.parse("$_baseUrl/users/me"),
        headers: {
          "Authorization": "$type $token",
          "Content-Type": "application/json",
        },
      );

      if (!mounted) return;

      if (res.statusCode == 200) {
        // final data = jsonDecode(res.body); // 필요하면 파싱
        _go(const MainScaffold());                 // ✅ 유효 → 메인으로
      } else {
        await _secure.delete(key: 'access_token'); // 무효 → 토큰 정리
        await _secure.delete(key: 'token_type');
        _go(const AuthChoiceScreen());             // 로그인/회원가입 화면
      }
    } catch (e) {
      if (!mounted) return;
      _go(const AuthChoiceScreen());
    }
  }

  void _go(Widget page) {
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => page),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
