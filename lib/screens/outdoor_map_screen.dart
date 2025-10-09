import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';

class OutdoorMapScreen extends StatefulWidget {
  const OutdoorMapScreen({super.key});

  @override
  State<OutdoorMapScreen> createState() => _OutdoorMapScreenState();
}

class _OutdoorMapScreenState extends State<OutdoorMapScreen> {
  NaverMapController? _controller;
  bool _mapInitialized = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initLocationPermission();
  }

  Future<void> _initLocationPermission() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('위치 서비스가 비활성화되어 있습니다.');
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('위치 권한이 거부되었습니다.');
          if (mounted) setState(() => _isLoading = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('위치 권한이 영구적으로 거부되었습니다.');
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('위치 권한 확인 오류: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<Position?> _getCurrentPosition() async {
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5),
      );
    } catch (e) {
      debugPrint('위치 불러오기 실패: $e');
      return null;
    }
  }

  void _onMapReady(NaverMapController controller) async {
    if (_mapInitialized) return;
    _controller = controller;
    _mapInitialized = true;

    try {
      final pos = await _getCurrentPosition();
      if (pos != null && mounted && _controller != null) {
        await _controller!.updateCamera(
          NCameraUpdate.scrollAndZoomTo(
            target: NLatLng(pos.latitude, pos.longitude),
            zoom: 16,
          ),
        );
      }
    } catch (e) {
      debugPrint('카메라 이동 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          NaverMap(
            onMapReady: _onMapReady,
            options: const NaverMapViewOptions(
              initialCameraPosition: NCameraPosition(
                target: NLatLng(35.8355, 128.7537), // 영남대 좌표
                zoom: 15,
              ),
              indoorEnable: false,
              locationButtonEnable: true,
              consumeSymbolTapEvents: false,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller = null;
    super.dispose();
  }
}