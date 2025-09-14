import 'package:flutter/material.dart';

class NearbyPanel extends StatelessWidget {
  final ScrollController controller;
  const NearbyPanel({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    // TODO: 실제 주변 장소/카테고리 리스트로 구성
    return ListView(
      controller: controller,
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: const [
        ListTile(
          leading: Icon(Icons.local_cafe_outlined),
          title: Text('카페'), subtitle: Text('내 주변 인기 카페'),
        ),
        Divider(height: 1),
        ListTile(
          leading: Icon(Icons.restaurant_outlined),
          title: Text('음식점'), subtitle: Text('평점 높은 식당'),
        ),
        Divider(height: 1),
        ListTile(
          leading: Icon(Icons.local_hospital_outlined),
          title: Text('병원'), subtitle: Text('가까운 진료소'),
        ),
      ],
    );
  }
}
