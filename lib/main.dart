import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(GameWidget(game: TestGame()));
}

class TestGame extends FlameGame {
  @override
  FutureOr<void> onLoad() async {
    ui.Image image = await _getImage();

    Rect rect = Rect.fromCenter(center: Offset.zero, width: 400, height: 200);
    Path path = Path()..addOval(rect);
    EffectController controller =
    EffectController(duration: 4.0, infinite: true);
    MoveAlongPathEffect effect =
    MoveAlongPathEffect(path, controller, oriented: true);
    SpriteComponent plane = SpriteComponent(
        anchor: Anchor.center,
        sprite: Sprite(image),
        position: size / 2,
        nativeAngle: -(pi / 2));
    add(plane);
    plane.add(effect);
    return super.onLoad();
  }

  Future<ui.Image> _getImage() async {
    final ByteData assetImageByteData =
    await rootBundle.load('images/nf-plane.png');
    final codec =
    await ui.instantiateImageCodec(assetImageByteData.buffer.asUint8List());
    return (await codec.getNextFrame()).image;
  }
}
