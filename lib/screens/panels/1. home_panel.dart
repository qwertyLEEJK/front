import 'package:flutter/material.dart';

class HomePanel extends StatelessWidget {
  final ScrollController controller;
  const HomePanel({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    // TODO: 여기에 네가 원하는 홈 패널 UI를 구성하면 됨
    return ListView.separated(
      controller: controller,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (_, i) => ListTile(
        leading: const Icon(Icons.home_outlined),
        title: Text('홈 패널 아이템 ${i + 1}'),
        subtitle: const Text('홈 관련 컨텐츠/추천/최근 위치 등'),
        onTap: () {},
      ),
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemCount: 20,
    );
  }
}
