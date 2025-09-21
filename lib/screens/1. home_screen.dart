// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // ValueListenable
import 'dart:async';
import 'package:get/get.dart';
import 'package:midas_project/theme/app_colors.dart';
import 'package:midas_project/theme/app_theme.dart';
import '../function/sensor_controller.dart';
import '../function/prediction_service.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'dart:math' as math;
import 'package:midas_project/screens/place_info.dart';
import 'package:midas_project/function/location_info.dart'; // ✅ 좌표/스케일 정보 불러오기

// ===== 네이버 현재위치 스타일 마커 =====
class NaverCurrentLocationMarker extends StatelessWidget {
  final double radius;
  final double headingDeg;
  const NaverCurrentLocationMarker({super.key, this.radius = 28, this.headingDeg = 0});

  @override
  Widget build(BuildContext context) {
    final double size = radius * 2;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(alignment: Alignment.center, children: [
        // 정확도 원
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.secondary.s800.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
        ),
        // 방위 삼각형
        Transform.rotate(
          angle: (headingDeg + 180) * math.pi / 180.0,
          child: CustomPaint(size: const Size(20, 20), painter: _HeadingTrianglePainter()),
        ),
        // 흰 링
        Container(
          width: 18, height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.grayscale.s30, width: 2),
          ),
        ),
        // 파란 점
        Container(
          width: 10, height: 10,
          decoration: BoxDecoration(color: AppColors.secondary.s800, shape: BoxShape.circle),
        ),
      ]),
    );
  }
}

