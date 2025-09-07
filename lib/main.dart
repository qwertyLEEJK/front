import 'package:flutter/material.dart';
import 'package:midas_project/theme/app_theme.dart'; // 테마 파일 import
import 'screens/auth_choice_screen.dart'; // 여기 경로만 수정
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  KakaoSdk.init(nativeAppKey : 'd3d5da14ab19ade1029f19a41f04e173');

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
      theme: appThemeData, // 테마 적용
      debugShowCheckedModeBanner: false,
      home: AuthChoiceScreen(), // 정상 연결됨
    );
  }
}