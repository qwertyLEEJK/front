import 'package:flutter/material.dart';
import 'package:midas_project/screens/search_screen.dart';
import 'package:midas_project/theme/app_colors.dart';
import 'package:midas_project/theme/app_theme.dart';

class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SearchScreen()),
        );
      },
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: AppColors.grayscale.s30,
          border: Border.all(
            color: AppColors.grayscale.s100,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '검색',
              style: AppTextStyles.body2_1.copyWith(color: AppColors.grayscale.s500),
            ),
            Image.asset(
              'lib/assets/images/magnifer.png', // 이미지 파일 경로
              width: 24,
              height: 24,
            ),
          ],
        ),
      ),
    );
  }
}