class _HeadingTrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint fill = Paint()..color = AppColors.secondary.s800;
    final Paint stroke = Paint()
      ..color = AppColors.secondary.s800
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    final double w = size.width, h = size.height;
    final Path tri = Path()
      ..moveTo(w / 2, 0)
      ..lineTo(w * 0.25, h * 0.375)
      ..lineTo(w * 0.75, h * 0.375)
      ..close();

    canvas.translate(0, -7);
    canvas.drawPath(tri, fill);
    canvas.drawPath(tri, stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.bottomInsetListenable,
    this.onRequestCollapsePanel, // 바깥 탭/마커 탭에서 호출
  });

  final ValueListenable<double>? bottomInsetListenable;
  final Future<void> Function()? onRequestCollapsePanel;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int? selectedPredictionIndex;
  Timer? _pollTimer;

  final TransformationController _transformationController = TransformationController();
  double _lastViewportWidth = 0, _lastViewportHeight = 0, _lastImageWidth = 0, _lastImageHeight = 0;

  double _headingDeg = 0.0;
  StreamSubscription<CompassEvent>? _compassSub;

  final SensorController _sensor = Get.put(SensorController());

  // 서버 앵커 & PDR 앵커
  Offset? _anchorServerImgPx;
  double _anchorPdrX = 0.0, _anchorPdrY = 0.0;

  // 융합 결과
  Offset? _fusedPx;

  // 맵 보정
  double _pxPerMeter = 20.0; // 초기값, initState에서 보정됨
  double _mapRotationDeg = 0;

  // 실시간 UI 틱(≈15Hz)
  Timer? _uiTicker;

  // ★ top_k_results (서버 문자열 그대로)
  List<String> _topK = [];

  @override
  void initState() {
    super.initState();

    // ✅ 실측 기반 자동 보정
    _pxPerMeter = computePxPerMeter();
    print("✅ 보정된 pxPerMeter = $_pxPerMeter");

    // 방위(heading)
    _compassSub = FlutterCompass.events?.listen((event) {
      final d = event.heading;
      if (d != null && mounted) setState(() => _headingDeg = d);
    });

    // 서버 폴링(2s)
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) => fetchPredictionAndUpdateAnchor());

    // PDR 보간(66ms)
    _uiTicker = Timer.periodic(const Duration(milliseconds: 66), (_) => _updateFusedPosition());

    fetchPredictionAndUpdateAnchor();
  }

  @override
  void dispose() {
    _uiTicker?.cancel();
    _pollTimer?.cancel();
    _compassSub?.cancel();
    _transformationController.dispose();
    super.dispose();
  }

  void _onMapBlankTap() {
    final collapse = widget.onRequestCollapsePanel;
    if (collapse != null) collapse();
  }

  Future<void> _openPlaceSheet({int? markerId}) async {
    if (widget.onRequestCollapsePanel != null) {
      await widget.onRequestCollapsePanel!.call();
    }
    if (!mounted) return;
    await showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.transparent,
      useSafeArea: true,
      builder: (ctx) => SlideUpCard(
        onClose: () => Navigator.pop(ctx),
        markerId: markerId ?? selectedPredictionIndex,
      ),
    );
  }

  // 서버 포인트 수신 → 앵커 갱신
  void fetchPredictionAndUpdateAnchor() async {
    final request = _sensor.getCurrentSensorValues();
    final result = await PredictApi.fetchPrediction(request);

    if (result != null) {
      setState(() {
        selectedPredictionIndex = result.num;
        _topK = result.topKRaw;
      });

      final idx = markerApiValues.indexOf(result.num);
      if (idx >= 0 && idx < markerList.length) {
        final newAnchor = Offset(
          (markerList[idx]['x'] as num).toDouble(),
          (markerList[idx]['y'] as num).toDouble(),
        );

        // ===== 스무딩 필터 (미터 단위 threshold) =====
        const double thresholdM = 3.0; // 3m 이상 튀면 outlier
        final double thresholdPx = thresholdM * _pxPerMeter;

        final currentPos = _fusedPx ?? _anchorServerImgPx;
        if (currentPos != null) {
          final distPx = (newAnchor - currentPos).distance;
          if (distPx > thresholdPx) {
            _anchorServerImgPx = Offset.lerp(currentPos, newAnchor, 0.2);
          } else {
            _anchorServerImgPx = newAnchor;
          }
        } else {
          _anchorServerImgPx = newAnchor;
        }

        // PDR anchor 갱신
        final st = _sensor.pdr.getState();
        _anchorPdrX = (st['posX'] as num).toDouble();
        _anchorPdrY = (st['posY'] as num).toDouble();
      }
    }
  }

  Offset _rotate(Offset v, double deg) {
    final r = deg * math.pi / 180.0, c = math.cos(r), s = math.sin(r);
    return Offset(c * v.dx - s * v.dy, s * v.dx + c * v.dy);
  }

  void _updateFusedPosition() {
    if (!mounted || _anchorServerImgPx == null || _lastImageWidth == 0 || _lastImageHeight == 0) return;

    final st = _sensor.pdr.getState();
    final dxM = (st['posX'] as num).toDouble() - _anchorPdrX;
    final dyM = (st['posY'] as num).toDouble() - _anchorPdrY;

    final rotated = _rotate(Offset(dxM, dyM), _mapRotationDeg);

    final dxPx = rotated.dx * _pxPerMeter;
    final dyPx = -rotated.dy * _pxPerMeter;

    final anchorScaled = Offset(
      (_anchorServerImgPx!.dx / imageOriginWidth) * _lastImageWidth,
      (_anchorServerImgPx!.dy / imageOriginHeight) * _lastImageHeight,
    );

    final fused = anchorScaled + Offset(dxPx, dyPx);

    setState(() {
      _fusedPx = Offset(
        fused.dx.clamp(0.0, _lastImageWidth),
        fused.dy.clamp(0.0, _lastImageHeight),
      );
    });
  }

  void _centerOnCurrentMarker() {
    if (_lastViewportWidth == 0 || _lastViewportHeight == 0 || _lastImageWidth == 0 || _lastImageHeight == 0) return;

    final target = _fusedPx ??
        (_anchorServerImgPx == null
            ? null
            : Offset(
          (_anchorServerImgPx!.dx / imageOriginWidth) * _lastImageWidth,
          (_anchorServerImgPx!.dy / imageOriginHeight) * _lastImageHeight,
        ));
    if (target == null) return;

    const scale = 1.0;
    final tx = (_lastViewportWidth / 2) - (target.dx * scale);
    final ty = (_lastViewportHeight / 2) - (target.dy * scale);

    _transformationController.value = Matrix4.identity()
      ..translate(tx, ty)
      ..scale(scale);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          final displayHeight = constraints.maxHeight;
          final displayWidth = imageOriginWidth * (displayHeight / imageOriginHeight);

          _lastViewportWidth = constraints.maxWidth;
          _lastViewportHeight = displayHeight;
          _lastImageWidth = displayWidth;
          _lastImageHeight = displayHeight;

          return Stack(children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _onMapBlankTap,
                child: InteractiveViewer(
                  transformationController: _transformationController,
                  panEnabled: true,
                  minScale: 1,
                  maxScale: 5,
                  constrained: false,
                  boundaryMargin: const EdgeInsets.all(200),
                  child: SizedBox(
                    width: displayWidth,
                    height: displayHeight,
                    child: Stack(children: [
                      Image.asset(
                        'lib/assets/3map.png',
                        fit: BoxFit.fill,
                        width: displayWidth,
                        height: displayHeight,
                      ),
                      ...markerList.asMap().entries.map((entry) {
                        final i = entry.key;
                        final m = entry.value;
                        final markerApiValue = (i < markerApiValues.length)
                            ? markerApiValues[i]
                            : null;

                        final mx = (m['x'] as num).toDouble();
                        final my = (m['y'] as num).toDouble();

                        final scaledLeft = (mx / imageOriginWidth) * displayWidth;
                        final scaledTop = (my / imageOriginHeight) * displayHeight;

                        final isCurrent = selectedPredictionIndex != null && markerApiValue == selectedPredictionIndex;
                        final markerSize = 20.0;

                        return Positioned(
                          left: scaledLeft - (markerSize / 2),
                          top: scaledTop - (markerSize / 2),
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => _openPlaceSheet(markerId: markerApiValue),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: markerSize,
                                  height: markerSize,
                                  decoration: BoxDecoration(
                                    color: isCurrent
                                        ? AppColors.secondary.s800
                                        : AppColors.secondary.s800.withOpacity(0.6),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.grayscale.s30, width: 2),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "${markerApiValue ?? '-'}",
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      if (_fusedPx != null)
                        Positioned(
                          left: _fusedPx!.dx - 28,
                          top: _fusedPx!.dy - 28,
                          child: GestureDetector(
                            onTap: () => _openPlaceSheet(markerId: selectedPredictionIndex),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                NaverCurrentLocationMarker(radius: 28, headingDeg: _headingDeg),
                                const SizedBox(height: 2),
                                Text(
                                  "${selectedPredictionIndex ?? '-'}",
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),
                      Positioned(
                        left: 8,
                        top: 8,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.grayscale.s900.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'API값: ${selectedPredictionIndex ?? '-'}',
                                style: AppTextStyles.title7.copyWith(color: AppColors.grayscale.s30),
                              ),
                            ),
                            const SizedBox(height: 6),
                            if (_topK.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.grayscale.s900.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: List.generate(_topK.length, (i) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 2),
                                      child: Text(
                                        _topK[i],
                                        style: AppTextStyles.title7.copyWith(color: AppColors.grayscale.s30),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
            ),
            ValueListenableBuilder<double>(
              valueListenable: widget.bottomInsetListenable ?? ValueNotifier<double>(0),
              builder: (_, panelH, __) {
                final bottom = 16 + panelH;
                return Positioned(
                  right: 16,
                  bottom: bottom,
                  child: InkWell(
                    onTap: _centerOnCurrentMarker,
                    borderRadius: BorderRadius.circular(32),
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.grayscale.s30,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.grayscale.s200),
                      ),
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: Image.asset(
                          'lib/assets/images/target.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ]);
        }),
      ),
    );
  }
}
