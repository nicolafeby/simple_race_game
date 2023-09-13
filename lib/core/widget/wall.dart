
import 'dart:math';
import 'dart:ui';
import 'package:flame/extensions.dart';
import 'package:flame/palette.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide Particle, World;
import 'package:simple_race_game/presentations/racing_game/racing_game.dart';

class Wall extends BodyComponent<PadRacingGame> {
  Wall(this.position, this.size) : super(priority: 3);

  final Vector2 position;
  final Vector2 size;

  final Random rng = Random();
  late final Image _image;

  final scale = 10.0;
  late final _renderPosition = -size.toOffset() / 2;
  late final _scaledRect = (size * scale).toRect();
  late final _renderRect = _renderPosition & size.toSize();

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    paint.color = ColorExtension.fromRGBHexString('#14F596');

    final recorder = PictureRecorder();
    final canvas = Canvas(recorder, _scaledRect);
    final drawSize = _scaledRect.size.toVector2();
    final center = (drawSize / 2).toOffset();
    const step = 1.0;

    canvas.drawRect(
      Rect.fromCenter(center: center, width: drawSize.x, height: drawSize.y),
      BasicPalette.black.paint(),
    );
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = step;
    for (var x = 0; x < 30; x++) {
      canvas.drawRect(
        Rect.fromCenter(center: center, width: drawSize.x, height: drawSize.y),
        paint,
      );
      paint.color = paint.color.darken(0.07);
      drawSize.x -= step;
      drawSize.y -= step;
    }
    final picture = recorder.endRecording();
    _image = await picture.toImage(
      _scaledRect.width.toInt(),
      _scaledRect.height.toInt(),
    );
  }

  @override
  void render(Canvas canvas) {
    canvas.drawImageRect(
      _image,
      _scaledRect,
      _renderRect,
      paint,
    );
  }

  @override
  Body createBody() {
    final def = BodyDef()
      ..type = BodyType.static
      ..position = position;
    final body = world.createBody(def)
      ..userData = this
      ..angularDamping = 3.0;

    final shape = PolygonShape()..setAsBoxXY(size.x / 2, size.y / 2);
    final fixtureDef = FixtureDef(shape)..restitution = 0.5;
    return body..createFixture(fixtureDef);
  }

  late Rect asRect = Rect.fromCenter(
    center: position.toOffset(),
    width: size.x,
    height: size.y,
  );
}