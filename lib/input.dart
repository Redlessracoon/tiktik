import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:esense/config.dart';
import 'package:esense/controller/esense.dart';
import 'package:esense/controller/gestures/gestures.dart';
import 'package:esense/controller/math.dart';
import 'package:esense/screens/test_ui.dart';
import 'package:esense_flutter/esense.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart';

class Input {
  ESense device = ESense();

  String deviceName = 'Unknown';
  double voltage = -1;
  String deviceStatus = '';
  bool sampling = false;
  String _event = '';
  String button = 'not pressed';
  StreamSubscription sensorSubscription;
  int nStillsRequired = 5;
  Queue<GestureType> lastGestures = Queue();
  GestureType gesture;
  bool isAttacking = false;
  int queLen = 3;

  Future<void> initialize() async {
    _connectToESense();
  }

  Future<void> _connectToESense() async {
    bool con = false;

    // if you want to get the connection events when connecting, set up the listener BEFORE connecting...
    device.conStream.listen((event) {
      print('CONNECTION event: $event');

      // when we're connected to the eSense device, we can start listening to events from it
      if (event.type == ConnectionType.connected) _listenToESenseEvents();

      switch (event.type) {
        case ConnectionType.connected:
          deviceStatus = 'connected';
          break;
        case ConnectionType.unknown:
          deviceStatus = 'unknown';
          break;
        case ConnectionType.disconnected:
          deviceStatus = 'disconnected';
          break;
        case ConnectionType.device_found:
          deviceStatus = 'device_found';
          break;
        case ConnectionType.device_not_found:
          deviceStatus = 'device_not_found';
          break;
      }
    });

    con = await ESenseManager.connect(eSenseName);
    deviceStatus = con ? 'connecting' : 'connection failed';
  }

  void _listenToESenseEvents() async {
    device.eSenseStream.listen((event) {
      print('ESENSE event: $event');

      switch (event.runtimeType) {
        case BatteryRead:
          voltage = (event as BatteryRead).voltage;
          break;
        case ButtonEventChanged:
          isAttacking = (event as ButtonEventChanged).pressed;
          button = (event as ButtonEventChanged).pressed ? 'pressed' : 'not pressed';
          break;
      }
    });

    _getESenseProperties();
  }

  void _getESenseProperties() async {
    // get the battery level every 10 secs
    Timer.periodic(Duration(seconds: 10), (timer) async => await ESenseManager.getBatteryVoltage());

    // // wait 2, 3, 4, 5, ... secs before getting the name, offset, etc.
    // // it seems like the eSense BTLE interface does NOT like to get called
    // // several times in a row -- hence, delays are added in the following calls
    // Timer(Duration(seconds: 2), () async => await ESenseManager.getDeviceName());
    // Timer(Duration(seconds: 3), () async => await ESenseManager.getAccelerometerOffset());
    // Timer(Duration(seconds: 4), () async => await ESenseManager.getAdvertisementAndConnectionInterval());
    // Timer(Duration(seconds: 5), () async => await ESenseManager.getSensorConfig());
  }

  void _startListenToSensorEvents() async {
    // subscribe to sensor event from the eSense device
    sensorSubscription = device.sensorStream.listen((event) {
      print('SENSOR event: $event');
      event.gestures.forEach((element) {
        // Queue gestures and commit one, only if `inbetween` were <nStillsRequired>
        // of GestureType.still.
        // When queue is full with stills, only then commit a gesture
        if (lastGestures.where((e) => e == GestureType.still).length == nStillsRequired) {
          print('LASTONESTILL but NOW: $element');
          if (element != GestureType.still) gesture = element;
        }
        // if queue full, remove first
        if (lastGestures.length == nStillsRequired) {
          lastGestures.removeFirst();
        }
        // allways add to end of queue
        lastGestures.addLast(element);
      });
    });
    sampling = true;
  }

  void _pauseListenToSensorEvents() async {
    sensorSubscription.cancel();
    sampling = false;
  }

  void dispose() {
    _pauseListenToSensorEvents();
    ESenseManager.disconnect();
  }

  bool playTapped() {
    if (!ESenseManager.connected) {
      return false;
    } else {
      if (!sampling) {
        _startListenToSensorEvents();
        return true;
      }
      return false;
    }
  }

  bool pauseTapped() {
    if (!ESenseManager.connected) {
      return false;
    } else {
      if (sampling) {
        _pauseListenToSensorEvents();
        return true;
      }
      return false;
    }
  }
}
// onPressed: (!ESenseManager.connected)
//     ? null
//     : (!sampling)
//         ? _startListenToSensorEvents
//         : _pauseListenToSensorEvents,
// child: (!sampling) ? Icon(Icons.play_arrow) : Icon(Icons.pause),
