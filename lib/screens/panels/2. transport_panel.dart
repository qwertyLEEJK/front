import 'package:flutter/material.dart';

class TransitPanel extends StatelessWidget {
  final ScrollController controller;
  const TransitPanel({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    // TODO: 실제 대중교통 데이터/위젯로 대체
    return ListView.separated(
      controller: controller,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (_, i) => ListTile(
        leading: const Icon(Icons.directions_bus),
        title: Text('정류장/노선 ${i + 1}'),
        subtitle: const Text('도착 정보 · 환승 · 즐겨찾기 등'),
      ),
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemCount: 20,
    );
  }
}
