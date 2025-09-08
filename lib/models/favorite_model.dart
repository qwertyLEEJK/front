// 즐겨찾기의 종류를 구분하기 위한 열거형
enum FavoriteType { place, bus, busStop }

// 서버 응답에 맞춘 단일 Favorite 클래스
class Favorite {
  final String id;
  final FavoriteType type;
  final String name;
  final String? address;
  final String? placeCategory;
  final String? busNumber;
  final String? stationName;
  final String? stationId;

  Favorite({
    required this.id,
    required this.type,
    required this.name,
    this.address,
    this.placeCategory,
    this.busNumber,
    this.stationName,
    this.stationId,
  });

  // 서버가 보내준 단일 JSON 객체를 Favorite 객체로 변환
  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['id'],
      name: json['name'],
      // 'type' 문자열을 enum 값으로 변환
      type: FavoriteType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => throw Exception('Unknown type from server: ${json['type']}'),
      ),
      address: json['address'],
      placeCategory: json['place_category'],
      busNumber: json['bus_number'],
      stationName: json['station_name'],
      stationId: json['station_id'],
    );
  }

  // 객체를 JSON으로 변환 (POST 요청 시 사용)
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'type': type.name,
      'name': name,
      'address': address,
      'place_category': placeCategory,
      'bus_number': busNumber,
      'station_name': stationName,
      'station_id': stationId,
    };
    // null인 필드는 JSON에 포함하지 않음
    data.removeWhere((key, value) => value == null);
    return data;
  }
}