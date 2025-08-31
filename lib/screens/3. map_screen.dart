import 'package:flutter/material.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '주변 어쩌구',
        style: TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
  }
}