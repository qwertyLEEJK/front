import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'dart:math' as math;
import 'dart:async';
import 'package:get/get.dart';
import 'components/bottom_Navbar.dart';
import 'function/sensor_controller.dart';
import 'function/Predict_api.dart';
import 'function/Predict_request.dart';
import 'function/Predict_response.dart';

final List<Map<String, dynamic>> markerList = [
  {"x": 200, "y": 830},     // 1
  {"x": 1650, "y": 1120},   // 2
  {"x": 1650, "y": 830},    // 3
  {"x": 1650, "y": 600},    // 4
  {"x": 2730, "y": 830},    // 5
  {"x": 2730, "y": 480},    // 6
  {"x": 3100, "y": 830},    // 7
  {"x": 2915, "y": 200, "isArrow": true}, // 화살표 마커
];

const double imageOriginWidth = 3508;
const double imageOriginHeight = 1422;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: '캠퍼스 지도',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const CampusMapPage(),
    );
  }
}

class CampusMapPage extends StatefulWidget {
  const CampusMapPage({super.key});

  @override
  State<CampusMapPage> createState() => _CampusMapPageState();
}

class _CampusMapPageState extends State<CampusMapPage> {
  double? _heading;
  int? selectedPredictionIndex;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    Get.put(SensorController());

    FlutterCompass.events?.listen((CompassEvent event) {
      setState(() {
        _heading = event.heading;
      });
    });

    fetchPredictionAndUpdateMarker();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) => fetchPredictionAndUpdateMarker());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void fetchPredictionAndUpdateMarker() async {
    final controller = Get.find<SensorController>();
    final request = controller.getCurrentSensorValues();
    final result = await PredictApi.fetchPrediction(request);

    if (result != null) {
      setState(() {
        selectedPredictionIndex = result.num; // 1~7 범위
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('캠퍼스 지도')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final displayHeight = constraints.maxHeight;
            final displayWidth = imageOriginWidth * (displayHeight / imageOriginHeight);

            return InteractiveViewer(
              panEnabled: true,
              minScale: 1,
              maxScale: 5,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: displayHeight,
                    minWidth: displayWidth,
                  ),
                  child: Stack(
                    children: [
                      Image.asset(
                        'lib/3map.png',
                        fit: BoxFit.fitHeight,
                        height: displayHeight,
                        width: displayWidth,
                      ),
                      ...markerList.asMap().entries.map((entry) {
                        final i = entry.key;
                        final marker = entry.value;
                        final markerNumber = i + 1;
                        double scaledLeft = (marker['x']! / imageOriginWidth) * displayWidth;
                        double scaledTop = (marker['y']! / imageOriginHeight) * displayHeight;

                        if (marker['isArrow'] == true) {
                          return Positioned(
                            left: scaledLeft - 16,
                            top: scaledTop - 32,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Transform.rotate(


                                  angle: (((_heading ?? 0) - 18 + 180) * (math.pi / 180) * -1),
                                  child: const Icon(Icons.navigation, size: 32, color: Colors.blue),
                                ),
                                const SizedBox(height: 4),
                                Text("(${marker['x']}, ${marker['y']})", style: const TextStyle(fontSize: 11)),
                              ],
                            ),
                          );
                        }

                        return Positioned(
                          left: scaledLeft - 8,
                          top: scaledTop - 8,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: selectedPredictionIndex == markerNumber ? Colors.blue : Colors.red,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text("($markerNumber)", style: const TextStyle(fontSize: 10)),
                            ],
                          ),
                        );
                      })
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: BottomNavBar(navigating: false, onStopNavigation: () {}),
      ),
    );
  }
}