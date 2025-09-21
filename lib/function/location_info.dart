// lib/function/location_info.dart
import 'dart:ui';
import 'dart:math' as Math;

const double imageOriginWidth = 3508;
const double imageOriginHeight = 1422;

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
  {"x": 1870, "y": 830}, //10
  {"x": 1668, "y": 830}, //11
  {"x": 1526, "y": 830}, //12
  {"x": 1384, "y": 830}, //13
  {"x": 1242, "y": 830}, //14
  {"x": 1100, "y": 830}, //15
  {"x": 958, "y": 830}, //16
  {"x": 816, "y": 830}, //17
  {"x": 674, "y": 830}, //18
  {"x": 532, "y": 830}, //19
  {"x": 390, "y": 830}, //20
  {"x": 238, "y": 880}, //21
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
  1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
  11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
  21, 22, 23, 24, 25, 26, 27, 28, 29
];

// ===== (B) 실측 거리 데이터 (m) =====
// List<int>를 키로 쓰면 같은 숫자쌍을 넣더라도 같은 키로 인식이 안됨 -> 업데이트 및 조회 불안정
// record 타입으로 refactoring
final Map<({int a, int b}), double> realDistances = {
  (a: 21, b: 20): 2.7,
  (a: 20, b: 19): 4.5,
  (a: 19, b: 18): 4.5,
  (a: 18, b: 17): 4.5,
  (a: 17, b: 16): 4.5,
  (a: 16, b: 15): 4.5,
  (a: 15, b: 14): 4.5,
  (a: 14, b: 13): 4.5,
  (a: 13, b: 12): 4.5,
  (a: 12, b: 11): 4.5,
  (a: 11, b: 10): 4.5,
  (a: 10, b: 9): 4.5,
  (a: 9, b: 8): 4.5,
  (a: 8, b: 7): 4.5,
  (a: 7, b: 6): 4.5,
  (a: 6, b: 5): 4.5,
  (a: 5, b: 4): 4.5,
  (a: 4, b: 3): 4.5,
  (a: 3, b: 2): 4.5,
  (a: 2, b: 1): 4.5,
  (a: 10, b: 27): 2.73,
  (a: 27, b: 28): 2.25,
  (a: 28, b: 29): 2.45,
  (a: 27, b: 26): 3.6,
  (a: 26, b: 25): 5.4,
  (a: 5, b: 24): 3.6,
  (a: 24, b: 25): 5.4,
};

// ===== (C) CAD 좌표 ↔ 보정 유틸 =====

// 특정 marker id의 CAD 좌표(px) 반환
Offset markerPos(int id) {
  final idx = markerApiValues.indexOf(id);
  final m = markerList[idx];
  return Offset((m['x'] as num).toDouble(), (m['y'] as num).toDouble());
}

// pxPerMeter 평균 계산
double computePxPerMeter() {
  List<double> values = [];
  realDistances.forEach((pair, realM) {
    final pos1 = markerPos(pair.a);
    final pos2 = markerPos(pair.b);
    final cadDistPx = (pos1 - pos2).distance;
    final pxPerM = cadDistPx / realM;
    values.add(pxPerM);
  });
  return values.reduce((a, b) => a + b) / values.length;
}

// 구간별 px/m 리스트 출력 (검증용)
void printPxPerMeterStats() {
  realDistances.forEach((pair, realM) {
    final pos1 = markerPos(pair.a);
    final pos2 = markerPos(pair.b);
    final cadDistPx = (pos1 - pos2).distance;
    final ratio = cadDistPx / realM;
    print("구간 ${pair.a}-${pair.b}: CAD=${cadDistPx.toStringAsFixed(2)}px, "
        "실측=${realM.toStringAsFixed(2)}m, "
        "px/m=${ratio.toStringAsFixed(3)}");
  });
}
