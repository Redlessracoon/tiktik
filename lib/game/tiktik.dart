import 'dart:math';
import 'dart:ui';
import 'package:esense/controller/gestures/gestures.dart';
import 'package:esense/game/components/pause_btn.dart';
import 'package:esense/game/components/player.dart';
import 'package:esense/game/components/restart_btn.dart';
import 'package:esense/game/components/start_btn.dart';
import 'package:esense/game/view.dart';
import 'package:esense/game/views/home_view.dart';
import 'package:esense/input.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/position.dart';
import 'package:flame/sprite.dart';
import 'package:flame/text_config.dart';
import 'package:flutter/material.dart';

class TikTikGame extends Game {
  Size screenSize;
  double tileSize;
  List<Player> players = List<Player>();
  Player protago;
  Player antago;
  View activeView = View.home;
  HomeView homeView;
  StartButton startButton;
  PauseButton pauseButton;
  RestartButton restartButton;
  TextConfig config = TextConfig(fontSize: 6, fontFamily: 'monospace');
  bool gameOver = false;
  Random rng = Random();

  Input input;
  GestureType lastGesture;

  void initialize() async {
    input = Input();
    input.initialize();

    resize(await Flame.util.initialDimensions());
    homeView = HomeView(this);
    startButton = StartButton(this);
    pauseButton = PauseButton(this);
    restartButton = RestartButton(this);

    protago = spawnProtagonist();
    antago = spawnAntagonist();
  }

  void restart() {
    input.pauseTapped();
    players.clear();
    protago = spawnProtagonist();
    antago = spawnAntagonist();
    activeView = View.home;
    gameOver = false;
  }

  Player spawnPlayer(Player entity) {
    players.add(entity);
    return entity;
  }

  Player spawnProtagonist() {
    return spawnPlayer(Player(
        game: this,
        velocity: 3,
        lookingDirection: 1,
        x: tileSize,
        y: screenSize.height - tileSize * 8,
        movingMid: [Sprite('player/player-0-mid.png'), Sprite('player/player-1-mid.png')],
        movingHigh: [Sprite('player/player-0-high.png'), Sprite('player/player-1-high.png')],
        movingLow: [Sprite('player/player-0-low.png'), Sprite('player/player-1-low.png')],
        attackHigh: Sprite('player/player-high-attack.png'),
        attackMid: Sprite('player/player-mid-attack.png'),
        attackLow: Sprite('player/player-low-attack.png'),
        deadSprite: Sprite('player/player-dead.png')));
  }

  Player spawnAntagonist() {
    return spawnPlayer(Player(
        game: this,
        velocity: -3,
        lookingDirection: -1,
        x: screenSize.width - 8.5 * tileSize,
        y: screenSize.height - tileSize * 8,
        movingMid: [Sprite('player/player-0-mid-f.png'), Sprite('player/player-1-mid-f.png')],
        movingHigh: [Sprite('player/player-0-high-f.png'), Sprite('player/player-1-high-f.png')],
        movingLow: [Sprite('player/player-0-low-f.png'), Sprite('player/player-1-low-f.png')],
        attackHigh: Sprite('player/player-high-attack-f.png'),
        attackMid: Sprite('player/player-mid-attack-f.png'),
        attackLow: Sprite('player/player-low-attack-f.png'),
        deadSprite: Sprite('player/player-dead-f.png')));
  }

