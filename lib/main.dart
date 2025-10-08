import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:midas_project/api/api_client.dart';
import 'package:midas_project/theme/app_theme.dart';
import 'package:midas_project/function/sensor_controller.dart';
import 'package:midas_project/function/location_service.dart';
import 'screens/auth_choice_screen.dart';
import 'screens/main_scaffold.dart';

import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ✅ .env 파일 로드
  await dotenv.load(fileName: ".env");
  
  // ✅ 네이버 맵 SDK 초기화
  final naverMapClientId = dotenv.env['NAVER_MAPS_API_KEY'] ?? '';
  if (naverMapClientId.isNotEmpty) {
    await NaverMapSdk.instance.initialize(
      clientId: naverMapClientId,
      onAuthFailed: (ex) {
        debugPrint('네이버맵 인증 실패: $ex');
      },
    );
  } else {
    debugPrint('⚠️ NAVER_MAPS_API_KEY가 .env 파일에 없습니다.');
  }
  
  // ✅ GetX 컨트롤러 초기화
  Get.put(SensorController());
  Get.put(LocationService());
  
  // 카카오 SDK 초기화
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
  final _secure = const FlutterSecureStorage();
  final ApiClient _apiClient = ApiClient();

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      // 토큰 유효성 체크
      final res = await _apiClient.get("/users/me");

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
      await _secure.delete(key: 'access_token'); // 무효 → 토큰 정리
      await _secure.delete(key: 'token_type');
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