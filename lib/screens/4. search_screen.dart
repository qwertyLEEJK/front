import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '검색창 어쩌구',
        style: TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
  }
}