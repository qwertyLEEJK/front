import 'package:flutter/material.dart';

class TransportScreen extends StatelessWidget {
  const TransportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '교통 어쩌구',
        style: TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
  }
}