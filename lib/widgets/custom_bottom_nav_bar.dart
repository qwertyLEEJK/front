import 'package:flutter/material.dart';
import 'package:midas_project/theme/app_colors.dart'; // 색상 테마 파일
import 'package:midas_project/theme/app_theme.dart'; // 텍스트 스타일 테마 파일

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
        color: AppColors.grayscale.s30,

// 상단에만 얇은 구분선을 추가

        border: Border(
          top: BorderSide(color: AppColors.grayscale.s300, width: 1.0),
        ),
      ),

// SafeArea 위젯으로 감싸서 시스템 영역을 자동으로 피함 (하단바 영역 피하도록 했는데 대신 하단바 영역 색이 검은색으로 뜨긴 함)

      child: SafeArea(
        top: false, // 상단은 안전 영역이 필요 없으므로 false

        child: Container(

          height: 58, // 아이콘과 텍스트가 실제 차지할 영역의 높이 (피그마상 38인데 실행하니까 58이 적정해 보임)

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
      '검색': 'map',
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
              'lib/assets/images/${iconName}_${isSelected ? 'selected' : 'unselected'}.png',
              width: 24,
              height: 24,
            ),
            const SizedBox(height: 2), // 아이콘과 텍스트 사이 간격

            // Text 위젯을 SizedBox로 감싸서 너비와 높이 고정
            SizedBox(
              width: 70,
              height: 12,
              child: Text(
                label,
                textAlign: TextAlign.center, // 텍스트를 중앙 정렬
                style: AppTextStyles.caption2_2.copyWith(
                  fontSize: 12, // 피그마상 height = 12이므로 글자 크기도 통일시킴
                  color: isSelected
                      ? AppColors.grayscale.s900
                      : AppColors.grayscale.s500,
                  height: 1, // height를 1로 설정하여 Text 위젯 자체의 줄 높이를 12로 만듭니다.
                ),
                maxLines: 1, // 한 줄만 표시
                overflow: TextOverflow.ellipsis, // 글자가 넘칠 경우 ...으로 표시
              ),
            ),
          ],
        ),
      ),
    );
  }
}