  void render(Canvas canvas) {
    Rect bgRect = Rect.fromLTWH(0, 0, screenSize.width, screenSize.height);
    Paint bgPaint = Paint();
    bgPaint.color = Color.fromARGB(255, 0, 0, 0);
    canvas.drawRect(bgRect, bgPaint);

    List<Color> bgColors = [
      Color.fromARGB(255, 208, 0, 0),
      Color.fromARGB(255, 220, 47, 2),
      Color.fromARGB(255, 232, 93, 4),
      Color.fromARGB(255, 244, 140, 6),
      Color.fromARGB(255, 250, 163, 7),
      Color.fromARGB(255, 255, 186, 8)
    ];
    for (var i = 1; i <= bgColors.length; i++) {
      bgPaint.color = bgColors[i - 1];
      canvas.drawRect(
          Rect.fromLTWH(tileSize * 2 * (i - 1), tileSize * 2.5 * (i - 1),
              screenSize.width - 2 * (tileSize * 2 * (i - 1)), screenSize.height - 3 * tileSize),
          bgPaint);
    }

    bgRect = Rect.fromLTWH(0, 0, screenSize.width, screenSize.height);
    bgPaint.color = Color.fromARGB(175, 216, 243, 220);
    canvas.drawRect(bgRect, bgPaint);

    players.forEach((Player p) => p.render(canvas));

    bgColors = [
      Color.fromARGB(255, 8, 28, 21),
      Color.fromARGB(255, 27, 67, 50),
      Color.fromARGB(255, 45, 106, 79),
      Color.fromARGB(255, 64, 145, 108),
      Color.fromARGB(255, 82, 183, 136),
    ];
    for (var i = 1; i <= bgColors.length; i++) {
      bgPaint.color = bgColors[i - 1];
      canvas.drawRect(
          Rect.fromLTWH(tileSize * 2 * (i - 1), screenSize.height - 3 * tileSize,
              screenSize.width - 2 * (tileSize * 2 * (i - 1)), 3 * tileSize),
          bgPaint);
    }

    if (gameOver) {
      restartButton.render(canvas);
    } else {
      if (activeView == View.home) homeView.render(canvas);
      if (activeView == View.home || activeView == View.howto) {
        startButton.render(canvas);
      } else {
        pauseButton.render(canvas);
      }
    }
    showDebugOnScreen(canvas);
  }

  void showDebugOnScreen(Canvas c) {
    config.render(
        c,
        'Status: ${input.deviceStatus} | Volatge: ${input.voltage} | GestureType: ${input.gesture} | IsAttacking: ${input.isAttacking} | Sampling: ${input.sampling}',
        Position(5, 5));
  }

  void update(double t) {
    // check if in playing screen
    if (antago != null && protago != null && activeView == View.playing && !gameOver) {
      protago.isAttacking = input.isAttacking;
      antago.isAttacking = false;

      protago.move = input.gesture;
      antago.move = getRNG();

      protago.canMove = false;
      antago.canMove = false;
      // check if not clushing
      Rect playerWithSword = Rect.fromLTWH(protago.x, 0, protago.wh.x / 2, 1);
      Rect anotherPlayerWithSword = Rect.fromLTWH(antago.x, 0, antago.wh.x / 2, 1);
      if (!playerWithSword.overlaps(anotherPlayerWithSword)) {
        // then they cannot move..
        protago.canMove = true;
        antago.canMove = true;
      } else if (protago.isAttacking) {
        //.. but can still try to attack
        if (protago.sword != antago.sword) {
          antago.dies();
          gameOver = true;
        }
      } else if (rng.nextDouble() <= 0.5) {
        antago.isAttacking = true;
        if (protago.sword != antago.sword) {
          protago.dies();
          gameOver = true;
        }
      }

      protago.update(t);
      antago.update(t);
    }
  }

  GestureType getRNG() {
    double random = rng.nextDouble();
    if (random < 0.1) {
      return GestureType.up;
    }
    if (random < 0.2) {
      return GestureType.down;
    }
    if (random < 0.75) {
      return GestureType.left;
    }
    if (random < 1) {
      return GestureType.right;
    }

    return GestureType.still;
  }

  void resize(Size size) {
    screenSize = size;
    // use most common aspect ration for width (height if landscape) [9]
    tileSize = screenSize.height / 18;
  }

  void onMove(GestureType move) {
    protago.move = move;
  }

  void onTapDown(TapDownDetails d) {
    bool isHandled = false;
    // start button handler
    if (!isHandled && startButton.rect.contains(d.globalPosition)) {
      if ((activeView == View.home || activeView == View.howto) && input.playTapped()) {
        startButton.onTapDown();
        isHandled = true;
      }
    }

    // pause button handler
    if (!isHandled && pauseButton.rect.contains(d.globalPosition)) {
      if (activeView == View.playing && input.pauseTapped()) {
        pauseButton.onTapDown();
        isHandled = true;
      }
    }

    // restart button handler
    if (!isHandled && restartButton.rect.contains(d.globalPosition)) {
      if (activeView == View.playing) {
        restartButton.onTapDown();
        isHandled = true;
      }
    }
  }
}
