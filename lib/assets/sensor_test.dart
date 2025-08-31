import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../function/sensor_controller.dart';

class SensorTest extends StatelessWidget {
  final SensorController sensorController = Get.put(SensorController());

  SensorTest({super.key});

  String radToDegree(double rad) =>
      (rad * 180 / 3.141592653589793).toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('센서 테스트')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          final accel = sensorController.accelerometer.value;
          final mag = sensorController.magnetometer.value;
          final gyro = sensorController.gyroscope.value;
          final heading = sensorController.direction.value;

          return ListView(
            children: [
              Text(
                '📌 가속도: x=${accel.x.toStringAsFixed(2)}, y=${accel.y.toStringAsFixed(2)}, z=${accel.z.toStringAsFixed(2)}',
              ),
              Text(
                '   ↪ Pitch: ${radToDegree(accel.pitch)}°, Roll: ${radToDegree(accel.roll)}°',
              ),
              const SizedBox(height: 12),
              Text(
                '🧲 자기장: x=${mag.x.toStringAsFixed(2)}, y=${mag.y.toStringAsFixed(2)}, z=${mag.z.toStringAsFixed(2)}',
              ),
              const SizedBox(height: 12),
              Text(
                '🌀 자이로: x=${gyro.x.toStringAsFixed(2)}, y=${gyro.y.toStringAsFixed(2)}, z=${gyro.z.toStringAsFixed(2)}',
              ),
              const SizedBox(height: 12),
              Text('🧭 방향 (Heading): ${heading.toStringAsFixed(2)}°'),
            ],
          );
        }),
      ),
    );
  }
}
