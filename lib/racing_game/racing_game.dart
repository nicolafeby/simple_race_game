import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/camera.dart';
import 'package:flame/extensions.dart';
import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide Particle, World;
import 'package:flutter/material.dart' hide Image, Gradient;
import 'package:flutter/services.dart';
import 'package:simple_race_game/core/game_collor/game_color.dart';
import 'package:simple_race_game/core/widget/ball.dart';
import 'package:simple_race_game/core/widget/car.dart';
import 'package:simple_race_game/core/widget/lap_text.dart';
import 'package:simple_race_game/core/widget/lapline.dart';
import 'package:simple_race_game/core/widget/wall.dart';

List<Wall> createWalls(Vector2 size) {
  final topCenter = Vector2(size.x / 2, 0);
  final bottomCenter = Vector2(size.x / 2, size.y);
  final leftCenter = Vector2(0, size.y / 2);
  final rightCenter = Vector2(size.x, size.y / 2);

  final filledSize = size.clone() + Vector2.all(5);
  return [
    Wall(topCenter, Vector2(filledSize.x, 5)),
    Wall(leftCenter, Vector2(5, filledSize.y)),
    Wall(Vector2(52.5, 240), Vector2(5, 380)),
    Wall(Vector2(200, 50), Vector2(300, 5)),
    Wall(Vector2(72.5, 300), Vector2(5, 400)),
    Wall(Vector2(180, 100), Vector2(220, 5)),
    Wall(Vector2(350, 105), Vector2(5, 115)),
    Wall(Vector2(310, 160), Vector2(240, 5)),
    Wall(Vector2(211.5, 400), Vector2(283, 5)),
    Wall(Vector2(351, 312.5), Vector2(5, 180)),
    Wall(Vector2(430, 302.5), Vector2(5, 290)),
    Wall(Vector2(292.5, 450), Vector2(280, 5)),
    Wall(bottomCenter, Vector2(filledSize.y, 5)),
    Wall(rightCenter, Vector2(5, filledSize.y)),
  ];
}

List<Ball> createBalls(Vector2 trackSize, List<Wall> walls, Ball bigBall) {
  final balls = <Ball>[];
  final rng = Random();
  while (balls.length < 20) {
    final ball = Ball(
      position: Vector2.random(rng)..multiply(trackSize),
      radius: 3.0 + rng.nextInt(5),
      rotation: (rng.nextBool() ? 1 : -1) * rng.nextInt(5).toDouble(),
    );
    final touchesBall = ball.position.distanceTo(bigBall.position) <
        ball.radius + bigBall.radius;
    if (!touchesBall) {
      final touchesWall =
          walls.any((wall) => wall.asRect.overlaps(ball.asRect));
      if (!touchesWall) {
        balls.add(ball);
      }
    }
  }
  return balls;
}

final List<Map<LogicalKeyboardKey, LogicalKeyboardKey>> playersKeys = [
  {
    LogicalKeyboardKey.arrowUp: LogicalKeyboardKey.arrowUp,
    LogicalKeyboardKey.arrowDown: LogicalKeyboardKey.arrowDown,
    LogicalKeyboardKey.arrowLeft: LogicalKeyboardKey.arrowLeft,
    LogicalKeyboardKey.arrowRight: LogicalKeyboardKey.arrowRight,
  },
  {
    LogicalKeyboardKey.keyW: LogicalKeyboardKey.arrowUp,
    LogicalKeyboardKey.keyS: LogicalKeyboardKey.arrowDown,
    LogicalKeyboardKey.keyA: LogicalKeyboardKey.arrowLeft,
    LogicalKeyboardKey.keyD: LogicalKeyboardKey.arrowRight,
  },
];

class PadRacingGame extends Forge2DGame with KeyboardEvents {
  PadRacingGame() : super(gravity: Vector2.zero(), zoom: 1);

  static const String description = '''
     This is an example game that uses Forge2D to handle the physics.
     In this game you should finish 3 laps in as little time as possible, it can
     be played as single player or with two players (on the same keyboard).
     Watch out for the balls, they make your car spin.
  ''';

  static const int numberOfLaps = 3;
  static double playZoom = 8.0;
  static Vector2 trackSize = Vector2.all(500);

  late List<Map<LogicalKeyboardKey, LogicalKeyboardKey>> activeKeyMaps;
  late final World cameraWorld;
  final cars = <Car>[];
  bool isGameOver = true;
  late List<Set<LogicalKeyboardKey>> pressedKeySets;
  late CameraComponent startCamera;
  Car? winner;

  double _timePassed = 0;

  @override
  Color backgroundColor() => Colors.black;

  @override
  KeyEventResult onKeyEvent(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    super.onKeyEvent(event, keysPressed);
    if (!isLoaded || isGameOver) {
      return KeyEventResult.ignored;
    }

    _clearPressedKeys();
    // for (final key in keysPressed) {
    //   activeKeyMaps.forEachIndexed((i, keyMap) {
    //     if (keyMap.containsKey(key)) {
    //       pressedKeySets[i].add(keyMap[key]!);
    //     }
    //   });
    // }
    return KeyEventResult.handled;
  }

