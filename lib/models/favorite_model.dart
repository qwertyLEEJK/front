// 장소의 종류를 구분하기 위한 열거형
enum PlaceCategory { home, work, convenienceStore, school, etc }

// 즐겨찾기의 최상위 종류를 구분하기 위한 열거형
enum FavoriteType { place, bus, busStop }

// 모든 즐겨찾기 유형의 기반이 되는 추상 클래스
abstract class Favorite {
  final String id;
  final FavoriteType type;
  final String name; // 사용자가 지정하는 이름 (예: "우리 집", "판교 가는 버스")

  Favorite({required this.id, required this.type, required this.name});

  // 나중에 JSON 파싱을 위해 factory 생성자 추가
  // (지금은 구현하지 않아도 되지만 구조상 넣어두는 것이 좋음)
}

// '장소' 유형의 즐겨찾기
class PlaceFavorite extends Favorite {
  final String address;
  final PlaceCategory category;

  PlaceFavorite({
    required String id,
    required String name,
    required this.address,
    required this.category,
  }) : super(id: id, type: FavoriteType.place, name: name);
}

// '버스' 유형의 즐겨찾기
class BusFavorite extends Favorite {
  final String busNumber;

  BusFavorite({
    required String id,
    required String name,
    required this.busNumber,
  }) : super(id: id, type: FavoriteType.bus, name: name);
}

// '정류장' 유형의 즐겨찾기
class BusStopFavorite extends Favorite {
  final String stationName; // 정류장 이름 (예: "영남대정문건너")
  final String stationId;   // 정류장 고유 번호 (예: "12345")

  BusStopFavorite({
    required String id,
    required String name,
    required this.stationName,
    required this.stationId,
  }) : super(id: id, type: FavoriteType.busStop, name: name);
}
