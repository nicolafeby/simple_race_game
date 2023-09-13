
import 'dart:math';
import 'dart:ui';
import 'package:flame/extensions.dart';
import 'package:flame/palette.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide Particle, World;
import 'package:simple_race_game/core/game_collor/game_color.dart';
import 'package:simple_race_game/core/widget/car.dart';
import 'package:simple_race_game/presentations/racing_game/racing_game.dart';

class Ball extends BodyComponent<PadRacingGame> with ContactCallbacks {
  final double radius;
  final Vector2 position;
  final double rotation;
  final bool isMovable;
  final rng = Random();
  late final Paint _shaderPaint;

  Ball({
    required this.position,
    this.radius = 80.0,
    this.rotation = 1.0,
    this.isMovable = true,
  }) : super(priority: 3);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    renderBody = false;
    _shaderPaint = GameColors.green.paint
      ..shader = Gradient.radial(
        Offset.zero,
        radius,
        [
          GameColors.green.color,
          BasicPalette.black.color,
        ],
        null,
        TileMode.clamp,
        null,
        Offset(radius / 2, radius / 2),
      );
  }

  @override
  Body createBody() {
    final def = BodyDef()
      ..userData = this
      ..type = isMovable ? BodyType.dynamic : BodyType.kinematic
      ..position = position;
    final body = world.createBody(def)..angularVelocity = rotation;

    final shape = CircleShape()..radius = radius;
    final fixtureDef = FixtureDef(shape)
      ..restitution = 0.5
      ..friction = 0.5;
    return body..createFixture(fixtureDef);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(Offset.zero, radius, _shaderPaint);
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (isMovable && other is Car) {
      final carBody = other.body;
      carBody.applyAngularImpulse(3 * carBody.mass * 100);
    }
  }

  late Rect asRect = Rect.fromCircle(
    center: position.toOffset(),
    radius: radius,
  );
}