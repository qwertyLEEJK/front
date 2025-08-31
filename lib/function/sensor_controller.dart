import 'dart:async';
import 'dart:math';

import 'package:get/get.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'Predict_request.dart';

class SensorData {
  double x, y, z;
  double pitch, roll, heading;

  SensorData(
    this.x,
    this.y,
    this.z, {
    this.pitch = 0.0,
    this.roll = 0.0,
    this.heading = 0.0,
  });
}

class SensorController extends GetxController {
  var accelerometer = SensorData(0, 0, 0).obs;
  var magnetometer = SensorData(0, 0, 0).obs;
  var gyroscope = SensorData(0, 0, 0).obs;
  var direction = 0.0.obs;

  late StreamSubscription<AccelerometerEvent> _accelSub;
  late StreamSubscription<MagnetometerEvent> _magSub;
  late StreamSubscription<GyroscopeEvent> _gyroSub;
  late StreamSubscription<CompassEvent> _compassSub;

  @override
  void onInit() {
    super.onInit();

    _accelSub = accelerometerEvents.listen((event) {
      accelerometer.update((data) {
        if (data != null) {
          data.x = event.x;
          data.y = event.y;
          data.z = event.z;
        }
      });
      _updatePitchRoll(event.x, event.y, event.z);
    });

    _magSub = magnetometerEvents.listen((event) {
      magnetometer.update((data) {
        if (data != null) {
          data.x = event.x;
          data.y = event.y;
          data.z = event.z;
        }
      });
    });

    _gyroSub = gyroscopeEvents.listen((event) {
      gyroscope.update((data) {
        if (data != null) {
          data.x = event.x;
          data.y = event.y;
          data.z = event.z;
        }
      });
    });

    _compassSub = FlutterCompass.events!.listen((event) {
      final headingVal = event.heading ?? 0;
      direction.value = headingVal;
      accelerometer.update((data) {
        if (data != null) {
          data.heading = headingVal;
        }
      });
    });
  }

  @override
  void onClose() {
    _accelSub.cancel();
    _magSub.cancel();
    _gyroSub.cancel();
    _compassSub.cancel();
    super.onClose();
  }

  /// 라디안 값을 -pi ~ pi로 정규화
  double normalize180(double rad) {
    while (rad <= -pi) rad += 2 * pi;
    while (rad > pi) rad -= 2 * pi;
    return rad;
  }

  // Pitch, Roll 계산 (단위: 라디안)
  void _updatePitchRoll(double ax, double ay, double az) {
    final pitch = atan2(ay, az);

    double roll = atan2(-ax, sqrt(ay * ay + az * az));
    if (az < 0) {
      if (ay >= 0) {
        roll = pi - roll;
      } else {
        roll = -pi - roll;
      }
    }
    roll = normalize180(roll); // <- roll을 -pi ~ pi로 정규화

    accelerometer.update((data) {
      if (data != null) {
        data.pitch = pitch;
        data.roll = roll;
      }
    });
  }

  // API가 요구하는 값에 맞춰서 현재 센서값을 PredictRequest로 반환 (실수값!)
  PredictRequest getCurrentSensorValues() {
    final mag = magnetometer.value;
    final azimuth = direction.value; // heading
    final pitch = accelerometer.value.pitch * 180 / pi; // 라디안 → 도(°)
    final roll = accelerometer.value.roll * 180 / pi;   // 라디안 → 도(°), -180~180 보장

    return PredictRequest(
      magX: mag.x,
      magY: mag.y,
      magZ: mag.z,
      oriAzimuth: azimuth,
      oriPitch: -pitch, //pitch랑 roll 바뀌어서 그냥 바꿔서 적음
      oriRoll: roll,
    );
  }
}
