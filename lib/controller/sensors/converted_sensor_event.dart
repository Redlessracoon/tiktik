import 'package:esense/controller/gestures/gestures.dart';
import 'package:vector_math/vector_math.dart';

class CSensorEvent {
  CSensorEvent(this.timestamp, this.accelVector, this.gyroVector, [this.gestures]);
  DateTime timestamp;
  Vector3 accelVector;
  Vector3 gyroVector;
  List<GestureType> gestures;

  String toString() {
    return '$timestamp: accel = $accelVector | gyro = $gyroVector | gestures = $gestures';
  }
}
