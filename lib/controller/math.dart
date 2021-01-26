import 'dart:math';

import 'package:vector_math/vector_math.dart';

class Quat {
  Quat({this.beta = 0.1, this.q0 = 0.1, this.q1 = 0, this.q2 = 0, this.q3 = 0});

  double beta;
  double q0;
  double q1;
  double q2;
  double q3;

  List<double> get q => [q0, q1, q2, q3];

  void madgwickAHRSupdateIMU(Vector3 gyroVector, Vector3 accelVector, double sampleTime) {
    Vector3 gyro = Vector3.copy(gyroVector);
    Vector3 accel = Vector3.copy(accelVector);
    double recipNorm;
    double s0, s1, s2, s3;
    double qDot1, qDot2, qDot3, qDot4;
    double _2q0, _2q1, _2q2, _2q3, _4q0, _4q1, _4q2, _8q1, _8q2, q0q0, q1q1, q2q2, q3q3;

    // Rate of change of quaternion from gyroscope
    qDot1 = 0.5 * (-q1 * gyro.x - q2 * gyro.y - q3 * gyro.z);
    qDot2 = 0.5 * (q0 * gyro.x + q2 * gyro.z - q3 * gyro.y);
    qDot3 = 0.5 * (q0 * gyro.y - q1 * gyro.z + q3 * gyro.x);
    qDot4 = 0.5 * (q0 * gyro.z + q1 * gyro.y - q2 * gyro.x);

// 	// Compute feedback only if accelerometer measurement valid (avoids NaN in accelerometer normalisation)
    if (!((accel.x == 0) && (accel.y == 0) && (accel.z == 0))) {
// 		// Normalise accelerometer measurement
      recipNorm = invSqrt(accel.x * accel.x + accel.y * accel.y + accel.z * accel.z);
      accel.x *= recipNorm;
      accel.y *= recipNorm;
      accel.z *= recipNorm;

// 		// Auxiliary variables to avoid repeated arithmetic
      _2q0 = 2 * q0;
      _2q1 = 2 * q1;
      _2q2 = 2 * q2;
      _2q3 = 2 * q3;
      _4q0 = 4 * q0;
      _4q1 = 4 * q1;
      _4q2 = 4 * q2;
      _8q1 = 8 * q1;
      _8q2 = 8 * q2;
      q0q0 = q0 * q0;
      q1q1 = q1 * q1;
      q2q2 = q2 * q2;
      q3q3 = q3 * q3;

// 		// Gradient decent algorithm corrective step
      s0 = _4q0 * q2q2 + _2q2 * accel.x + _4q0 * q1q1 - _2q1 * accel.y;
      s1 = _4q1 * q3q3 -
          _2q3 * accel.x +
          4.0 * q0q0 * q1 -
          _2q0 * accel.y -
          _4q1 +
          _8q1 * q1q1 +
          _8q1 * q2q2 +
          _4q1 * accel.z;
      s2 = 4.0 * q0q0 * q2 +
          _2q0 * accel.x +
          _4q2 * q3q3 -
          _2q3 * accel.y -
          _4q2 +
          _8q2 * q1q1 +
          _8q2 * q2q2 +
          _4q2 * accel.z;
      s3 = 4.0 * q1q1 * q3 - _2q1 * accel.x + 4.0 * q2q2 * q3 - _2q2 * accel.y;
      recipNorm = invSqrt(s0 * s0 + s1 * s1 + s2 * s2 + s3 * s3); // normalise step magnitude
      s0 *= recipNorm;
      s1 *= recipNorm;
      s2 *= recipNorm;
      s3 *= recipNorm;

// 		// Apply feedback step
      qDot1 -= beta * s0;
      qDot2 -= beta * s1;
      qDot3 -= beta * s2;
      qDot4 -= beta * s3;
    }

// 	// Integrate rate of change of quaternion to yield quaternion
    q0 += qDot1 * sampleTime;
    q1 += qDot2 * sampleTime;
    q2 += qDot3 * sampleTime;
    q3 += qDot4 * sampleTime;

// 	// Normalise quaternion
    recipNorm = invSqrt(q0 * q0 + q1 * q1 + q2 * q2 + q3 * q3);
    q0 *= recipNorm;
    q1 *= recipNorm;
    q2 *= recipNorm;
    q3 *= recipNorm;
  }

  double invSqrt(double x) {
    return 1 / sqrt(x);
  }

  String toString() {
    return '${roundDouble(q0, 2)}, ${roundDouble(q1, 2)}, ${roundDouble(q2, 2)}, ${roundDouble(q3, 2)}';
  }

  double roundDouble(double value, int places) {
    double mod = pow(10.0, places);
    return ((value * mod).round().toDouble() / mod);
  }

  Vector3 toEuler() {
    double x = q1;
    double y = q2;
    double z = q3;
    double w = q0;
    double t0 = 2.0 * (w * x + y * z);
    double t1 = 1.0 - 2.0 * (x * x + y * y);
    double roll = atan2(t0, t1);
    double t2 = 2.0 * (w * y - z * x);
    t2 = t2 > 1 ? 1 : t2;
    t2 = t2 < -1 ? -1 : t2;
    double pitch = asin(t2);
    double t3 = 2.0 * (w * z + x * y);
    double t4 = 1.0 - 2.0 * (y * y + z * z);
    double yaw = atan2(t3, t4);
    return Vector3(roll, pitch, yaw);
  }
}

class EulerAngles {
  Vector3 angles = Vector3.zero();
  double weight = 0.2;

  void updateIMU(Vector3 gyroVector, Vector3 accelVector, double sampleTime) {
    Vector3 gyro = Vector3.copy(gyroVector);
    Vector3 accel = Vector3.copy(accelVector);
    Vector3 accelAngles;

    angles[0] += gyro[0] * sampleTime;
    angles[1] += gyro[1] * sampleTime;
    angles[2] += gyro[2] * sampleTime;

    accelAngles = Vector3(
        atan2(accel.y, accel.z) * 180 / pi, atan2(accel.x, accel.z) * 180 / pi, atan2(accel.x, accel.y) * 180 / pi);

    angles[0] = (1 - weight) * angles[0] + accelAngles.x * weight;
    angles[1] = (1 - weight) * angles[1] + accelAngles.y * weight;
    angles[2] = (1 - weight) * angles[2] + accelAngles.z * weight;
  }

  String toString() {
    return '$angles';
  }
}
