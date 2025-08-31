import 'dart:convert';
import 'package:http/http.dart' as http;
import 'Predict_request.dart';
import 'Predict_response.dart';

class PredictApi {
  static Future<Predict?> fetchPrediction(PredictRequest input) async {
    final url = Uri.parse('http://3.36.52.161:8000/predict');

    try {
      final response = await http.post(
        url,
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(input.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Predict.fromJson(data);
      } else {
        print('요청 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('에러 발생: $e');
    }
    return null;
  }
}
