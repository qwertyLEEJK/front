import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:get/get.dart';
import 'package:flutter_compass/flutter_compass.dart';

import '../function/prediction_service.dart';
import '../function/location_info.dart';
import 'place_info.dart';
import 'package:midas_project/theme/app_colors.dart';
import 'package:midas_project/theme/app_theme.dart';
import 'package:flutter/gestures.dart';
import 'package:midas_project/function/sensor_controller.dart';

const double kImageW = 3508;
const double kImageH = 1422;

// ----------------------------
// 상태 접근용 static holder
// ----------------------------
class IndoorMapScreenStateHolder {
  static _IndoorMapScreenState? state;
}

// =============================
// 현재 위치 마커 (주황색 + 방향 화살표)
// =============================
class NaverCurrentLocationMarker extends StatelessWidget {
  final double radius;
  final double headingDeg;
  const NaverCurrentLocationMarker({
    super.key,
    this.radius = 28,
    this.headingDeg = 0,
  });

  @override
  Widget build(BuildContext context) {
    final double size = radius * 2;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(alignment: Alignment.center, children: [
        // 반투명 원
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.secondary.s800.withOpacity(0.25),
            shape: BoxShape.circle,
          ),
        ),
        // 방향 화살표
        Transform.rotate(
          angle: (headingDeg + 180) * math.pi / 180.0,
          child: CustomPaint(
            size: Size(radius * 0.8, radius * 0.8),
            painter: _HeadingTrianglePainter(),
          ),
        ),
        // 안쪽 원
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.grayscale.s30, width: 2),
          ),
        ),
        // 중심점
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: AppColors.secondary.s800,
            shape: BoxShape.circle,
          ),
        ),
      ]),
    );
  }
}

