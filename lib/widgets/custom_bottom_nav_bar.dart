import 'package:flutter/material.dart';
import 'package:midas_project/theme/app_colors.dart'; // 색상 테마 파일
import 'package:midas_project/theme/app_theme.dart';  // 텍스트 스타일 테마 파일

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const CustomBottomNavBar({
    super.key,
    this.currentIndex = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 하단 바 전체를 감싸는 컨테이너
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        // 상단에만 얇은 구분선을 추가
        border: Border(
          top: BorderSide(color: AppColors.grayscale.s300, width: 1.0),
        ),
      ),
      // ✅ SafeArea 위젯으로 감싸서 시스템 영역을 자동으로 피함 (동작 제대로 되는지 확인 필요)
      child: SafeArea(
        top: false, // ✅ 상단은 안전 영역이 필요 없으므로 false로 설정
        child: Container(
          // ✅ 아이콘과 텍스트가 실제로 차지할 영역의 높이를 지정 (피그마 디자인 상 38로 확인되나 실행해 보고 확인할 예정)
          height: 38,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(index: 0, label: '홈'),
              _buildNavItem(index: 1, label: '대중교통'),
              _buildNavItem(index: 2, label: '내주변'),
              _buildNavItem(index: 3, label: '검색'),
              _buildNavItem(index: 4, label: '내정보'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({required int index, required String label}) {
    final bool isSelected = currentIndex == index;
    final Map<String, String> labelToIconName = {
      '홈': 'home',
      '대중교통': 'bus',
      '내주변': 'mappoint',
      '검색': 'search',
      '내정보': 'user',
    };
    final String iconName = labelToIconName[label] ?? 'home';

    return Expanded(
      child: InkWell(
        onTap: () => onTap?.call(index),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/${iconName}_${isSelected ? 'selected' : 'unselected'}.png',
              width: 24,
              height: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: isSelected
                  ? AppTextStyles.caption1_2.copyWith(color: AppColors.grayscale.s900) // 이거 참고해서 다른 부분도 색을 테마에서 가져다 쓰는 걸로 수정
                  : AppTextStyles.caption1_1.copyWith(color: AppColors.grayscale.s500),
            ),
          ],
        ),
      ),
    );
  }
}