import 'package:esense/game/tiktik.dart';
import 'package:esense/game/view.dart';
import 'dart:ui';
import 'package:flame/sprite.dart';

class StartButton {
  final TikTikGame game;
  Rect rect;
  Sprite sprite;
  bool isHandled = false;

  StartButton(this.game) {
    rect = Rect.fromLTWH(
      (game.screenSize.width / 2) - (3 * game.tileSize),
      game.screenSize.height - (game.tileSize * 4.5),
      game.tileSize * 6,
      game.tileSize * 3,
    );
    sprite = Sprite('start-btn.png');
  }

  void render(Canvas c) {
    sprite.renderRect(c, rect);
  }

  void update(double t) {}

  void onTapDown() {
    game.activeView = View.playing;
  }
}
