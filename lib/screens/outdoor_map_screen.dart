import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:midas_project/function/sensor_controller.dart';

class OutdoorMapScreen extends StatefulWidget {
  const OutdoorMapScreen({super.key});

  @override
  State<OutdoorMapScreen> createState() => _OutdoorMapScreenState();
}

class _OutdoorMapScreenState extends State<OutdoorMapScreen> {
  NaverMapController? _controller;
  bool _mapInitialized = false; // ✅ onMapReady 반복 방지용 플래그

  @override
  void initState() {
    super.initState();
    _initLocationPermission();
  }

  Future<void> _initLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
  }

  Future<Position?> _getCurrentPosition() async {
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      debugPrint('위치 불러오기 실패: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        NaverMap(
          onMapReady: (controller) async {
            if (_mapInitialized) return; // ✅ 무한 호출 방지
            _mapInitialized = true;

            _controller = controller;
            final pos = await _getCurrentPosition();
            if (pos != null && mounted) {
              controller.updateCamera(
                NCameraUpdate.scrollAndZoomTo(
                  target: NLatLng(pos.latitude, pos.longitude),
                  zoom: 16,
                ),
              );
            }
          },
          options: const NaverMapViewOptions(
            initialCameraPosition: NCameraPosition(
              target: NLatLng(37.5666102, 126.9783881), // 기본 서울 좌표
              zoom: 15,
            ),
          ),
        ),
        Positioned(
          top: 40,
          left: 16,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('뒤로'),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller = null;
    super.dispose();
  }
}
