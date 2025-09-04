import 'package:flutter/material.dart';
import 'package:midas_project/screens/place_info.dart'; // place_info.dart 파일 import

void main() {
  runApp(const TestPlaceInfoApp());
}

class TestPlaceInfoApp extends StatelessWidget {
  const TestPlaceInfoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Place Info Test',
      debugShowCheckedModeBanner: false,
      home: Scaffold( // Scaffold를 추가하여 기본적인 앱 구조를 제공
        appBar: AppBar(title: const Text('Place Info Test')),
        body: Center(
          child: SlideUpCard(
            onClose: () {
              // 테스트를 위한 간단한 닫기 동작 (예: 콘솔 출력 또는 아무것도 안 함)
              print('SlideUpCard closed');
            },
          ),
        ),
      ),
    );
  }
}
