import 'dart:math';

/// 📌 PDRManager
/// - 걸음 검출 (가속도 threshold + peak/trough 방식)
/// - 보폭 추정 (Weinberg 공식)
/// - Δx, Δy 좌표 누적 (East=+X, North=+Y)
class PDRManager {
  // 내부 상태
  int stepCount = 0;
  double lastStepLength = 0.0;
  double posX = 0.0; // 누적 이동 (m) - East
  double posY = 0.0; // 누적 이동 (m) - North

  // 튜닝 가능한 파라미터
  final double accelThreshold; // 가속도 문턱값 (m/s^2)
  final int minStepIntervalMs; // 최소 걸음 간격 (ms)
  final double weinbergK; // 보폭 추정 상수

  // 걸음 검출용 변수
  double? _lastPeak;
  double? _lastTrough;
  bool _waitingForTrough = false;
  int _lastStepMs = 0;

  PDRManager({
    this.accelThreshold = 1.2,
    this.minStepIntervalMs = 250,
    this.weinbergK = 0.41,
  });

  /// 센서 이벤트 업데이트
  /// accelMag: 가속도 크기 (m/s^2), 보통 sqrt(ax^2+ay^2+az^2) - 9.81
  /// headingDeg: 현재 heading (deg, 0=North, 시계방향 증가)
  /// timestampMs: 현재 시간 (ms)
  void update(double accelMag, double headingDeg, int timestampMs) {
    final step = _detectStep(accelMag, timestampMs);

    if (step != null) {
      final stepLength = _estimateStepLength(step['delta']);
      lastStepLength = stepLength;
      stepCount++;

      // Δx, Δy 갱신
      final adjustedHeadingDeg = (headingDeg) % 360; //여기 수정해야 하는 거 아님?
      final rad = adjustedHeadingDeg * pi / 180.0;
      final dx = stepLength * sin(rad); // East
      final dy = stepLength * cos(rad); // North
      posX += dx;
      posY += dy;
    }
  }

  /// 걸음 검출 (피크-트로프 기반)
  Map<String, dynamic>? _detectStep(double accelMag, int timestampMs) {
    if (timestampMs - _lastStepMs < minStepIntervalMs) return null;

    // 피크/트로프 추적
    if (_lastPeak == null || accelMag > _lastPeak!) _lastPeak = accelMag;
    if (_lastTrough == null || accelMag < _lastTrough!) _lastTrough = accelMag;

    if (!_waitingForTrough) {
      // 피크 후보 찾는 중
      if (_lastPeak! > accelThreshold) {
        _waitingForTrough = true;
      }
    } else {
      // 트로프 후보 찾는 중
      if ((_lastPeak! - _lastTrough!) > 0.8) {
        final delta = _lastPeak! - _lastTrough!;
        _lastStepMs = timestampMs;
        _waitingForTrough = false;
        final step = {'delta': delta};
        _lastPeak = null;
        _lastTrough = null;
        return step;
      }
    }
    return null;
  }

  /// 보폭 추정 (Weinberg 공식)
  double _estimateStepLength(double delta) {
    return weinbergK * pow(delta, 0.25);
  }

  /// 현재 상태 가져오기
  Map<String, dynamic> getState() {
    return {
      'stepCount': stepCount,
      'lastStepLength': lastStepLength,
      'posX': posX,
      'posY': posY,
    };
  }

  /// 초기화
  void reset() {
    stepCount = 0;
    lastStepLength = 0.0;
    posX = 0.0;
    posY = 0.0;
    _lastPeak = null;
    _lastTrough = null;
    _waitingForTrough = false;
    _lastStepMs = 0;
  }
}
