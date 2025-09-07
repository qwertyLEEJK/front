import 'package:flutter/material.dart';
import 'dart:async';
import 'package:get/get.dart';
import 'package:midas_project/theme/app_colors.dart';
import 'package:midas_project/theme/app_theme.dart';
import '../function/sensor_controller.dart';
import '../function/Predict_api.dart';
import 'dart:collection'; // 주석 부분 때문에 필요한 패키지
import 'package:flutter_compass/flutter_compass.dart';
import 'dart:math' as math;
import 'place_info.dart';

// ===== (A) 마커 좌표 / API 매핑 =====
final List<Map<String, dynamic>> markerList = [
  {"x": 3150, "y": 830}, //1
  {"x": 3008, "y": 830}, //2
  {"x": 2866, "y": 830}, //3
  {"x": 2723, "y": 830}, //4
  {"x": 2581, "y": 830}, //5
  {"x": 2439, "y": 830}, //6
  {"x": 2297, "y": 830}, //7
  {"x": 2154, "y": 830}, //8
  {"x": 2012, "y": 830}, //9
  {"x": 1870, "y": 830}, //10  ← 현재위치 스타일 + 방위 삼각형
  {"x": 1668, "y": 830}, //11
  {"x": 1526, "y": 830}, //12
  {"x": 1384, "y": 830}, //13
  {"x": 1242, "y": 830}, //14
  {"x": 1100, "y": 830}, //15
  {"x": 958,  "y": 830}, //16
  {"x": 816,  "y": 830}, //17
  {"x": 674,  "y": 830}, //18
  {"x": 532,  "y": 830}, //19
  {"x": 390,  "y": 830}, //20
  {"x": 238,  "y": 880}, //21
  {"x": 2777, "y": 730}, //22
  {"x": 2777, "y": 540}, //23
  {"x": 1800, "y": 755}, //24
  {"x": 1668, "y": 680}, //25
  {"x": 1668, "y": 530}, //26
  {"x": 1668, "y": 930}, //27
  {"x": 1800, "y": 1000}, //28
  {"x": 1800, "y": 1100}, //29
];


final List<int> markerApiValues = [
  1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29
];

// ===== (B) 네이버 현재위치 스타일 마커 위젯 (방위 삼각형 포함) =====
class NaverCurrentLocationMarker extends StatelessWidget {
  final double radius;     // 바깥 반경(정확도 원 크기 절반)
  final double headingDeg; // 단말 방위(0° = 북쪽/위쪽)

  const NaverCurrentLocationMarker({
    super.key,
    this.radius = 28,
    this.headingDeg = 0,
  });

  @override
  Widget build(BuildContext context) {
    final double size = radius * 2; // 전체 위젯 가로/세로
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 정확도(반경) 원 - 옅은 파란색
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: AppColors.secondary.s800.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
          ),
          // === 방위 삼각형 (위쪽 기준, headingDeg 만큼 회전) ===
          Transform.rotate(
            angle: (headingDeg + 180) * math.pi / 180.0,
            child: CustomPaint(
              size: const Size(20, 20),
              painter: _HeadingTrianglePainter(),
            ),
          ),
          // 흰 테두리 링
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.grayscale.s30, width: 2),
            ),
          ),
          // 파란 점
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: AppColors.secondary.s800,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

