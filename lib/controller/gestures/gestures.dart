import 'package:esense/config.dart';
import 'package:vector_math/vector_math.dart';

class GestureValidator {
  double trigger = 7;

  List<GestureType> check(Vector3 inputData) {
    List<GestureType> result = [];
    Vector3 input = inputData.clone();
    double verticalStrength = (input.y - G).abs();
    double horizontalStrength = (input.z).abs();
    // y is up/down    | pos/neg
    // z is right/left | pos/neg

    // remove false positives.
    // if 2 gestures detected, most likely the strongest one is
    // the right one.
    if (verticalStrength > horizontalStrength) {
      // check y:
      if (input.y - G > trigger) {
        result.add(GestureType.up);
      } else if (input.y - G <= -trigger) {
        result.add(GestureType.down);
      }
    } else {
      // check z:
      if (input.z > trigger) {
        result.add(GestureType.left);
      } else if (input.z <= -trigger) {
        result.add(GestureType.right);
      }
    }

    if (result.isEmpty) {
      result.add(GestureType.still);
    }

    return result;
  }
}

enum GestureType { up, down, left, right, still, attack }
