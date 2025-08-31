class Predict {
  final int num;

  Predict({required this.num});

  factory Predict.fromJson(Map<String, dynamic> json) {
    return Predict(num: json['prediction']);
  }
}
