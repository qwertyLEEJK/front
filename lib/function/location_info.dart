// lib/function/location_info.dart
import 'dart:ui';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart'; // debugPrint

/// 노드 정보
class Node {
  final int id;
  final String name;
  final double x;
  final double y;
  final String type; // marker / corner

  Node({
    required this.id,
    required this.name,
    required this.x,
    required this.y,
    required this.type,
  });
}

/// 엣지 정보
class Edge {
  final int from;
  final int to;
  final double distance;

  Edge({required this.from, required this.to, required this.distance});
}

class LocationGraph {
  final List<Node> nodes;
  final List<Edge> edges;

  LocationGraph({required this.nodes, required this.edges});

  Node getNode(int id) => nodes.firstWhere((n) => n.id == id);

  /// CAD 좌표(px) 대신 → 실측 좌표(m) 기반 반환
  Offset nodePos(int id) {
    final n = getNode(id);
    return Offset(n.x, n.y);
  }
}

// ---------- 유틸 ----------
String _clean(String s) {
  return s
      .replaceAll('\ufeff', '') // BOM
      .replaceAll('"', '')
      .replaceAll("'", '')
      .trim();
}

bool _isIntToken(String s) => RegExp(r'^\s*\d+\s*$').hasMatch(s);

int? _tryInt(String s) => int.tryParse(_clean(s));
double? _tryDouble(String s) => double.tryParse(_clean(s));

/// CSV 로드 (문자 ID → 내부 정수 ID로 매핑)
Future<LocationGraph> loadGraphFromCsv() async {
  final nodeCsv = await rootBundle.loadString('assets/data/nodes_final.csv');
  final edgeCsv = await rootBundle.loadString('assets/data/edges_final.csv');

  final nodeLines = const LineSplitter().convert(nodeCsv);
  final edgeLines = const LineSplitter().convert(edgeCsv);

  if (nodeLines.isEmpty) {
    debugPrint('[Graph] nodes_final.csv 비어있음');
    return LocationGraph(nodes: const [], edges: const []);
  }

  // 1) 모든 토큰(노드 id 문자열) 수집
  final Set<String> nodeIdTokens = {};
  final List<List<String>> nodeRows = [];
  final List<List<String>> edgeRows = [];

  // 노드
  for (final raw in nodeLines.skip(1)) {
    if (raw.trim().isEmpty) continue;
    final cols = raw.split(',');
    if (cols.length < 5) {
      debugPrint('[Graph][NODES][SKIP] 컬럼 수 부족: "$raw"');
      continue;
    }
    final idTok = _clean(cols[0]);
    nodeIdTokens.add(idTok);
    nodeRows.add(cols);
  }

  // 엣지 (엣지에서 등장하는 토큰도 매핑에 포함)
  for (final raw in edgeLines.skip(1)) {
    if (raw.trim().isEmpty) continue;
    final cols = raw.split(',');
    if (cols.length < 3) {
      debugPrint('[Graph][EDGES][SKIP] 컬럼 수 부족: "$raw"');
      continue;
    }
    edgeRows.add(cols);
    final fromTok = _clean(cols[0]);
    final toTok = _clean(cols[1]);
    nodeIdTokens.add(fromTok);
    nodeIdTokens.add(toTok);
  }

  // 2) 정수/문자 토큰 분리 & 최대 정수 id 파악
  int maxNumeric = -1;
  for (final tok in nodeIdTokens) {
    if (_isIntToken(tok)) {
      final v = int.parse(tok);
      if (v > maxNumeric) maxNumeric = v;
    }
  }

  // 3) 문자 토큰에 새 정수 id 부여 (겹치지 않게 maxNumeric+1부터)
  int nextId = maxNumeric + 1;
  final Map<String, int> idMap = {};
  for (final tok in nodeIdTokens) {
    if (_isIntToken(tok)) {
      idMap[tok] = int.parse(tok);
    } else {
      idMap[tok] = nextId++;
    }
  }

  // 4) 노드 파싱 (모든 토큰을 매핑된 정수 id로 변환)
  final List<Node> nodes = [];
  int nodeSkipped = 0;
  for (final cols in nodeRows) {
    final idTok = _clean(cols[0]);
    final name = _clean(cols[1]);
    final x = _tryDouble(cols[2]);
    final y = _tryDouble(cols[3]);
    final type = _clean(cols[4]);

    if (x == null || y == null) {
      nodeSkipped++;
      debugPrint('[Graph][NODES][SKIP] 좌표 파싱 실패: x="${cols[2]}", y="${cols[3]}" (id="$idTok")');
      continue;
    }
    final mappedId = idMap[idTok];
    if (mappedId == null) {
      nodeSkipped++;
      debugPrint('[Graph][NODES][SKIP] id 매핑 실패: "$idTok"');
      continue;
    }
    nodes.add(Node(
      id: mappedId,
      name: name.isEmpty ? idTok : name, // 이름 비면 원래 토큰 사용
      x: x,
      y: y,
      type: type.isEmpty ? 'marker' : type,
    ));
  }
  debugPrint('[Graph] 노드 파싱 완료: kept=${nodes.length}, skipped=$nodeSkipped (문자 ID 포함 매핑 처리됨)');

  // 5) 엣지 파싱
  final nodeIdSet = nodes.map((n) => n.id).toSet();
  final List<Edge> edges = [];
  int edgeSkipped = 0;

  for (final cols in edgeRows) {
    final fromTok = _clean(cols[0]);
    final toTok = _clean(cols[1]);
    final dist = _tryDouble(cols[2]);

    if (dist == null) {
      edgeSkipped++;
      debugPrint('[Graph][EDGES][SKIP] distance 파싱 실패: "${cols[2]}"');
      continue;
    }
    final fromId = idMap[fromTok];
    final toId = idMap[toTok];
    if (fromId == null || toId == null) {
      edgeSkipped++;
      debugPrint('[Graph][EDGES][SKIP] 토큰 매핑 실패: "$fromTok" -> "$toTok"');
      continue;
    }
    if (!nodeIdSet.contains(fromId) || !nodeIdSet.contains(toId)) {
      edgeSkipped++;
      debugPrint('[Graph][EDGES][SKIP] 존재하지 않는 노드 참조: $fromTok($fromId) -> $toTok($toId)');
      continue;
    }

    edges.add(Edge(from: fromId, to: toId, distance: dist));
  }
  debugPrint('[Graph] 엣지 파싱 완료: kept=${edges.length}, skipped=$edgeSkipped');

  return LocationGraph(nodes: nodes, edges: edges);
}
