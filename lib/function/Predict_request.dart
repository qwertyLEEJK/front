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

