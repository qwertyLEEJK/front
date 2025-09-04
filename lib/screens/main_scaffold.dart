import 'package:flutter/material.dart';
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

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // ✨ 이 부분이 수정되었습니다.
  // 검색 탭(인덱스 3)과 내정보 탭(인덱스 4)에서 검색창 숨기기
  bool get _showSearchBar => _currentIndex != 3 && _currentIndex != 4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_showSearchBar)
              Padding(
                padding: const EdgeInsets.only(
                  top: 16.0,
                  left: 20.0,
                  right: 20.0,
                ),
                // CustomSearchBar를 파라미터 없이 호출합니다.
                child: CustomSearchBar(),
              ),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: const [
                  HomeScreen(),
                  TransportScreen(),
                  MapScreen(),
                  SearchScreen(), // 자체 검색창을 가진 화면
                  ProfileScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}