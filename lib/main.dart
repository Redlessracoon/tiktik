import 'package:esense/game/tiktik.dart';
import 'package:flame/flame.dart';
import 'package:flame/util.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();

  TikTikGame game = TikTikGame();

  Util flameUtil = Util();
  await flameUtil.fullScreen();
  await flameUtil.setOrientation(DeviceOrientation.landscapeRight);
  await Flame.images.loadAll(<String>['logo.png']);

  game.initialize();
  runApp(game.widget);

  TapGestureRecognizer tapper = TapGestureRecognizer();
  tapper.onTapDown = game.onTapDown;
  // ignore: deprecated_member_use
  flameUtil.addGestureRecognizer(tapper);
}
