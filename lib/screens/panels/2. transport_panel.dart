// lib/screens/2. transport_panel.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// ===========================
/// 모델
/// ===========================
class BusRouteInfo {
  final String routeNo;
  final List<BusArrival> arrList;

  BusRouteInfo({required this.routeNo, required this.arrList});

  factory BusRouteInfo.fromJson(Map<String, dynamic> json) {
    final list = (json['arrList'] as List?) ?? const [];
    return BusRouteInfo(
      routeNo: json['routeNo']?.toString() ?? '',
      arrList: list
          .whereType<Map<String, dynamic>>()
          .map((e) => BusArrival.fromJson(e))
          .toList(),
    );
  }
}

class BusArrival {
  final String arrState; // 예: "곧도착", "운행종료"
  final int? bsGap;      // 몇 정류장 전 (운행종료일 때 -2)
  final String bsNm;     // 정류장명(있으면 사용)

  BusArrival({
    required this.arrState,
    required this.bsGap,
    required this.bsNm,
  });

  factory BusArrival.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }

    return BusArrival(
      arrState: json['arrState']?.toString() ?? '',
      bsGap: parseInt(json['bsGap']),
      bsNm: json['bsNm']?.toString() ?? '',
    );
  }
}

/// ===========================
/// API
/// ===========================
Future<List<BusRouteInfo>> fetchBusData() async {
  final url = Uri.parse(
    'https://apis.data.go.kr/6270000/dbmsapi01/getRealtime'
    '?serviceKey=%2BjhrV6NTQx%2F7D6dpNIvlvhoCkDaDGBX5Q4YS1YHjXbCIEafa%2F2hbqu79wN94O%2F8009L2H3meXft4RGUHZN1xbw%3D%3D'
    '&bsId=7121005800',
  );

  final response = await http.get(url);
  if (response.statusCode != 200) {
    throw Exception('API 요청 실패 (${response.statusCode})');
  }

  final data = jsonDecode(response.body);
  final body = (data is Map && data['body'] is Map) ? data['body'] as Map : {};
  final items = (body['items'] as List?) ?? const <dynamic>[];

  return items
      .whereType<Map<String, dynamic>>()
      .map((e) => BusRouteInfo.fromJson(e))
      .toList();
}

/// ===========================
/// UI: TransitPanel
/// ===========================
class TransitPanel extends StatefulWidget {
  final ScrollController controller;
  const TransitPanel({super.key, required this.controller});

  @override
  State<TransitPanel> createState() => _TransitPanelState();
}

class _TransitPanelState extends State<TransitPanel> {
  late Future<List<BusRouteInfo>> _busDataFuture;

  @override
  void initState() {
    super.initState();
    _busDataFuture = fetchBusData();
  }

  Future<void> _refresh() async {
    setState(() {
      _busDataFuture = fetchBusData();
    });
    await _busDataFuture;
  }

  @override
  Widget build(BuildContext context) {
    final divider = Divider(height: 1, thickness: 0.7, color: Colors.grey.shade300);

    return RefreshIndicator(
      onRefresh: _refresh,
      child: FutureBuilder<List<BusRouteInfo>>(
        future: _busDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView(
              controller: widget.controller,
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 200),
                Center(child: CircularProgressIndicator()),
                SizedBox(height: 200),
              ],
            );
          }

          if (snapshot.hasError) {
            return ListView(
              controller: widget.controller,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              children: [
                const Icon(Icons.error_outline, size: 40, color: Colors.redAccent),
                const SizedBox(height: 12),
                const Text('대중교통 정보를 불러오지 못했습니다.',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('${snapshot.error}', style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _refresh,
                  icon: const Icon(Icons.refresh),
                  label: const Text('다시 시도'),
                ),
              ],
            );
          }

          final list = snapshot.data ?? const <BusRouteInfo>[];
          if (list.isEmpty) {
            return ListView(
              controller: widget.controller,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              children: const [
                Icon(Icons.directions_bus, size: 40, color: Colors.grey),
                SizedBox(height: 12),
                Text('도착 정보가 없습니다.',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('잠시 후 다시 확인해 주세요.', style: TextStyle(color: Colors.grey)),
              ],
            );
          }

          return ListView(
            controller: widget.controller,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              // 헤더
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 6),
                child: Text(
                  '영남대 앞',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              divider,
              const SizedBox(height: 8),

              // 노선 리스트
              ...list.map((e) => Column(
                    children: [
                      _busRow(e),
                      divider,
                    ],
                  )),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

  /// 노선 한 줄 UI
  Widget _busRow(BusRouteInfo routeInfo) {
    final isEnded = routeInfo.arrList.isNotEmpty &&
        routeInfo.arrList.every(
            (arr) => arr.arrState.contains('운행종료') || arr.bsGap == -2);

    String times;
    if (routeInfo.arrList.isEmpty) {
      times = '도착 정보 없음';
    } else if (isEnded) {
      times = '운행종료';
    } else {
      times = routeInfo.arrList.map((e) {
        if (e.bsGap == -2 || e.arrState.contains('운행종료')) {
          return '운행종료';
        }
        final gapStr = (e.bsGap == null) ? '-' : '${e.bsGap}정류장';
        return '${e.arrState}  $gapStr';
      }).join(',  ');
    }

    // 아이콘 컬러: 직행(직*) 빨강, 그 외 파랑
    final Color iconColor =
        routeInfo.routeNo.startsWith('직') ? Colors.red : Colors.blue;

    return ListTile(
      leading: Icon(Icons.directions_bus, color: iconColor),
      title: Text(
        routeInfo.routeNo,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          times,
          style: TextStyle(color: isEnded ? Colors.grey : Colors.red),
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      dense: false,
    );
  }
}
