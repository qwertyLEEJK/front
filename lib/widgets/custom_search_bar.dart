import 'package:flutter/material.dart';
import 'package:midas_project/theme/app_colors.dart';
import 'package:midas_project/theme/app_theme.dart';

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
          color: AppColors.grayscale.s30,
          border: Border.all(
            color: AppColors.grayscale.s100,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const SizedBox(width: 18),
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: '검색',
                  hintStyle: AppTextStyles.body2_1.copyWith(color: AppColors.grayscale.s500),
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
