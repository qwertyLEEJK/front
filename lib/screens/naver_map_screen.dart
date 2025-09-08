import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

class NaverMapScreen extends StatelessWidget {
  const NaverMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const NaverMap(
      options: NaverMapViewOptions(
        initialCameraPosition: NCameraPosition(
          target: NLatLng(37.5666102, 126.9783881), // 서울 시청 (기본값)
          zoom: 15,
        ),
      ),
    );
  }
}
