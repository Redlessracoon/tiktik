import 'package:esense/config.dart';
import 'package:esense/controller/gestures/gestures.dart';
import 'package:esense/controller/sensors/converted_sensor_event.dart';
import 'package:esense/controller/sensors/sensor.dart';
import 'package:esense_flutter/esense.dart';
import 'package:vector_math/vector_math.dart';

class ESense {
  Stream<ConnectionEvent> get conStream => ESenseManager.connectionEvents;
  Stream<ESenseEvent> get eSenseStream => ESenseManager.eSenseEvents;
  Stream<CSensorEvent> get sensorStream => _sensorStream();

  Sensor accel = Accel(accelOffsetVector, accelScaleFactor);
  Sensor gyro = Gyro(gyroOffsetVector, gyroScaleFactor);

  GestureValidator gv = GestureValidator();

  Stream<CSensorEvent> _sensorStream() {
    return ESenseManager.sensorEvents.distinct().map((event) {
      return CSensorEvent(event.timestamp, accel.convert(event.accel), gyro.convert(event.gyro), []);
    }).map((event) {
      event.gestures = gv.check(event.accelVector);
      return event;
    });
  }
}
