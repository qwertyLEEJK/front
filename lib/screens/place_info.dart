import 'package:flutter/material.dart';
import 'package:midas_project/theme/app_colors.dart';
import 'package:midas_project/theme/app_theme.dart';
import 'package:midas_project/screens/1. home_screen.dart';

class SlideUpCard extends StatelessWidget {
  final VoidCallback onClose;
  final int? markerId;

  const SlideUpCard({
    super.key,
    required this.onClose,
    this.markerId,
  });

  @override
  Widget build(BuildContext context) {
    // MediaQuery를 통해 안전 영역과 네비게이션 바 높이를 정확히 계산
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double bottomPadding = mediaQuery.padding.bottom; // 안전 영역
    final double bottomInset = mediaQuery.viewInsets.bottom; // 키보드 등

    // 네비게이션 바가 있다면 추가 여백 (일반적으로 56-80px)
    final double navigationBarHeight = 80.0; // 앱의 네비게이션 바 높이에 맞게 조정

    // 총 하단 여백 계산
    final double totalBottomGap =
        bottomPadding + navigationBarHeight + bottomInset;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: EdgeInsets.only(
          bottom: totalBottomGap,
          left: 16,
          right: 16,
        ),
        height: 227,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.grayscale.s30,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(color: AppColors.grayscale.s100, width: 1),
          ),
          // 그림자 추가로 더 자연스럽게
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("영남대학교 IT관", style: AppTextStyles.title6),
                Image.asset('lib/assets/images/fill_star.png',
                    width: 24, height: 24),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              "경북 경산시 삼풍동 영남대학교 공과대학본관",
              style: AppTextStyles.body2_1
                  .copyWith(color: AppColors.grayscale.s600),
            ),
            const SizedBox(height: 16),
            const Spacer(),
            // 액션 버튼
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: AppColors.primary.s500,
                          foregroundColor: AppColors.grayscale.s30,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: Text(
                          "출발",
                          style: AppTextStyles.body1_3
                              .copyWith(color: AppColors.grayscale.s30),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: AppColors.primary.s50,
                          foregroundColor: AppColors.primary.s500,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: Text(
                          "도착",
                          style: AppTextStyles.body1_3
                              .copyWith(color: AppColors.primary.s500),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Center(
              child: IconButton(
                icon: const Icon(Icons.keyboard_arrow_down),
                onPressed: onClose,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
