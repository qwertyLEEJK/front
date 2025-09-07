import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');
  final clientId = dotenv.env['NAVER_MAPS_API_KEY'];
  if (clientId == null || clientId.isEmpty) {
    throw Exception('NAVER_MAPS_API_KEY 가 .env 에 없습니다.');
  }

  await FlutterNaverMap().init(
    clientId: clientId,
    onAuthFailed: (ex) {
      if (ex is NQuotaExceededException) {
        debugPrint("사용량 초과: ${ex.message}");
      } else {
        debugPrint("인증 실패: $ex");
      }
    },
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Naver Map Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Naver Map Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  NaverMapController? _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: NaverMap(
        onMapReady: (controller) async {
          _controller = controller;
          final pos = await _getCurrentPosition();
          if (pos != null) {
            controller.updateCamera(
              NCameraUpdate.scrollAndZoomTo(
                target:  NLatLng(pos.latitude, pos.longitude),
                zoom :16,
              ),
            );
          }
        },
        // 초기 위치(권한 거부/오류 대비 기본값)
        options: const NaverMapViewOptions(
          initialCameraPosition: NCameraPosition(
            target: NLatLng(37.5666102, 126.9783881), // 서울 시청
            zoom: 15,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final pos = await _getCurrentPosition();
          if (pos != null && _controller != null) {
            _controller!.updateCamera(
              NCameraUpdate.scrollAndZoomTo(
                target: NLatLng(pos.latitude, pos.longitude),
                zoom: 16,
              ),
            );
          }
        },
        label: const Text('현재 위치'),
        icon: const Icon(Icons.my_location),
      ),
    );
  }

  /// 위치 권한 확인/요청 + 현재 좌표 반환
  Future<Position?> _getCurrentPosition() async {
    // 서비스 사용 가능 여부
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('위치 서비스가 비활성화됨');
      return null;
    }

    // 권한 상태 확인
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('위치 권한 거부됨');
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint('위치 권한 영구 거부됨(설정에서 허용 필요)');
      return null;
    }

    // 현재 위치 획득
    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
  }
}
