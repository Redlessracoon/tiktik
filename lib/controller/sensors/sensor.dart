import 'dart:math';

import 'package:esense/config.dart';
import 'package:vector_math/vector_math.dart';

abstract class Sensor {
  Sensor(this.offsetVector, this.scaleFactor);

  Vector3 offsetVector;
  double scaleFactor;

  Vector3 convert(List<int> data) {
    return Vector3(convertEQ(data[0].toDouble()), convertEQ(data[1].toDouble()), convertEQ(data[2].toDouble())) -
        offsetVector;
  }

  double convertEQ(double vertex);
}

class Accel extends Sensor {
  Accel(Vector3 offsetVector, double scaleFactor) : super(offsetVector, scaleFactor);

  @override
  double convertEQ(double vertex) {
    return (vertex / scaleFactor) * G;
  }
}

class Gyro extends Sensor {
  Gyro(Vector3 offsetVector, double scaleFactor) : super(offsetVector, scaleFactor);

  @override
  double convertEQ(double vertex) {
    return vertex / scaleFactor;
  }
}
