import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:midas_project/theme/app_colors.dart';
import 'package:midas_project/theme/app_theme.dart';
import 'package:midas_project/function/location_service.dart';

class SlideUpCard extends StatefulWidget {
  final VoidCallback onClose;
  final String? markerId;

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
    // LocationService 인스턴스 확보
    try {
      _locationService = Get.find<LocationService>();
    } catch (_) {
      _locationService = Get.put(LocationService());
    }

    // ⚠️ 필드는 if ( != null )로 승격이 안 됨 → 로컬 변수로 받아서 체크
    final mid = widget.markerId;
    if (mid != null && mid.isNotEmpty) {
      _locationService.setMarkerId(mid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final double bottomPadding = mediaQuery.padding.bottom;
    final double bottomInset = mediaQuery.viewInsets.bottom;
    final double navigationBarHeight = 58.0;
    final double totalBottomGap = bottomPadding + navigationBarHeight + bottomInset;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: EdgeInsets.only(bottom: totalBottomGap),
        height: 227,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.grayscale.s30,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(color: AppColors.grayscale.s100, width: 1),
          ),
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
            return const Center(child: CircularProgressIndicator());
          }

          if (error != null) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("오류 발생", style: AppTextStyles.title6),
                    Image.asset('assets/images/fill_star.png', width: 24, height: 24),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  error,
                  style: AppTextStyles.body2_1.copyWith(color: AppColors.grayscale.s600),
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

          // 위치 정보 fallback
          final locationName = location?.locationName ?? "위치 정보 없음";
          final description = location?.description ?? "위치 설명이 없습니다.";
          final floor = location?.floor ?? 0;
          final address = location?.address ?? "주소 정보 없음";
          final markerIdLabel = widget.markerId ?? "-"; // ✅ 문자열 기본값으로 통일

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
                        Text(
                          (floor > 0) ? "$floor층 | ID: $markerIdLabel" : "ID: $markerIdLabel",
                          style: AppTextStyles.body2_1.copyWith(
                            color: AppColors.grayscale.s500,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // 경로 통일 (위쪽과 동일 경로 사용)
                  Image.asset('assets/images/fill_star.png', width: 24, height: 24),
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
                            // TODO: 출발 로직
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
                            style: AppTextStyles.body1_3.copyWith(color: AppColors.grayscale.s30),
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
                            // TODO: 도착 로직
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
                            style: AppTextStyles.body1_3.copyWith(color: AppColors.primary.s500),
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
