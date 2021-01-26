import 'package:esense/game/tiktik.dart';
import 'package:esense/game/view.dart';
import 'dart:ui';
import 'package:flame/sprite.dart';

class PauseButton {
  final TikTikGame game;
  Rect rect;
  Sprite sprite;
  bool isHandled = false;

  PauseButton(this.game) {
    rect = Rect.fromLTWH(
      game.screenSize.width - 4 * game.tileSize,
      game.tileSize,
      game.tileSize * 2,
      game.tileSize * 2,
    );
    sprite = Sprite('pause-btn.png');
  }

  void render(Canvas c) {
    sprite.renderRect(c, rect);
  }

  void update(double t) {}

  void onTapDown() {
    game.activeView = View.home;
  }
}
