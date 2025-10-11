import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';

// ----------------------------
// 상태 접근용 static holder
// ----------------------------
class OutdoorMapScreenStateHolder {
  static _OutdoorMapScreenState? state;
}

// =============================
// OutdoorMapScreen 본체
// =============================
class OutdoorMapScreen extends StatefulWidget {
  const OutdoorMapScreen({super.key});

  @override
  State<OutdoorMapScreen> createState() => _OutdoorMapScreenState();
}

class _OutdoorMapScreenState extends State<OutdoorMapScreen> {
  NaverMapController? _controller;
  bool _mapInitialized = false;
  bool _isLoading = true;

  StreamSubscription<Position>? _posSub; // 위치 스트림 구독

  @override
  void initState() {
    super.initState();
    OutdoorMapScreenStateHolder.state = this;
    _initLocationPermission();
  }

  @override
  void dispose() {
    OutdoorMapScreenStateHolder.state = null;
    _posSub?.cancel();
    _controller = null;
    super.dispose();
  }

  // ----------------------------
  // 위치 권한 초기화
  // ----------------------------
  Future<void> _initLocationPermission() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('위치 서비스 비활성화');
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('위치 권한 거부됨');
          if (mounted) setState(() => _isLoading = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('위치 권한 영구 거부됨');
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('위치 권한 확인 오류: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ----------------------------
  // 현재 위치 가져오기
  // ----------------------------
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

  // ----------------------------
  // HomeScreen에서 호출하는 카메라 이동
  // ----------------------------
  Future<void> moveToCurrentLocation() async {
    final pos = await _getCurrentPosition();
    if (pos != null && _controller != null) {
      await _controller!.updateCamera(
        NCameraUpdate.scrollAndZoomTo(
          target: NLatLng(pos.latitude, pos.longitude),
          zoom: 16,
        ),
      );
    } else {
      debugPrint('현재 위치 정보 없음 또는 컨트롤러 미초기화');
    }
  }

  // ----------------------------
  // 지도 준비 완료 콜백
  // ----------------------------
  Future<void> _onMapReady(NaverMapController controller) async {
    if (_mapInitialized) return;
    _controller = controller;
    _mapInitialized = true;

    try {
      // 오버레이 보이기 + 스타일(주황색 원)
      // TODO: 스타일 수정 (실내 마커와 동일 디자인 적용)
      final overlay = await _controller!.getLocationOverlay();
      overlay.setIsVisible(true);
      overlay.setCircleColor(const Color(0x59FF9800)); // 약 35% 알파
      overlay.setCircleOutlineColor(const Color(0xFFFFB74D));
      overlay.setCircleOutlineWidth(2.0);

      // 최초 한 번 현재 위치 적용 (마커 제자리 방지)
      final p0 = await _getCurrentPosition();
      if (p0 != null) {
        overlay.setPosition(NLatLng(p0.latitude, p0.longitude));
      }

      // 위치 스트림 구독 → 오버레이 좌표 실시간 갱신 (마커가 내 위치를 “따라” 움직임)
      _posSub = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 1, // 1m 이상 이동 시 업데이트
        ),
      ).listen((pos) async {
        try {
          final o = await _controller?.getLocationOverlay();
          o?.setPosition(NLatLng(pos.latitude, pos.longitude));
        } catch (e) {
          debugPrint('오버레이 위치 갱신 오류: $e');
        }
      });
    } catch (e) {
      debugPrint('오버레이 설정 오류: $e');
    }

    // 카메라는 버튼으로만 이동 (기존 동작 유지)
    // await moveToCurrentLocation();
  }

  // ----------------------------
  // UI 빌드
  // ----------------------------
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          NaverMap(
            onMapReady: _onMapReady,
            options: const NaverMapViewOptions(
              initialCameraPosition: NCameraPosition(
                target: NLatLng(35.8355, 128.7537), // 영남대 기본 좌표
                zoom: 15,
              ),
              indoorEnable: false,
              locationButtonEnable: false, // 직접 만든 버튼 사용
              consumeSymbolTapEvents: false,
            ),
          ),
        ],
      ),
    );
  }
}
