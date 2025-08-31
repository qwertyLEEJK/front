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
  final TextEditingController _searchController = TextEditingController();

  void _onSearch() {
    print("검색어: ${_searchController.text}");
  }

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  bool get _showSearchBar => _currentIndex != 4; // 내정보 탭만 검색창 제외

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
              CustomSearchBar(
                controller: _searchController,
                onSearch: _onSearch,
              ),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: const [
                  HomeScreen(),
                  TransportScreen(),
                  MapScreen(),
                  SearchScreen(),
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
