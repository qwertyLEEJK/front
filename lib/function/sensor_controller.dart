import 'dart:async';
import 'dart:math';
import 'package:get/get.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_compass/flutter_compass.dart';

import 'PDRManager.dart';
import 'prediction_service.dart';

class SensorData {
  double x, y, z;
  double pitch, roll, heading;
  SensorData(this.x, this.y, this.z, {this.pitch = 0.0, this.roll = 0.0, this.heading = 0.0});
}

class SensorController extends GetxController {
  var accelerometer = SensorData(0, 0, 0).obs;
  var magnetometer = SensorData(0, 0, 0).obs;
  var gyroscope = SensorData(0, 0, 0).obs;
  var direction = 0.0.obs;

  late StreamSubscription<AccelerometerEvent> _accelSub;
  late StreamSubscription<MagnetometerEvent> _magSub;
  late StreamSubscription<GyroscopeEvent> _gyroSub;
  StreamSubscription<CompassEvent>? _compassSub;

  // ✅ PDR
  final PDRManager pdr = PDRManager();

  // ✅ heading smoothing state
  double _smoothedHeading = 0.0;
  final double _alpha = 0.9; // 0.9 = 매우 부드럽게, 0.5 = 중간, 0.1 = 빠르게 반응

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

      // PDR 업데이트
      final accelMag = sqrt(event.x * event.x + event.y * event.y + event.z * event.z) - 9.81;
      final now = DateTime.now().millisecondsSinceEpoch;
      pdr.update(accelMag.abs(), direction.value, now);
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

    // ✅ Compass (heading) with smoothing
    _compassSub = FlutterCompass.events?.listen((event) {
      final rawHeading = event.heading ?? 0;

      // wrap-around 보정 (359 -> 0 넘어갈 때 점프 방지)
      double diff = rawHeading - _smoothedHeading;
      if (diff > 180) diff -= 360;
      if (diff < -180) diff += 360;

      _smoothedHeading = (_smoothedHeading + (1 - _alpha) * diff) % 360;

      direction.value = _smoothedHeading;
      accelerometer.update((data) {
        if (data != null) {
          data.heading = _smoothedHeading;
        }
      });
    });
  }

  @override
  void onClose() {
    _accelSub.cancel();
    _magSub.cancel();
    _gyroSub.cancel();
    _compassSub?.cancel();
    super.onClose();
  }

  double normalize180(double rad) {
    while (rad <= -pi) rad += 2 * pi;
    while (rad > pi) rad -= 2 * pi;
    return rad;
  }

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
    roll = normalize180(roll);

    accelerometer.update((data) {
      if (data != null) {
        data.pitch = pitch;
        data.roll = roll;
      }
    });
  }

  PredictRequest getCurrentSensorValues() {
    final mag = magnetometer.value;
    final azimuth = direction.value;
    final pitch = accelerometer.value.pitch * 180 / pi;
    final roll = accelerometer.value.roll * 180 / pi;

    final state = pdr.getState();

    return PredictRequest(
      magX: mag.x,
      magY: mag.y,
      magZ: mag.z,
      oriAzimuth: azimuth,
      oriPitch: -pitch,
      oriRoll: roll,
      pdrX: (state['posX'] as num).toDouble(),
      pdrY: (state['posY'] as num).toDouble(),
      stepCount: (state['stepCount'] as num).toInt(),
      lastStepLength: (state['lastStepLength'] as num).toDouble(),
    );
  }
}
