// lib/screens/indoor_map_screen.dart
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
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.secondary.s800.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
        ),
        Transform.rotate(
          angle: (headingDeg + 180) * math.pi / 180.0,
          child: CustomPaint(size: const Size(20, 20), painter: _HeadingTrianglePainter()),
        ),
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.grayscale.s30, width: 2),
          ),
        ),
        Container(
          width: 10,
          height: 10,
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

  Offset? _anchorServerPx;
  double _anchorPdrX = 0.0, _anchorPdrY = 0.0;
  Offset? _fusedPx;

  double _pxPerMeter = 20.0;
  Offset _originPx = Offset.zero;
  bool _calibrated = false;
  final bool _flipY = false;

  double _minX = 0, _minY = 0, _maxX = 0, _maxY = 0;

  Timer? _uiTicker;
  List<String> _topK = [];
  LocationGraph? _graph;
  bool _isLoading = true;

  final TransformationController _tfm = TransformationController();
  final double _initialScale = 1.0;
  final Offset _initialPan = const Offset(0, -120);

  final Offset _bgOffset = const Offset(0, -80);
  final Offset _overlayOffset = const Offset(0, 380);

  @override
  void initState() {
    super.initState();
    _initializeAsync();
  }

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
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _uiTicker?.cancel();
    _pollTimer?.cancel();
    _compassSub?.cancel();
    _tfm.dispose();
    super.dispose();
  }

  // 🔧 markerId 타입 변경 (int? → String?)
  Future<void> _openPlaceSheet({String? markerId}) async {
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

  Future<void> fetchPredictionAndUpdateAnchor() async {
    if (_sensor == null || _graph == null) return;
    try {
      final request = _sensor!.getCurrentSensorValues();
      final result = await PredictApi.fetchPrediction(request);
      if (result != null && mounted) {
        setState(() {
          selectedPredictionIndex = result.num.toString(); // 문자열 변환
          _topK = result.topKRaw;
        });

        final node = _graph!.getNode(result.num.toString()); // 문자열 변환
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

        final st = _sensor!.pdr.getState();
        _anchorPdrX = (st['posX'] as num).toDouble();
        _anchorPdrY = (st['posY'] as num).toDouble();
      }
    } catch (e) {
      debugPrint('Prediction 오류: $e');
    }
  }

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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    final scrollBehavior = const MaterialScrollBehavior().copyWith(
      dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse, PointerDeviceKind.stylus, PointerDeviceKind.unknown},
    );

    return ScrollConfiguration(
      behavior: scrollBehavior,
      child: InteractiveViewer(
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
                child: Image.asset('assets/3map.png', width: kImageW, height: kImageH, fit: BoxFit.fill),
              ),
              if (_graph != null)
                ..._graph!.nodes.map((n) {
                  final posPx = _meterToPx(n.x, n.y) + _overlayOffset;
                  final isCurrent = (selectedPredictionIndex != null && n.id == selectedPredictionIndex);
                  return Positioned(
                    left: posPx.dx - 10,
                    top: posPx.dy - 10,
                    child: GestureDetector(
                      onTap: () => _openPlaceSheet(markerId: n.id), // 🔧 n.id는 String
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? Colors.orange
                              : (n.type == "marker" ? Colors.blue : Colors.red),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.grayscale.s30, width: 1),
                        ),
                        child: Center(
                          child: Text(
                            n.id, // 🔧 문자열 표시
                            style: AppTextStyles.caption2_1.copyWith(color: AppColors.grayscale.s30, fontSize: 8),
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
                  child: NaverCurrentLocationMarker(radius: 28, headingDeg: _headingDeg),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
