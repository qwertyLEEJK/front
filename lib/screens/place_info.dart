import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:midas_project/theme/app_colors.dart';
import 'package:midas_project/theme/app_theme.dart';
import 'package:midas_project/function/location_service.dart';

class SlideUpCard extends StatefulWidget {
  final VoidCallback onClose;
  final int? markerId;

  const SlideUpCard({
    super.key,
    required this.onClose,
    this.markerId,
  });

  @override
  State<SlideUpCard> createState() => _SlideUpCardState();
}

class _SlideUpCardState extends State<SlideUpCard> {
  late final LocationService _locationService;

  @override
  void initState() {
    super.initState();
    // LocationService 인스턴스 가져오기 (없으면 생성)
    _locationService = Get.find<LocationService>();
    
    // markerId가 있으면 해당 위치 정보 로드
    if (widget.markerId != null) {
      _locationService.setMarkerId(widget.markerId);
    }
  }

  @override
  Widget build(BuildContext context) {
    // MediaQuery를 통해 안전 영역과 네비게이션 바 높이를 정확히 계산
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double bottomPadding = mediaQuery.padding.bottom; // 안전 영역
    final double bottomInset = mediaQuery.viewInsets.bottom; // 키보드 등

    // 네비게이션 바가 있다면 추가 여백 (일반적으로 56-80px)
    final double navigationBarHeight = 58.0; // 앱의 네비게이션 바 높이에 맞게 조정

    // 총 하단 여백 계산
    final double totalBottomGap =
        bottomPadding + navigationBarHeight + bottomInset;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: EdgeInsets.only(
          bottom: totalBottomGap,
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
        child: Obx(() {
          final isLoading = _locationService.loading.value;
          final location = _locationService.location.value;
          final error = _locationService.error.value;
          
          if (isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          if (error != null) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("오류 발생", style: AppTextStyles.title6),
                    Image.asset('assets/images/fill_star.png',
                        width: 24, height: 24),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  error,
                  style: AppTextStyles.body2_1
                      .copyWith(color: AppColors.grayscale.s600),
                ),
                const Spacer(),
                Center(
                  child: IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down),
                    onPressed: widget.onClose,
                  ),
                ),
              ],
            );
          }
          
          // 위치 정보가 없을 때 기본값 표시
          final locationName = location?.locationName ?? "위치 정보 없음";
          final description = location?.description ?? "위치 설명이 없습니다.";
          final floor = location?.floor ?? 0;
          final address = location?.address ?? "주소 정보 없음";
          final markerId = widget.markerId ?? 0;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          address,
                          style: AppTextStyles.title6,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (floor > 0)
                          Text(
                            "$floor층 | ID: $markerId",
                            style: AppTextStyles.body2_1.copyWith(
                              color: AppColors.grayscale.s500,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Image.asset('lib/assets/images/fill_star.png',
                      width: 24, height: 24),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                locationName,
                style: AppTextStyles.body2_1.copyWith(
                  color: AppColors.grayscale.s500,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              const Expanded(child: SizedBox()),
              // 액션 버튼
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          onPressed: () {
                            // 출발 버튼 로직 구현
                          },
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
                          onPressed: () {
                            // 도착 버튼 로직 구현
                          },
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
                  onPressed: widget.onClose,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}