import 'dart:convert';
// import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';




class BusRouteInfo {
  final String routeNo;
  final List <BusArrival> arrList;

  BusRouteInfo({required this.routeNo, required this.arrList});

  factory BusRouteInfo.fromJson(Map<String, dynamic> json) {
    return BusRouteInfo(
      routeNo: json['routeNo'],
      arrList: (json['arrList'] as List)
          .map((e) => BusArrival.fromJson(e))
          .toList(),
    );
  }
}

class BusArrival {
  final String arrState;
  final int bsGap;
  final String bsNm;

  BusArrival({
    required this.arrState,
    required this.bsGap,
    required this.bsNm,
  });

  factory BusArrival.fromJson(Map<String, dynamic> json) {
    return BusArrival(
      arrState: json['arrState'],
      bsGap: json['bsGap'],
      bsNm: json['bsNm'],
    );
  }
}

Future<List<BusRouteInfo>> fetchBusData() async {
  final url = Uri.parse('https://apis.data.go.kr/6270000/dbmsapi01/getRealtime?serviceKey=%2BjhrV6NTQx%2F7D6dpNIvlvhoCkDaDGBX5Q4YS1YHjXbCIEafa%2F2hbqu79wN94O%2F8009L2H3meXft4RGUHZN1xbw%3D%3D&bsId=7121005800',
  );

  final response = await http.get(url);
  if(response.statusCode != 200) {
    throw Exception('API 요청 실패');
  }

  final data = jsonDecode(response.body);
  final items = data['body']['items'] as List;

  return items.map((e) => BusRouteInfo.fromJson(e)).toList();
}




class BusInfoScreen extends StatefulWidget {
  const BusInfoScreen({super.key});

  @override
  State<BusInfoScreen> createState() => _BusInfoScreenState();
}

class _BusInfoScreenState extends State<BusInfoScreen> {
  late Future<List<BusRouteInfo>> _busDataFuture;

  @override
  void initState() {
    super.initState();
    _busDataFuture = fetchBusData();
  }

  Future<void> _refreshData() async {
    setState(() {
      _busDataFuture = fetchBusData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('버스 정류장 정보'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: FutureBuilder<List<BusRouteInfo>>(
          future: _busDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('에러 발생'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('도착 정보 없음'));
            }

            final busList = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('영남대 앞',
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const Divider(thickness: 1),
                const SizedBox(height: 12),
                ...busList.map(_busRow),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _busRow(BusRouteInfo routeInfo) {
    final isEnded =
        routeInfo.arrList.every((arr) => arr.arrState == "운행종료");

    String times = isEnded
        ? "운행종료"
        : routeInfo.arrList
            .map((e) => '${e.arrState}  ${e.bsGap}정류장')
            .join(',  ');

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.directions_bus, color: isEnded ? Colors.grey : Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${routeInfo.routeNo}  임당삼성 앞 방면',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('기점 ↔ 종점', style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 4),
                Text(times,
                    style: TextStyle(
                        color: isEnded ? Colors.grey : Colors.red)),
              ],
            ),
          )
        ],
      ),
    );
  }
}