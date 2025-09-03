import 'package:flutter/material.dart';
import 'dart:async';
import 'package:get/get.dart';
import '../function/sensor_controller.dart';
import '../function/Predict_api.dart';
import 'dart:collection'; //주석 부분 때문에 필요한 패키지

final List<Map<String, dynamic>> markerList = [
  {"x": 3100, "y": 830}, //1
  {"x": 2992, "y": 830}, //2
  {"x": 2885, "y": 830}, //3
  {"x": 2777, "y": 830}, //4
  {"x": 2616, "y": 830}, //5
  {"x": 2455, "y": 830}, //6
  {"x": 2294, "y": 830}, //7
  {"x": 2133, "y": 830}, //8
  {"x": 1972, "y": 830}, //9
  {"x": 1811, "y": 830}, //10
  {"x": 2777, "y": 730}, //11
  {"x": 2777, "y": 540}, //12
  {"x": 1720, "y": 700}, //13
  {"x": 1720, "y": 560}, //14
  {"x": 1720, "y": 920}, //15
  {"x": 1720, "y": 1060}, //16
];

final List<int> markerApiValues = [
  1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16
];

/*
void main() {
  List<String> rawGrid = [
    "111111111111111111111111111111111111111111111111111111111111111111",
    "1111111111111111111111111111101111111111111111111E1111111111111111",
    "111111111111111111111111111110111111111111111111101111111111111111",
    "1S0000000000000000000000000000000000000000000000000000000000000001",
    "111111111111111111111111111110111111111111111111111111111111111111",
    "111111111111111111111111111110111111111111111111111111111111111111",
    "111111111111111111111111111111111111111111111111111111111111111111"
  ];

  int n = rawGrid.length;
  int m = rawGrid[0].length;
  List<List<String>> grid =
      rawGrid.map((row) => row.split('')).toList();

  // S, E 좌표 찾기
  late Point start, end;
  for (int i = 0; i < n; i++) {
    for (int j = 0; j < m; j++) {
      if (grid[i][j] == 'S') {
        start = Point(i, j);
      }
      if (grid[i][j] == 'E') {
        end = Point(i, j);
      }
    }
  }

  // BFS
  Queue<Point> q = Queue();
  q.add(start);
  Map<Point, Point?> prev = {};
  prev[start] = null;

  List<List<int>> dirs = [
    [1, 0],
    [-1, 0],
    [0, 1],
    [0, -1]
  ];

  while (q.isNotEmpty) {
    Point cur = q.removeFirst();
    if (cur == end) break;
    for (var d in dirs) {
      int nx = cur.x + d[0];
      int ny = cur.y + d[1];
      if (nx < 0 || ny < 0 || nx >= n || ny >= m) continue;
      if (grid[nx][ny] == '1') continue;
      Point next = Point(nx, ny);
      if (prev.containsKey(next)) continue;
      prev[next] = cur;
      q.add(next);
    }
  }

  if (!prev.containsKey(end)) {
    print("경로 없음");
    return;
  }

  // 경로 복원
  List<Point> path = [];
  Point? cur = end;
  while (cur != null) {
    path.add(cur);
    cur = prev[cur];
  }
  path = path.reversed.toList();

  // 경로 표시
  for (var p in path) {
    if (grid[p.x][p.y] != 'S' && grid[p.x][p.y] != 'E') {
      grid[p.x][p.y] = '.';
    }
  }

  // 결과 출력
  for (var row in grid) {
    print(row.join());
  }
  print("최단 거리: ${path.length - 1}");
}

class Point {
  final int x, y;
  const Point(this.x, this.y);

  @override
  bool operator ==(Object other) =>
      other is Point && other.x == x && other.y == y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;
}
*/



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

  @override
  void initState() {
    super.initState();
    Get.put(SensorController());

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
      print('API result: ${result.num}'); // 디버깅용 콘솔 출력
      setState(() {
        selectedPredictionIndex = result.num;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '캠퍼스 지도${selectedPredictionIndex != null ? ' (API값: $selectedPredictionIndex)' : ''}',
        ),
      ),
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
                      // 지도 이미지와 마커
                      Image.asset(
                        'lib/assets/3map.png',
                        fit: BoxFit.fitHeight,
                        height: displayHeight,
                        width: displayWidth,
                      ),
                      ...markerList.asMap().entries.map((entry) {
                        final i = entry.key;
                        final marker = entry.value;
                        final markerApiValue = (i < markerApiValues.length) ? markerApiValues[i] : null;
                        double scaledLeft = (marker['x']! / imageOriginWidth) * displayWidth;
                        double scaledTop = (marker['y']! / imageOriginHeight) * displayHeight;

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
                                  color: (selectedPredictionIndex != null && markerApiValue != null && selectedPredictionIndex == markerApiValue)
                                    ? Colors.blue
                                    : Colors.red,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text("(${markerApiValue ?? '-'})", style: const TextStyle(fontSize: 10)),
                            ],
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
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'API값: ${selectedPredictionIndex ?? '-'}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}