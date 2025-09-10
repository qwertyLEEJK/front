import 'dart:convert';
import 'package:http/http.dart' as http;

class PredictRequest {
  final double magX;
  final double magY;
  final double magZ;
  final double oriAzimuth;
  final double oriPitch;
  final double oriRoll;

  PredictRequest({
    required this.magX,
    required this.magY,
    required this.magZ,
    required this.oriAzimuth,
    required this.oriPitch,
    required this.oriRoll,
  });

  Map<String, dynamic> toJson() {
    return {
      'Mag_X': magX,
      'Mag_Y': magY,
      'Mag_Z': magZ,
      'Ori_X': oriAzimuth,
      'Ori_Y': oriPitch,
      'Ori_Z': oriRoll,
    };
  }
}

class Predict {
  final int num;

  Predict({required this.num});

  factory Predict.fromJson(Map<String, dynamic> json) {
    return Predict(num: json['prediction']);
  }
}

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
