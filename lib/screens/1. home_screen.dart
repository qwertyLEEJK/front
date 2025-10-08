// lib/screens/1. home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:midas_project/theme/app_colors.dart';
import 'package:midas_project/screens/indoor_map_screen.dart';
import 'package:midas_project/screens/outdoor_map_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.bottomInsetListenable,
    this.onRequestCollapsePanel,
  });

  final ValueListenable<double>? bottomInsetListenable;
  final Future<void> Function()? onRequestCollapsePanel;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isIndoorMode = false; // default: 실외 지도

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 지도 표시 영역
          if (_isIndoorMode)
            SafeArea(
              child: IndoorMapScreen(
                bottomInsetListenable: widget.bottomInsetListenable,
                onRequestCollapsePanel: widget.onRequestCollapsePanel,
              ),
            )
          else
            const OutdoorMapScreen(),

          // 실내/실외 전환 버튼
          Positioned(
            top: 80, // 👈 검색창 아래로 내림 (기존 16 → 80)
            right: 16,
            child: SafeArea(
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.grayscale.s200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _MapToggleButton(
                        label: '실외',
                        icon: Icons.map,
                        isSelected: !_isIndoorMode,
                        onTap: () {
                          debugPrint('실외 버튼 클릭');
                          setState(() => _isIndoorMode = false);
                        },
                      ),
                      Container(
                        width: 1,
                        height: 32,
                        color: AppColors.grayscale.s200,
                      ),
                      _MapToggleButton(
                        label: '실내',
                        icon: Icons.store,
                        isSelected: _isIndoorMode,
                        onTap: () {
                          debugPrint('실내 버튼 클릭');
                          setState(() => _isIndoorMode = true);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapToggleButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _MapToggleButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondary.s800 : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : AppColors.grayscale.s600,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.grayscale.s600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
