import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final VoidCallback? onSearch;

  const CustomSearchBar({
    super.key,
    this.controller,
    this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Colors.grey,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(5),
          // boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: Row(
          children: [
            const SizedBox(width: 18),
            Expanded(
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: '검색',
                  border: InputBorder.none,
                  isCollapsed: true,
                ),
                onSubmitted: (_) => onSearch?.call(),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: onSearch,
            ),
          ],
        ),
      ),
    );
  }
}
