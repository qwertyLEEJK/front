// 서버 통신용 (네트워크 + DTO) 이므로 파일 이름 수정
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

/// ===== DTO =====
class LocationDto {
  final int id;
  final String? locationName;
  final String? description;
  final int floor;
  final String address;

  const LocationDto({
    required this.id,
    required this.locationName,
    required this.description,
    required this.floor,
    required this.address,
  });

  factory LocationDto.fromJson(Map<String, dynamic> j) {
    return LocationDto(
      id: j['id'] as int,
      locationName: j['location_name'] as String?,
      description: j['description'] as String?,
      floor: (j['floor'] as num).toInt(),
      address: j['address'] as String? ?? '',
    );
  }
}

/// ===== 서비스(컨트롤러 통합) =====
/// - markerId 변화 감지 → 자동 조회
/// - 캐시/TTL 내장
class LocationService extends GetxController {
  static const String _base = 'http://3.36.52.161:8000';
  static const Duration _timeout = Duration(seconds: 6);
  static const Duration _ttl = Duration(minutes: 5);

  final RxnInt markerId = RxnInt();
  final RxBool loading = false.obs;
  final Rxn<LocationDto> location = Rxn<LocationDto>();
  final RxnString error = RxnString();

  // 캐시 및 타임스탬프를 ID별로 관리하도록 수정
  final Map<int, LocationDto> _cacheById = {};
  final Map<int, DateTime> _lastFetchedAt = {};

  @override
  void onInit() {
    // markerId 변경을 자동 감지하여 데이터 재조회
    ever<int?>(markerId, (id) async {
      if (id == null) {
        location.value = null;
        return;
      }
      await _loadById(id);
    });
    super.onInit();
  }

  // 외부에서 marker id를 세팅
  void setMarkerId(int? id) => markerId.value = id;

  // [수정됨] 개별 id 조회 (캐시 우선, 만료 시 개별 API 호출)
  Future<void> _loadById(int id) async {
    loading.value = true;
    error.value = null;
    try {
      final now = DateTime.now();
      final lastFetched = _lastFetchedAt[id];
      final isFresh = lastFetched != null && now.difference(lastFetched) < _ttl;

      // 1. 캐시에 있고 신선하면 캐시에서 바로 제공
      if (isFresh && _cacheById.containsKey(id)) {
        location.value = _cacheById[id];
        return; // 여기서 함수 종료
      }

      // 2. 캐시에 없거나 만료되었으면 서버에서 직접 조회
      final fetchedLocation = await fetchByIdDirect(id);
      if (fetchedLocation != null) {
        location.value = fetchedLocation;
      } else {
        // 서버에서도 못 찾은 경우 (404 Not Found 등)
        error.value = '해당 위치(id=$id)를 찾을 수 없음';
        location.value = null;
      }
    } catch (e) {
      error.value = e.toString();
      location.value = null;
    } finally {
      loading.value = false;
    }
  }

  // [수정됨] 개별 상세 엔드포인트를 직접 호출하는 메서드
  Future<LocationDto?> fetchByIdDirect(int id) async {
    final uri = Uri.parse('$_base/locations/$id');
    final res = await http
        .get(uri, headers: {'accept': 'application/json'}).timeout(_timeout);

    if (res.statusCode == 200) {
      final dto =
          LocationDto.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
      _cacheById[id] = dto; // 캐시 갱신
      _lastFetchedAt[id] = DateTime.now(); // 타임스탬프 갱신
      return dto;
    } else if (res.statusCode == 404) {
      // 404 Not Found의 경우 null을 반환하여 '찾을 수 없음'을 명확히 함
      return null;
    } else {
      // 그 외 다른 에러의 경우 예외 발생
      throw Exception('GET $uri failed: ${res.statusCode}');
    }
  }
}
