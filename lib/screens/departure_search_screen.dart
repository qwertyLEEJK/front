import 'package:flutter/material.dart';
import 'package:midas_project/theme/app_theme.dart';

class DepartureSearchScreen extends StatelessWidget {
  const DepartureSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('출발지 검색')),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: '도착지 검색',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.grey[300],
              alignment: Alignment.center,
              child: Text(
                '도착지 검색 히스토리',
                style: AppTextStyles.title6,
              ),
            ),
          )
        ],
      ),
    );
  }
}
