import 'package:flutter/material.dart';
import 'package:midas_project/theme/app_colors.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/custom_search_bar.dart';

import '1. home_screen.dart';
import '2. transport_screen.dart';
import '3. map_screen.dart';
import '4. search_screen.dart'; // 해당 스크린 기능 수정 필요
import '5. profile_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // 내정보 탭(인덱스 4)에서는 검색창 필요 X
  bool get _showSearchBar => _currentIndex != 4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  child: CustomSearchBar(), // 가짜 검색창 (누르면 검색 페이지로 이동)이니까 파라미터 필요 X
                ),
              ),
          ],
        ),
      ),
    );
  }
}
