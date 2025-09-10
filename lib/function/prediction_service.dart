import 'dart:convert';
import 'package:http/http.dart' as http;

/// 서버 바디에 지금은 PDR을 보내지 않지만,
/// SensorController가 생성자를 이미 사용 중이라 필드는 유지.
/// (나중에 서버가 받도록 합의되면 toJson에 키만 추가하면 됨)
class PredictRequest {
  final double magX;
  final double magY;
  final double magZ;
  final double oriAzimuth;
  final double oriPitch;
  final double oriRoll;

  // PDR 관련(클라 융합용)
  final double pdrX;
  final double pdrY;
  final int stepCount;
  final double lastStepLength;

  PredictRequest({
    required this.magX,
    required this.magY,
    required this.magZ,
    required this.oriAzimuth,
    required this.oriPitch,
    required this.oriRoll,
    required this.pdrX,
    required this.pdrY,
    required this.stepCount,
    required this.lastStepLength,
  });

  Map<String, dynamic> toJson() {
    // ⚠️ 서버 스키마가 PDR을 아직 받지 않는다고 하셔서 제외
    return {
      'Mag_X': magX,
      'Mag_Y': magY,
      'Mag_Z': magZ,
      'Ori_X': oriAzimuth,
      'Ori_Y': oriPitch,
      'Ori_Z': oriRoll,
      // 'PDR_X': pdrX,
      // 'PDR_Y': pdrY,
      // 'Step_Count': stepCount,
      // 'Last_Step_Length': lastStepLength,
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
