import 'package:flutter/material.dart';

class DirectionsPanel extends StatelessWidget {
  final ScrollController controller;
  const DirectionsPanel({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    // TODO: 출발/도착 입력 + 경로 옵션 UI로 확장
    return ListView(
      controller: controller,
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          decoration: const InputDecoration(
            labelText: '출발지',
            prefixIcon: Icon(Icons.my_location_outlined),
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) {},
        ),
        const SizedBox(height: 12),
        TextField(
          decoration: const InputDecoration(
            labelText: '도착지',
            prefixIcon: Icon(Icons.flag_outlined),
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) {},
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () {/* TODO: 경로 검색 */},
          icon: const Icon(Icons.search),
          label: const Text('경로 검색'),
        ),
        const SizedBox(height: 16),
        const Divider(),
        const ListTile(
          leading: Icon(Icons.route_outlined),
          title: Text('추천 경로'),
          subtitle: Text('예상 시간 · 환승 수 · 요금'),
        ),
      ],
    );
  }
}
