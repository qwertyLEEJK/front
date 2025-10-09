import 'dart:async';
import 'dart:convert';
import '../api/api_client.dart'; // http 대신 ApiClient를 import
import '../models/favorite_model.dart';

class FavoriteService {
  static final FavoriteService _instance = FavoriteService._internal();
  factory FavoriteService() => _instance;
  FavoriteService._internal();

  // ApiClient 인스턴스를 가져와 사용
  final ApiClient _apiClient = ApiClient();

  Future<List<Favorite>> getFavorites() async {
    final response = await _apiClient.get('/favorites/');
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((json) => Favorite.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load favorites. Status code: ${response.statusCode}');
    }
  }

  /// 기존 메서드 (다른 곳에서 쓰고 있으면 유지)
  Future<void> addFavorite(Favorite favorite) async {
    // 주의: favorite.toJson()이 camelCase를 내보내면 백엔드 스키마와 불일치할 수 있음
    final response = await _apiClient.post(
      '/favorites/',
      body: favorite.toJson(),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to add favorite. Status code: ${response.statusCode}');
    }
  }

  /// ✅ 스웨거 스키마에 정확히 맞춘 place 등록 (POST /favorites/)
  /// - type: "place"
  /// - name: 별칭
  /// - address: 주소
  /// - place_category: 'home' | 'work' | 사용자 입력
  /// - bus_number / station_name / station_id: null
  /// - id는 서버 생성 → 보내지 않음(필요하면 주석 풀고 null 전송)
  Future<void> addFavoritePlacePost({
    required String name,
    required String address,
    required String placeCategory,
  }) async {
    final response = await _apiClient.post(
      '/favorites/',
      body: {
        "id": "string3", // 서버가 요구하면 주석 해제
        "type": "place",
        "name": name,
        "address": address,
        "place_category": placeCategory,
        "bus_number": null,
        "station_name": null,
        "station_id": null,
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to add favorite. Status code: ${response.statusCode}, body: ${response.body}');
    }
  }

  Future<void> removeFavorite(String favoriteId) async {
    final response = await _apiClient.delete('/favorites/$favoriteId');
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to delete favorite. Status code: ${response.statusCode}');
    }
  }
}
