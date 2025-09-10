// lib/widgets/slide_up_card.dart
import 'package:flutter/material.dart';
import 'package:midas_project/theme/app_colors.dart';
import 'package:midas_project/theme/app_theme.dart'; // 텍스트 스타일 테마 파일
import 'package:midas_project/theme/app_colors.dart'; // 색상 테마 파일
import '1. home_screen.dart';

class SlideUpCard extends StatelessWidget {
  final VoidCallback onClose;

  const SlideUpCard({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 227,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.grayscale.s30,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
              top: BorderSide(color: AppColors.grayscale.s100, width: 1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("영남대학교 IT관", style: AppTextStyles.title6),
                Image.asset('lib/assets/images/star.png', width: 24, height: 24)
              ],
            ),
            SizedBox(height: 10),
            Text("경북 경산시 삼풍동 영남대학교 공과대학본관",
                style: AppTextStyles.body2_1
                    .copyWith(color: AppColors.grayscale.s600)),
            SizedBox(height: 16),
            Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6), // 18px → 6LP
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44, // 44px → 15LP
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: AppColors.primary.s500,
                            foregroundColor: AppColors.grayscale.s30,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            )),
                        child: Text("출발",
                            style: AppTextStyles.body1_3
                                .copyWith(color: AppColors.grayscale.s30)),
                      ),
                    ),
                  ),
                  SizedBox(width: 14), // 14px → 5LP
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
                            )),
                        child: Text("도착",
                            style: AppTextStyles.body1_3
                                .copyWith(color: AppColors.primary.s500)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Center(
              child: IconButton(
                icon: Icon(Icons.keyboard_arrow_down),
                onPressed: onClose,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