  @override
  Future<void> onLoad() async {
    children.register<CameraComponent>();
    cameraWorld = World();
    add(cameraWorld);

    final walls = createWalls(trackSize);
    final bigBall = Ball(position: Vector2(200, 245), isMovable: false);
    cameraWorld.addAll([
      LapLine(1, Vector2(25, 50), Vector2(50, 5), false),
      LapLine(2, Vector2(25, 70), Vector2(50, 5), false),
      LapLine(3, Vector2(52.5, 25), Vector2(5, 50), true),
      bigBall,
      ...walls,
      ...createBalls(trackSize, walls, bigBall),
    ]);

    openMenu();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isGameOver) {
      return;
    }
    _timePassed += dt;
  }

  void openMenu() {
    overlays.add('menu');
    final zoomLevel = min(
      canvasSize.x / trackSize.x,
      canvasSize.y / trackSize.y,
    );
    startCamera = CameraComponent(
      world: cameraWorld,
    )
      ..viewfinder.position = trackSize / 2
      ..viewfinder.anchor = Anchor.center
      ..viewfinder.zoom = zoomLevel - 0.2;
    add(startCamera);
  }

  void prepareStart({required int numberOfPlayers}) {
    startCamera.viewfinder
      ..add(
        ScaleEffect.to(
          Vector2.all(playZoom),
          EffectController(duration: 1.0),
          onComplete: () => start(numberOfPlayers: numberOfPlayers),
        ),
      )
      ..add(
        MoveEffect.to(
          Vector2.all(20),
          EffectController(duration: 1.0),
        ),
      );
  }

  void start({required int numberOfPlayers}) {
    isGameOver = false;
    overlays.remove('menu');
    startCamera.removeFromParent();
    final isHorizontal = canvasSize.x > canvasSize.y;
    Vector2 alignedVector({
      required double longMultiplier,
      double shortMultiplier = 1.0,
    }) {
      return Vector2(
        isHorizontal
            ? canvasSize.x * longMultiplier
            : canvasSize.x * shortMultiplier,
        !isHorizontal
            ? canvasSize.y * longMultiplier
            : canvasSize.y * shortMultiplier,
      );
    }

    final viewportSize = alignedVector(longMultiplier: 1 / numberOfPlayers);

    RectangleComponent viewportRimGenerator() =>
        RectangleComponent(size: viewportSize, anchor: Anchor.topLeft)
          ..paint.color = GameColors.blue.color
          ..paint.strokeWidth = 2.0
          ..paint.style = PaintingStyle.stroke;
    final cameras = List.generate(numberOfPlayers, (i) {
      return CameraComponent(
        world: cameraWorld,
        viewport: FixedSizeViewport(viewportSize.x, viewportSize.y)
          ..position = alignedVector(
            longMultiplier: i == 0 ? 0.0 : 1 / (i + 1),
            shortMultiplier: 0.0,
          )
          ..add(viewportRimGenerator()),
      )
        ..viewfinder.anchor = Anchor.center
        ..viewfinder.zoom = playZoom;
    });

    final mapCameraSize = Vector2.all(500);
    const mapCameraZoom = 0.5;
    final mapCameras = List.generate(numberOfPlayers, (i) {
      return CameraComponent(
        world: cameraWorld,
        viewport: FixedSizeViewport(mapCameraSize.x, mapCameraSize.y)
          ..position = Vector2(
            viewportSize.x - mapCameraSize.x * mapCameraZoom - 50,
            50,
          ),
      )
        ..viewfinder.anchor = Anchor.topLeft
        ..viewfinder.zoom = mapCameraZoom;
    });
    addAll(cameras);

    for (var i = 0; i < numberOfPlayers; i++) {
      final car = Car(playerNumber: i, cameraComponent: cameras[i]);
      final lapText = LapText(
        car: car,
        position: Vector2.all(100),
      );

      car.lapNotifier.addListener(() {
        if (car.lapNotifier.value > numberOfLaps) {
          isGameOver = true;
          winner = car;
          overlays.add('gameover');
          lapText.addAll([
            ScaleEffect.by(
              Vector2.all(1.5),
              EffectController(duration: 0.2, alternate: true, repeatCount: 3),
            ),
            RotateEffect.by(pi * 2, EffectController(duration: 0.5)),
          ]);
        } else {
          lapText.add(
            ScaleEffect.by(
              Vector2.all(1.5),
              EffectController(duration: 0.2, alternate: true),
            ),
          );
        }
      });
      cars.add(car);
      cameraWorld.add(car);
      cameras[i].viewport.addAll([lapText, mapCameras[i]]);
    }

    pressedKeySets = List.generate(numberOfPlayers, (_) => {});
    activeKeyMaps = List.generate(numberOfPlayers, (i) => playersKeys[i]);
  }

  void reset() {
    _clearPressedKeys();
    for (final keyMap in activeKeyMaps) {
      keyMap.clear();
    }
    _timePassed = 0;
    overlays.remove('gameover');
    openMenu();
    for (final car in cars) {
      car.removeFromParent();
    }
    for (final camera in children.query<CameraComponent>()) {
      camera.removeFromParent();
    }
  }

  String get timePassed {
    final minutes = _maybePrefixZero((_timePassed / 60).floor());
    final seconds = _maybePrefixZero((_timePassed % 60).floor());
    final ms = _maybePrefixZero(((_timePassed % 1) * 100).floor());
    return [minutes, seconds, ms].join(':');
  }

  void _clearPressedKeys() {
    for (final pressedKeySet in pressedKeySets) {
      pressedKeySet.clear();
    }
  }

  String _maybePrefixZero(int number) {
    if (number < 10) {
      return '0$number';
    }
    return number.toString();
  }
}
