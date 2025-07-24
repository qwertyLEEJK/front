import 'package:capston/screens/campus_map_screen.dart';
import 'package:flutter/material.dart';
import '../screens/bus_info_screen.dart';
import '../screens/login_screen.dart';
import '../screens/departure_search_screen.dart';

class BottomNavBar extends StatelessWidget {
  final bool navigating;
  final VoidCallback onStopNavigation;

  const BottomNavBar({
    super.key,
    required this.navigating,
    required this.onStopNavigation,
  });

  // void _goToMain(BuildContext context) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (_) => const CampusMapScreen()),
  //   );
  // }
  //
  // void _goToBusInfo(BuildContext context) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (_) => const BusInfoScreen()),
  //   );
  // }
  //
  // void _goLoginInfo(BuildContext context) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (_) => const LoginScreen()),
  //   );
  // }
  //
  // void _goToDepartureSearch(BuildContext context) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (_) => const DepartureSearchScreen()),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: navigating
          ? Row(
        children: [
          const Text(
            '12:34 PM • 845m',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const Spacer(),
          TextButton(
            onPressed: onStopNavigation,
            child: const Text('안내 종료'),
          ),
        ],
      )
          : Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(context, Icons.home_outlined, "메인", () => _goToMain),
          _buildNavItem(context, Icons.map_outlined, "지도", () {}),
          _buildNavItem(context, Icons.search, "검색", () => _goToDepartureSearch(context)),
          _buildNavItem(context, Icons.directions_bus_outlined, "대중교통", () => _goToBusInfo(context)),
          _buildNavItem(context, Icons.account_circle_outlined, "내 정보", () => _goLoginInfo(context)),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
