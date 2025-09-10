import 'package:flutter/material.dart';
import '../screens/departure_search_screen.dart';
import '../screens/login_screen.dart';
import '../screens/bus_info_screen.dart';
import '../widgets/search_box.dart';

class CampusMapScreen extends StatefulWidget {
  const CampusMapScreen({super.key});

  @override
  State<CampusMapScreen> createState() => _CampusMapScreenState();
}

class _CampusMapScreenState extends State<CampusMapScreen> {
  String _mode = '기본 모드';
  String? _locationName;
  String? _locationAddress;
  bool _showRouteInfo = false;
  String _routeMethod = '도보';
  String _routeInfoText = '도보\n5분 소요';
  bool _navigating = false;

  void _showModeSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.text_fields),
                title: const Text('기본 모드'),
                onTap: () {
                  setState(() => _mode = '기본 모드');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.format_size),
                title: const Text('큰 글자 모드'),
                onTap: () {
                  setState(() => _mode = '큰 글자 모드');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.record_voice_over),
                title: const Text('음성 모드'),
                onTap: () {
                  setState(() => _mode = '음성 모드');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleTap() {
    if (_navigating) return;
    setState(() {
      _locationName = null;
      _locationAddress = null;
      _showRouteInfo = false;
    });
  }

  void _confirmArrival() {
    setState(() {
      _showRouteInfo = true;
      _routeMethod = '도보';
      _routeInfoText = '도보\n5분 소요';
    });
  }

  void _showLocationInfo() {
    if (_navigating) return;
    setState(() {
      _locationName = '영남대학교경산캠퍼스IT관';
      _locationAddress = '경북 경산시...';
      _showRouteInfo = false;
    });
  }

  void _setRouteMethod(String method) {
    setState(() {
      _routeMethod = method;
      if (method == '대중교통') {
        _routeInfoText = '찾을 수 없습니다';
      } else {
        _routeInfoText = '도보\n5분 소요';
      }
    });
  }

  void _startNavigation() {
    setState(() {
      _navigating = true;
    });
  }

  void _stopNavigation() {
    setState(() {
      _navigating = false;
      _showRouteInfo = false;
      _locationName = null;
      _locationAddress = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            onTap: _handleTap,
            child: Container(
              color: Colors.grey[200],
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: _showLocationInfo,
                child: const Text(
                  '📍 여기에 지도 들어갈 예정',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          if (!_navigating)
            const Positioned(
              top: 40,
              left: 20,
              right: 20,
              child: SearchBox(),
            )
          else
            Positioned(
              top: 40,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                color: Colors.blue,
                child: Column(
                  children: const [
                    Icon(Icons.arrow_upward, color: Colors.white, size: 32),
                    SizedBox(height: 4),
                    Text(
                      '100m 직진',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    )
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
