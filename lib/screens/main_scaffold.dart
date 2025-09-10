import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // SystemNavigator.pop
import 'package:midas_project/theme/app_colors.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/custom_search_bar.dart';

import '1. home_screen.dart';
import '2. transport_screen.dart';
import '3. map_screen.dart';
import '4. search_screen.dart';
import '5. profile_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;
  DateTime? _lastBackPressed; // 마지막 뒤로가기 시점 기록

  void _onTap(int index) {
    setState(() => _currentIndex = index);
  }

  // 내정보 탭(인덱스 4)에서는 검색창 숨김
  bool get _showSearchBar => _currentIndex != 4;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // 기본적으로 pop을 직접 제어
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return; // 이미 pop된 경우는 무시

        final now = DateTime.now();
        // 2초 내 두 번 누르면 종료
        if (_lastBackPressed == null ||
            now.difference(_lastBackPressed!) > const Duration(seconds: 2)) {
          _lastBackPressed = now;

          final messenger = ScaffoldMessenger.of(context);
          messenger.hideCurrentSnackBar();
          messenger.showSnackBar(
            const SnackBar(
              content: Text('한 번 더 누르면 앱이 종료됩니다.'),
              duration: Duration(milliseconds: 1500),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.all(16),
            ),
          );
          // 첫 번째 뒤로가기는 막음
          return;
        }

        // 두 번째 뒤로가기는 앱 종료
        SystemNavigator.pop();
      },
      child: Scaffold(
        backgroundColor: AppColors.grayscale.s30,
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: _currentIndex,
          onTap: _onTap,
        ),
        body: SafeArea(
          child: Stack(
            children: [
              IndexedStack(
                index: _currentIndex,
                children: const [
                  HomeScreen(),
                  TransportScreen(),
                  MapScreen(),
                  SearchScreen(),
                  ProfileScreen(),
                ],
              ),
              if (_showSearchBar)
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 16.0,
                      left: 20.0,
                      right: 20.0,
                    ),
                    child: CustomSearchBar(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
