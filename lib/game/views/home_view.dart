import 'dart:ui';
import 'package:esense/game/tiktik.dart';
import 'package:flame/sprite.dart';

class HomeView {
  final TikTikGame game;
  Rect logoRect;
  Sprite logoSprite;

  HomeView(this.game) {
    logoRect = Rect.fromLTWH(
      (game.screenSize.width / 2) - (9.3 * game.tileSize),
      game.tileSize,
      game.tileSize * 18.6,
      game.tileSize * 10.6,
    );
    logoSprite = Sprite('logo2.png');
  }

  void render(Canvas c) {
    logoSprite.renderRect(c, logoRect);
  }

  void update(double t) {}
}
