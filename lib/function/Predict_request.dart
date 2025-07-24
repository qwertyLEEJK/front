class PredictRequest{
  final int magX;
  final int magY;
  final int magZ;
  final int oriX;

  PredictRequest({
    required this.magX,
    required this.magY,
    required this.magZ,
    required this.oriX
  });

  Map<String, dynamic> toJson() {
    return {
      'Mag_X': magX,
      'Mag_Y': magY,
      'Mag_Z': magZ,
      'Ori_X': oriX,
    };
  }
}