import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:esense/controller/gestures/gestures.dart';
import 'package:esense/game/tiktik.dart';
import 'package:esense/game/components/sword.dart';
import 'package:flame/sprite.dart';
import 'package:vector_math/vector_math.dart';

class Player {
  Player(
      {this.game,
      this.velocity,
      this.lookingDirection,
      this.x,
      this.y,
      this.movingMid,
      this.movingHigh,
      this.movingLow,
      this.attackHigh,
      this.attackLow,
      this.attackMid,
      this.deadSprite}) {
    wh = Vector2(5 * game.tileSize, 5 * game.tileSize);
    playerRect = Rect.fromLTWH(x, y, wh.x, wh.y);
    isDead = false;
    isAttacking = false;
    sword = Sword.mid;
    canMove = true;
    move = GestureType.still;
    oldVelocity = velocity;
  }

  final TikTikGame game;
  Vector2 wh;
  Rect playerRect;
  List<Sprite> movingHigh;
  List<Sprite> movingMid;
  List<Sprite> movingLow;
  Sprite attackHigh;
  Sprite attackMid;
  Sprite attackLow;
  Sprite deadSprite;
  double spriteIndex = 0;
  int velocity;
  int oldVelocity;
  int lookingDirection;
  Sword sword;
  double x;
  double y;
  GestureType move;
  bool isDead;
  bool isAttacking;
  bool canMove;

  void render(Canvas c) {
    Paint paint;
    if (lookingDirection < 0) {
      paint = Paint()..blendMode = BlendMode.hardLight;
    }

    if (isDead) {
      deadSprite.renderRect(c, Rect.fromLTWH(x, y, playerRect.width * 1.5, playerRect.height), overridePaint: paint);
      return;
    }

    Sprite attackingSprite;
    if (isAttacking) {
      switch (sword) {
        case Sword.high:
          attackingSprite = attackHigh;
          break;
        case Sword.mid:
          attackingSprite = attackMid;
          break;
        case Sword.low:
          attackingSprite = attackLow;
          break;
        default:
      }
      attackingSprite.renderRect(c, Rect.fromLTWH(x, y, playerRect.width * 1.5, playerRect.height),
          overridePaint: paint);
      return;
    }

    List<Sprite> spritesPack;
    switch (sword) {
      case Sword.high:
        spritesPack = movingHigh;
        break;
      case Sword.mid:
        spritesPack = movingMid;
        break;
      case Sword.low:
        spritesPack = movingLow;
        break;
      default:
    }
    spritesPack[spriteIndex.toInt()]
        .renderRect(c, Rect.fromLTWH(x, y, playerRect.width * 1.5, playerRect.height), overridePaint: paint);
  }

  void update(double t) {
    if (isDead) {
      return;
    }

    if (isAttacking) {
      return;
    }

    int newVelocity = 0;
    switch (move) {
      case GestureType.left:
        newVelocity = lookingDirection.sign > 0 ? -velocity : velocity;
        break;
      case GestureType.right:
        newVelocity = lookingDirection.sign > 0 ? velocity : -velocity;
        break;
      case GestureType.up:
        newVelocity = oldVelocity;
        switch (sword) {
          case Sword.mid:
            sword = Sword.high;
            break;
          case Sword.low:
            sword = Sword.mid;
            break;
          default:
            break;
        }
        break;
      case GestureType.down:
        newVelocity = oldVelocity;
        switch (sword) {
          case Sword.mid:
            sword = Sword.low;
            break;
          case Sword.high:
            sword = Sword.mid;
            break;
          default:
            break;
        }
        break;
      default:
        // newVelocity = oldVelocity;
        break;
    }

    double translationX = game.tileSize * newVelocity * t;
    double newX = lookingDirection.sign > 0 ? playerRect.left + translationX : playerRect.right + translationX - wh.x;

    if ((lookingDirection > 0 && translationX > 0) || (lookingDirection < 0 && translationX < 0)) {
      if (canMove) {
        if (newX <= game.screenSize.width - 8.5 * game.tileSize && newX >= game.tileSize) {
          x = newX;
          if (translationX != 0) {
            spriteIndex = (spriteIndex + 5 * t) % 2;
            oldVelocity = newVelocity;
          }
          playerRect = playerRect.translate(translationX, 0);
        }
      }
    } else {
      if (newX <= game.screenSize.width - 8.5 * game.tileSize && newX >= game.tileSize) {
        x = newX;
        if (translationX != 0) {
          spriteIndex = (spriteIndex + 5 * t) % 2;
          oldVelocity = newVelocity;
        }
        playerRect = playerRect.translate(translationX, 0);
      }
    }
  }

  void dies() {
    isDead = true;
  }
}
