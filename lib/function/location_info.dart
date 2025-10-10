import 'dart:ui';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart'; // debugPrint

/// 노드 정보
class Node {
  final String id; // 문자열 ID
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
  final String from; // 문자열 ID
  final String to;   // 문자열 ID
  final double distance;

  Edge({
    required this.from,
    required this.to,
    required this.distance,
  });
}

class LocationGraph {
  final List<Node> nodes;
  final List<Edge> edges;

  LocationGraph({required this.nodes, required this.edges});

  Node getNode(String id) =>
      nodes.firstWhere((n) => n.id == id, orElse: () => throw Exception('노드 $id 없음'));

  /// CAD 좌표(px) 대신 → 실측 좌표(m) 기반 반환
  Offset nodePos(String id) {
    final n = getNode(id);
    return Offset(n.x, n.y);
  }
}

// ---------- 유틸 ----------

String _clean(String s) {
  return s
      .replaceAll('\ufeff', '') // BOM 제거
      .replaceAll('"', '')
      .replaceAll("'", '')
      .trim();
}

double? _tryDouble(String s) => double.tryParse(_clean(s));

/// CSV 로드 (ID 문자열 그대로 사용)
Future<LocationGraph> loadGraphFromCsv() async {
  final nodeCsv = await rootBundle.loadString('assets/data/nodes_final.csv');
  final edgeCsv = await rootBundle.loadString('assets/data/edges_final.csv');

  final nodeLines = const LineSplitter().convert(nodeCsv);
  final edgeLines = const LineSplitter().convert(edgeCsv);

  if (nodeLines.isEmpty) {
    debugPrint('[Graph] nodes_final.csv 비어있음');
    return LocationGraph(nodes: const [], edges: const []);
  }

  // ---------- 노드 파싱 ----------
  final List<Node> nodes = [];
  int nodeSkipped = 0;

  for (final raw in nodeLines.skip(1)) {
    if (raw.trim().isEmpty) continue;
    final cols = raw.split(',');

    if (cols.length < 5) {
      debugPrint('[Graph][NODES][SKIP] 컬럼 수 부족: "$raw"');
      continue;
    }

    final id = _clean(cols[0]);
    final name = _clean(cols[1]);
    final x = _tryDouble(cols[2]);
    final y = _tryDouble(cols[3]);
    final type = _clean(cols[4]);

    if (x == null || y == null) {
      nodeSkipped++;
      debugPrint('[Graph][NODES][SKIP] 좌표 파싱 실패: id=$id');
      continue;
    }

    nodes.add(Node(
      id: id,
      name: name.isEmpty ? id : name,
      x: x,
      y: y,
      type: type.isEmpty ? 'marker' : type,
    ));
  }

  debugPrint('[Graph] 노드 파싱 완료: ${nodes.length}개 (스킵 $nodeSkipped개)');

  // ---------- 엣지 파싱 ----------
  final Set<String> nodeIdSet = nodes.map((n) => n.id).toSet();
  final List<Edge> edges = [];
  int edgeSkipped = 0;

  for (final raw in edgeLines.skip(1)) {
    if (raw.trim().isEmpty) continue;
    final cols = raw.split(',');

    if (cols.length < 3) {
      debugPrint('[Graph][EDGES][SKIP] 컬럼 수 부족: "$raw"');
      continue;
    }

    final from = _clean(cols[0]);
    final to = _clean(cols[1]);
    final dist = _tryDouble(cols[2]);

    if (dist == null) {
      edgeSkipped++;
      debugPrint('[Graph][EDGES][SKIP] 거리 파싱 실패: "$raw"');
      continue;
    }

    if (!nodeIdSet.contains(from) || !nodeIdSet.contains(to)) {
      edgeSkipped++;
      debugPrint('[Graph][EDGES][SKIP] 존재하지 않는 노드 참조: $from → $to');
      continue;
    }

    edges.add(Edge(from: from, to: to, distance: dist));
  }

  debugPrint('[Graph] 엣지 파싱 완료: ${edges.length}개 (스킵 $edgeSkipped개)');

  return LocationGraph(nodes: nodes, edges: edges);
}
