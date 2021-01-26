import 'package:esense/game/tiktik.dart';
import 'package:esense/game/view.dart';
import 'dart:ui';
import 'package:flame/sprite.dart';

class RestartButton {
  final TikTikGame game;
  Rect rect;
  Sprite sprite;
  bool isHandled = false;

  RestartButton(this.game) {
    rect = Rect.fromLTWH(
      (game.screenSize.width / 2) - 2 * game.tileSize,
      (game.screenSize.height / 2) - 2 * game.tileSize,
      game.tileSize * 4,
      game.tileSize * 4,
    );
    sprite = Sprite('restart-btn.png');
  }

  void render(Canvas c) {
    sprite.renderRect(c, rect);
  }

  void update(double t) {}

  void onTapDown() {
    game.restart();
  }
}
