import 'dart:async';
import '../models/favorite_model.dart';

class FavoriteService {
  static final FavoriteService _instance = FavoriteService._internal();
  factory FavoriteService() => _instance;
  FavoriteService._internal();

  // 다양한 유형의 즐겨찾기를 모두 담는 리스트
  final List<Favorite> _favorites = [
    PlaceFavorite(id: 'place_home', name: '집', address: '우리집 주소', category: PlaceCategory.home),
    PlaceFavorite(id: 'place_work', name: '회사', address: '경산북도 경산시 삼풍로 27 영남대학교경산캠퍼스 IT관', category: PlaceCategory.work),
    BusFavorite(id: 'bus_609', name: '학교', busNumber: '609'),
    BusStopFavorite(id: 'stop_12345', name: '영남대 정문', stationName: '영남대정문건너', stationId: '12345'),
  ];

  Future<List<Favorite>> getFavorites() async {
    return _favorites;
  }

  Future<void> addFavorite(Favorite favorite) async {
    if (!_favorites.any((f) => f.id == favorite.id)) {
      _favorites.add(favorite);
    }
  }

  Future<void> removeFavorite(String favoriteId) async {
    _favorites.removeWhere((f) => f.id == favoriteId);
  }
}