class _HeadingTrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint fill = Paint()..color = AppColors.secondary.s800;
    final double w = size.width, h = size.height;
    final Path tri = Path()
      ..moveTo(w / 2, 0)
      ..lineTo(w * 0.2, h * 0.5)
      ..lineTo(w * 0.8, h * 0.5)
      ..close();
    canvas.translate(0, -size.height * 0.3);
    canvas.drawPath(tri, fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// =============================
// IndoorMapScreen 본체
// =============================
class IndoorMapScreen extends StatefulWidget {
  const IndoorMapScreen({
    super.key,
    this.bottomInsetListenable,
    this.onRequestCollapsePanel,
  });

  final ValueListenable<double>? bottomInsetListenable;
  final Future<void> Function()? onRequestCollapsePanel;

  @override
  State<IndoorMapScreen> createState() => _IndoorMapScreenState();
}

class _IndoorMapScreenState extends State<IndoorMapScreen> {
  String? selectedPredictionIndex;
  Timer? _pollTimer;

  double _headingDeg = 0.0;
  StreamSubscription<CompassEvent>? _compassSub;
  SensorController? _sensor;

  Offset? _anchorServerPx; // 서버 예측 기준 앵커
  double _anchorPdrX = 0.0, _anchorPdrY = 0.0; // PDR 앵커(상대 이동량 계산용)
  Offset? _fusedPx; // 최종 표출 좌표

  double _pxPerMeter = 20.0;
  Offset _originPx = Offset.zero;
  bool _calibrated = false;
  final bool _flipY = false;

  double _minX = 0, _minY = 0, _maxX = 0, _maxY = 0;
  Timer? _uiTicker;
  LocationGraph? _graph;
  bool _isLoading = true;

  final TransformationController _tfm = TransformationController();
  final double _initialScale = 1.0;
  final Offset _initialPan = const Offset(0, -120);

  final Offset _bgOffset = const Offset(0, -80);
  final Offset _overlayOffset = const Offset(0, 380);

  // 뷰포트(화면) 크기 추적: 중심 맞춤 정확도 향상
  Size _viewportSize = Size.zero;

  @override
  void initState() {
    super.initState();
    IndoorMapScreenStateHolder.state = this;
    _initializeAsync();
  }

  @override
  void dispose() {
    IndoorMapScreenStateHolder.state = null;
    _uiTicker?.cancel();
    _pollTimer?.cancel();
    _compassSub?.cancel();
    _tfm.dispose();
    super.dispose();
  }

  // ----------------------------
  // 초기화
  // ----------------------------
  Future<void> _initializeAsync() async {
    try {
      _sensor = Get.put(SensorController(), permanent: true);
      final g = await loadGraphFromCsv();
      if (!mounted) return;

      setState(() {
        _graph = g;
        _isLoading = false;
      });

      _calibrateScaleAndOrigin();

      _compassSub = FlutterCompass.events?.listen((event) {
        final d = event.heading;
        if (d != null && mounted) {
          setState(() => _headingDeg = d);
        }
      });

      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;

      _pollTimer = Timer.periodic(
        const Duration(seconds: 2),
            (_) => fetchPredictionAndUpdateAnchor(),
      );

      _uiTicker = Timer.periodic(
        const Duration(milliseconds: 66),
            (_) => _updateFusedPosition(),
      );

      fetchPredictionAndUpdateAnchor();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _tfm.value = Matrix4.identity()
            ..translate(_initialPan.dx, _initialPan.dy)
            ..scale(_initialScale);
        }
      });
    } catch (e) {
      debugPrint('IndoorMap 초기화 오류: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ----------------------------
  // 현재 위치로 이동 (뷰포트 기준으로 정확히 센터)
  // ----------------------------
  void centerToCurrentPosition() {
    if (_fusedPx == null) return;

    final Offset targetPx = _fusedPx! + _overlayOffset;
    final double currentScale = _tfm.value.getMaxScaleOnAxis();

    // 화면(뷰포트) 중심 좌표
    final double viewCenterX = _viewportSize.width / 2;
    final double viewCenterY = _viewportSize.height / 2;

    // 이미지 좌표계 → 화면 좌표계로 맞춰서 이동
    final double dx = -targetPx.dx * currentScale + viewCenterX;
    final double dy = -targetPx.dy * currentScale + viewCenterY;

    _tfm.value = Matrix4.identity()
      ..translate(dx, dy)
      ..scale(currentScale);
  }

  // ----------------------------
  // 예측 + 위치 갱신
  // ----------------------------
  Future<void> fetchPredictionAndUpdateAnchor() async {
    if (_sensor == null || _graph == null) return;
    try {
      final request = _sensor!.getCurrentSensorValues();
      final result = await PredictApi.fetchPrediction(request);
      if (result != null && mounted) {
        setState(() {
          selectedPredictionIndex = result.num.toString();
        });

        final node = _graph!.getNode(result.num.toString());
        final newAnchor = _meterToPx(node.x, node.y);

        const double thresholdM = 3.0;
        final double thresholdPx = thresholdM * _pxPerMeter;

        final currentPos = _fusedPx ?? _anchorServerPx;
        if (currentPos != null) {
          final distPx = (newAnchor - currentPos).distance;
          _anchorServerPx = distPx > thresholdPx
              ? Offset.lerp(currentPos, newAnchor, 0.2)
              : newAnchor;
        } else {
          _anchorServerPx = newAnchor;
        }

        // 첫 위치는 즉시 표출
        _fusedPx ??= _anchorServerPx;

        final st = _sensor!.pdr.getState();
        _anchorPdrX = (st['posX'] as num).toDouble();
        _anchorPdrY = (st['posY'] as num).toDouble();
      }
    } catch (e) {
      debugPrint('Prediction 오류: $e');
    }
  }

  // ----------------------------
  // 위치 보정
  // ----------------------------
  Offset _meterToPx(double xM, double yM) {
    double y = yM;
    if (_flipY) y = _minY + (_maxY - yM);
    return _originPx + Offset(xM * _pxPerMeter, y * _pxPerMeter);
  }

  Offset _rotate(Offset v, double deg) {
    final r = deg * math.pi / 180.0, c = math.cos(r), s = math.sin(r);
    return Offset(c * v.dx - s * v.dy, s * v.dx + c * v.dy);
  }

  void _updateFusedPosition() {
    if (!mounted || _anchorServerPx == null || _sensor == null) return;
    try {
      final st = _sensor!.pdr.getState();
      final dxM = (st['posX'] as num).toDouble() - _anchorPdrX;
      final dyM = (st['posY'] as num).toDouble() - _anchorPdrY;
      final rotated = _rotate(Offset(dxM, dyM), 0);
      final fused = _anchorServerPx! + Offset(rotated.dx * _pxPerMeter, -rotated.dy * _pxPerMeter);
      setState(() => _fusedPx = fused);
    } catch (e) {
      debugPrint('Position update 오류: $e');
    }
  }

  void _calibrateScaleAndOrigin() {
    if (_graph == null || _graph!.nodes.isEmpty || _calibrated) return;
    double minX = double.infinity, minY = double.infinity;
    double maxX = -double.infinity, maxY = -double.infinity;
    for (final n in _graph!.nodes) {
      minX = math.min(minX, n.x);
      minY = math.min(minY, n.y);
      maxX = math.max(maxX, n.x);
      maxY = math.max(maxY, n.y);
    }

    _minX = minX; _minY = minY; _maxX = maxX; _maxY = maxY;
    final wM = (maxX - minX).abs();
    final hM = (maxY - minY).abs();
    if (wM <= 0 || hM <= 0) return;

    const padPx = 24.0;
    final availW = kImageW - padPx * 2;
    final availH = kImageH - padPx * 2;
    _pxPerMeter = math.min(availW / wM, availH / hM);

    _originPx = Offset(
      padPx - minX * _pxPerMeter,
      padPx - (_flipY ? (minY + (maxY - minY)) : minY) * _pxPerMeter,
    );
    _calibrated = true;
  }

  // ----------------------------
  // UI
  // ----------------------------
  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    final scrollBehavior = const MaterialScrollBehavior().copyWith(
      dragDevices: {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.unknown,
      },
    );

    return ScrollConfiguration(
      behavior: scrollBehavior,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 현재 화면(뷰포트) 크기 저장 → 중심 이동 정확도 보장
          _viewportSize = constraints.biggest;

          return InteractiveViewer(
            transformationController: _tfm,
            minScale: 0.3,
            maxScale: 5.0,
            constrained: false,
            boundaryMargin: const EdgeInsets.all(200),
            panEnabled: true,
            scaleEnabled: true,
            child: SizedBox(
              width: kImageW,
              height: kImageH,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: _bgOffset.dx,
                    top: _bgOffset.dy,
                    child: Image.asset(
                      'assets/3map.png',
                      width: kImageW,
                      height: kImageH,
                      fit: BoxFit.fill,
                    ),
                  ),
                  if (_graph != null)
                    ..._graph!.nodes.map((n) {
                      final posPx = _meterToPx(n.x, n.y) + _overlayOffset;
                      final isCurrent = (selectedPredictionIndex != null && n.id == selectedPredictionIndex);
                      return Positioned(
                        left: posPx.dx - 10,
                        top: posPx.dy - 10,
                        child: GestureDetector(
                          onTap: () async {
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
                                markerId: n.id,
                              ),
                            );
                          },
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: isCurrent ? Colors.orange : (n.type == "marker" ? Colors.blue : Colors.red),
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.grayscale.s30, width: 1),
                            ),
                            child: Center(
                              child: Text(
                                n.id,
                                style: AppTextStyles.caption2_1.copyWith(
                                  color: AppColors.grayscale.s30,
                                  fontSize: 8,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  if (_fusedPx != null)
                    Positioned(
                      left: (_fusedPx! + _overlayOffset).dx - 28,
                      top: (_fusedPx! + _overlayOffset).dy - 28,
                      child: NaverCurrentLocationMarker(
                        radius: 28,
                        headingDeg: _headingDeg,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
