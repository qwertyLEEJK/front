import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

import 'package:midas_project/screens/place_info.dart';
import 'naver_map_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1) .env 로드
  await dotenv.load(fileName: '.env');

  // 2) 키 읽기
  final clientId = dotenv.env['NAVER_MAPS_API_KEY'];
  if (clientId == null || clientId.isEmpty) {
    // 운영에서는 로깅/예외 처리로 교체
    throw Exception('NAVER_MAPS_API_KEY 가 .env 에 없습니다.');
  }

  // 3) 네이버맵 초기화 (await 필수)
  await NaverMapSdk.instance.initialize(
    clientId: clientId,
    onAuthFailed: (e) => debugPrint('NaverMap auth failed: $e'),
  );

  runApp(const TestPlaceInfoApp());
}

class TestPlaceInfoApp extends StatelessWidget {
  const TestPlaceInfoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Place Info Test',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Place Info Test')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 300,
                height: 300,
                child: NaverMapScreen(),
              ),
              const SizedBox(height: 20),
              SlideUpCard(onClose: () => print('SlideUpCard closed')),
            ],
          ),
        ),
      ),
    );
  }
}
