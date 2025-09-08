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
    // ApiClient의 get 함수를 호출
    final response = await _apiClient.get('/favorites/');

    // 200번대 응답 코드는 모두 성공으로 간주
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((json) => Favorite.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load favorites. Status code: ${response.statusCode}');
    }
  }

  Future<void> addFavorite(Favorite favorite) async {
    // ApiClient의 post 함수를 호출
    final response = await _apiClient.post(
      '/favorites/',
      body: favorite.toJson(),
    );

    // 200번대 응답 코드는 모두 성공으로 간주
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to add favorite. Status code: ${response.statusCode}');
    }
  }

  Future<void> removeFavorite(String favoriteId) async {
    // ApiClient의 delete 함수를 호출
    final response = await _apiClient.delete('/favorites/$favoriteId');

    // 200번대 응답 코드는 모두 성공으로 간주 (204 포함)
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to delete favorite. Status code: ${response.statusCode}');
    }
  }
}
