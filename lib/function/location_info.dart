// lib/function/location_info.dart
import 'dart:ui';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

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

/// CSV 로드
Future<LocationGraph> loadGraphFromCsv() async {
  final nodeCsv = await rootBundle.loadString('assets/data/nodes_final.csv');
  final edgeCsv = await rootBundle.loadString('assets/data/edges_final.csv');

  final nodes = <Node>[];
  final edges = <Edge>[];

  // --- Parse nodes ---
  final nodeLines = const LineSplitter().convert(nodeCsv);
  final nodeHeader = nodeLines.first.split(',');
  for (final line in nodeLines.skip(1)) {
    final cols = line.split(',');
    nodes.add(Node(
      id: int.parse(cols[0]),
      name: cols[1],
      x: double.parse(cols[2]),
      y: double.parse(cols[3]),
      type: cols[4],
    ));
  }

  // --- Parse edges ---
  final edgeLines = const LineSplitter().convert(edgeCsv);
  for (final line in edgeLines.skip(1)) {
    final cols = line.split(',');
    edges.add(Edge(
      from: int.parse(cols[0]),
      to: int.parse(cols[1]),
      distance: double.parse(cols[2]),
    ));
  }

  return LocationGraph(nodes: nodes, edges: edges);
}