/// 위쪽(12시)을 향하는 작은 삼각형을 그리는 페인터
class _HeadingTrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint fill = Paint()..color = AppColors.secondary.s800;
    final Paint stroke = Paint()
      ..color = AppColors.secondary.s800
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    final double w = size.width;
    final double h = size.height;

    // === 크기 절반으로 축소 ===
    final Path tri = Path()
      ..moveTo(w / 2, 0)              // 위 꼭짓점
      ..lineTo(w * 0.25, h * 0.375)   // 좌측 하단 (원래 0, h*0.75 → 절반)
      ..lineTo(w * 0.75, h * 0.375)   // 우측 하단 (원래 w, h*0.75 → 절반)
      ..close();

    // 중심보다 살짝 위로 올리기 (값도 절반 정도로 줄임)
    canvas.translate(0, -7);

    canvas.drawPath(tri, fill);
    canvas.drawPath(tri, stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


const double imageOriginWidth = 3508;
const double imageOriginHeight = 1422;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int? selectedPredictionIndex;
  Timer? _timer;

  // InteractiveViewer 제어용
  final TransformationController _transformationController = TransformationController();

  // 레이아웃(뷰포트/이미지) 크기 저장
  double _lastViewportWidth = 0;
  double _lastViewportHeight = 0;
  double _lastImageWidth = 0;
  double _lastImageHeight = 0;

  // 방위(도)
  double _headingDeg = 0.0;
  StreamSubscription<CompassEvent>? _compassSub;

  @override
  void initState() {
    super.initState();
    Get.put(SensorController());

    // 방위(heading) 수신
    _compassSub = FlutterCompass.events?.listen((event) {
      final double? deg = event.heading; // 0~360 (북=0)
      if (deg != null && mounted) {
        setState(() {
          _headingDeg = deg;
        });
      }
    });

    fetchPredictionAndUpdateMarker();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) => fetchPredictionAndUpdateMarker());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _compassSub?.cancel();
    _transformationController.dispose();
    super.dispose();
  }

  void fetchPredictionAndUpdateMarker() async {
    final controller = Get.find<SensorController>();
    final request = controller.getCurrentSensorValues();
    final result = await PredictApi.fetchPrediction(request);

    if (result != null) {
      setState(() {
        selectedPredictionIndex = result.num;
      });
    }
  }

  /// 버튼 누르면 현재 마커를 화면 중앙에 오도록 이동 (스케일 1.0)
  void _centerOnCurrentMarker() {
    if (selectedPredictionIndex == null || _lastViewportWidth == 0 || _lastViewportHeight == 0 || _lastImageWidth == 0 || _lastImageHeight == 0) {
      return;
    }

    final idx = markerApiValues.indexOf(selectedPredictionIndex!);
    if (idx < 0 || idx >= markerList.length) return;

    final marker = markerList[idx];
    final double mx = (marker['x'] as num).toDouble();
    final double my = (marker['y'] as num).toDouble();

    final double scaledLeft = (mx / imageOriginWidth) * _lastImageWidth;
    final double scaledTop  = (my / imageOriginHeight) * _lastImageHeight;

    const double scale = 1.0;
    final double tx = (_lastViewportWidth  / 2) - (scaledLeft * scale);
    final double ty = (_lastViewportHeight / 2) - (scaledTop  * scale);

    _transformationController.value = Matrix4.identity()
      ..translate(tx, ty)
      ..scale(scale);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // 화면(뷰포트) 높이에 맞춰 원본 비율로 지도 크기 산정
            final displayHeight = constraints.maxHeight;
            final displayWidth = imageOriginWidth * (displayHeight / imageOriginHeight);

            // 뷰포트/이미지 크기 저장
            _lastViewportWidth = constraints.maxWidth;
            _lastViewportHeight = displayHeight;
            _lastImageWidth = displayWidth;
            _lastImageHeight = displayHeight;

            return Stack(
              children: [
                // InteractiveViewer는 자식 실제 크기를 쓰게(constrained: false)
                Positioned.fill(
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
                      child: Stack(
                        children: [
                          // 지도 이미지
                          Image.asset(
                            'lib/assets/3map.png',
                            fit: BoxFit.fill,
                            width: displayWidth,
                            height: displayHeight,
                          ),

                          // 마커들
                          ...markerList.asMap().entries.map((entry) {
                            final i = entry.key;
                            final marker = entry.value;
                            final markerApiValue = (i < markerApiValues.length) ? markerApiValues[i] : null;

                            final double mx = (marker['x'] as num).toDouble();
                            final double my = (marker['y'] as num).toDouble();

                            final double scaledLeft = (mx / imageOriginWidth) * displayWidth;
                            final double scaledTop  = (my / imageOriginHeight) * displayHeight;

                            final bool isCurrentLocation = selectedPredictionIndex != null && markerApiValue == selectedPredictionIndex;
                            final double markerSize = isCurrentLocation ? 56.0 : 16.0;

                            return Positioned(
                              left: scaledLeft - (markerSize / 2),
                              top:  scaledTop  - (markerSize / 2),
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  if (isCurrentLocation) {
                                    showModalBottomSheet(
                                      context: context,
                                      backgroundColor: Colors.transparent, // 뒷배경 어두워지는 효과 제거
                                      barrierColor: Colors.transparent, // 배경을 투명하게 하여 SlideUpCard의 둥근 모서리를 살림
                                      builder: (builderContext) {
                                        return SlideUpCard(
                                          onClose: () {
                                            Navigator.pop(builderContext);
                                          },
                                        );
                                      },
                                    );
                                  }
                                },
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isCurrentLocation)
                                      NaverCurrentLocationMarker(
                                        radius: 28,
                                        headingDeg: _headingDeg, // ← 방위 전달
                                      )
                                    else
                                      Container(
                                        width: 16,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          color: (selectedPredictionIndex != null &&
                                                  markerApiValue != null &&
                                                  selectedPredictionIndex == markerApiValue)
                                              ? Colors.blue
                                              : Colors.transparent,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: AppColors.grayscale.s30, width: 2),
                                        ),
                                      ),
                                    const SizedBox(height: 2),
                                    Text("(${markerApiValue ?? '-'})"),
                                  ],
                                ),
                              ),
                            );
                          }),

                          // 왼쪽 상단에 API값 띄우기
                          Positioned(
                            left: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.grayscale.s900.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'API값: ${selectedPredictionIndex ?? '-'}',
                                style: AppTextStyles.title7.copyWith(color: AppColors.grayscale.s30)
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ===== 오른쪽 아래 타깃 버튼 =====
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: InkWell(
                    onTap: _centerOnCurrentMarker,
                    borderRadius: BorderRadius.circular(32),
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.grayscale.s30,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.grayscale.s200)
                      ),
                      padding: const EdgeInsets.all(15),
                      child: Image.asset(
                        'lib/assets/images/target.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
