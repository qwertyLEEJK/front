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

  DateTime? _lastFetchedAt;
  final Map<int, LocationDto> _cacheById = {};

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

  // 개별 id 조회(캐시 우선)
  Future<void> _loadById(int id) async {
    loading.value = true;
    error.value = null;
    try {
      final now = DateTime.now();
      final isFresh =
          _lastFetchedAt != null && now.difference(_lastFetchedAt!) < _ttl;

      if (!isFresh || !_cacheById.containsKey(id)) {
        // 상세 엔드포인트가 없다고 가정 → 목록 갱신 후 조회
        await fetchAll(); // 필요 시 한 번에 캐시 갱신
      }
      location.value = _cacheById[id];
      if (location.value == null) {
        // 목록에 없으면 서버 스키마가 달라졌을 수 있음 → 안전 처리
        error.value = '해당 위치(id=$id)를 찾을 수 없음';
      }
    } catch (e) {
      error.value = e.toString();
      location.value = null;
    } finally {
      loading.value = false;
    }
  }

  // 전체 목록 가져와 캐시/타임스탬프 갱신
  Future<List<LocationDto>> fetchAll({int skip = 0, int limit = 100}) async {
    final uri = Uri.parse('$_base/locations/?skip=$skip&limit=$limit');
    final res = await http
        .get(uri, headers: {'accept': 'application/json'}).timeout(_timeout);

    if (res.statusCode != 200) {
      throw Exception('GET $uri failed: ${res.statusCode}');
    }

    final List data = jsonDecode(res.body) as List;
    final list = data
        .map((e) => LocationDto.fromJson(e as Map<String, dynamic>))
        .toList();

    _cacheById
      ..clear()
      ..addEntries(list.map((e) => MapEntry(e.id, e)));
    _lastFetchedAt = DateTime.now();
    return list;
  }

  // 필요 시: 개별 상세 엔드포인트가 생기면 이 메서드를 사용
  Future<LocationDto?> fetchByIdDirect(int id) async {
    final uri = Uri.parse('$_base/locations/$id');
    final res = await http
        .get(uri, headers: {'accept': 'application/json'}).timeout(_timeout);
    if (res.statusCode == 200) {
      final dto =
          LocationDto.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
      _cacheById[id] = dto;
      return dto;
    }
    return null;
  }
}
