import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame/layers.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(GameWidget(game: TestGame()));
}

class TestGame extends FlameGame {
  @override
  FutureOr<void> onLoad() {
    // Create Test using West Facing Arrow (Path-follow WORKS)
    BaseComponent leftBaseComponent =
        BaseComponent(ArrowComponent(WFArrow(), angle: 0.0, nativeAngle: 0.0));
    leftBaseComponent.size = Vector2(size.x / 2, size.y);
    leftBaseComponent.position = Vector2.zero();
    add(leftBaseComponent);

    // Create Test using North Facing Arrow (Path-follow DOES NOT WORK)
    BaseComponent rightBaseComponent = BaseComponent(
        ArrowComponent(NFArrow(), angle: 0.0, nativeAngle: pi / 2));
    rightBaseComponent.size = Vector2(size.x / 2, size.y);
    rightBaseComponent.position = Vector2(size.x / 2, 0);
    add(rightBaseComponent);
    return super.onLoad();
  }
}

class BaseComponent extends PositionComponent {
  late CircleComponent _waypoint1;
  late CircleComponent _waypoint2;

  late Path _travelPath1;
  late Path _travelPath2;

  final ArrowComponent arrowComponent;

  BaseComponent(this.arrowComponent);

  @override
  FutureOr<void> onLoad() {
    _waypoint1 = CircleComponent(
        radius: 25,
        anchor: Anchor.center,
        position: Vector2(size.x * 0.25, size.y * 0.5),
        paint: Paint()
          ..style = PaintingStyle.stroke
          ..color = Colors.yellowAccent);
    add(_waypoint1);
    _waypoint2 = CircleComponent(
        radius: 25,
        anchor: Anchor.center,
        position: Vector2(size.x * 0.75, size.y * 0.5),
        paint: Paint()
          ..style = PaintingStyle.stroke
          ..color = Colors.yellowAccent);
    add(_waypoint2);

    arrowComponent.position = _waypoint1.position;
    add(arrowComponent);

    String label = arrowComponent.arrow.runtimeType.toString();
    add(TextComponent(
        text: label,
        position: Vector2(size.x / 2, 100),
        anchor: Anchor.center));

    _makeTravelPaths();
    _doTravelPath(_travelPath1);

    return super.onLoad();
  }

  @override
  render(Canvas canvas) {
    canvas.drawPath(
        _travelPath1,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = Colors.white);
    canvas.drawPath(
        _travelPath2,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = Colors.white);
  }

  _makeTravelPaths() {
    double x0 = _waypoint1.position.x;
    double y0 = _waypoint1.position.y;
    double x1 = size.x / 2;
    double y1 = size.y / 2 - 100;
    double x2 = _waypoint2.position.x;
    double y2 = _waypoint2.position.y;
    double x3 = size.x / 2;
    double y3 = size.y / 2 + 100;
    _travelPath1 = Path()
      ..moveTo(x0, y0)
      ..quadraticBezierTo(x1, y1, x2, y2);
    _travelPath2 = Path()
      ..moveTo(x2, y2)
      ..quadraticBezierTo(x3, y3, x0, y0);
  }

  _doTravelPath(Path travelPath) {
    double pathAngle =
        -travelPath.computeMetrics().first.getTangentForOffset(0)!.angle;

    EffectController controller = EffectController(duration: 1);
    Effect rotateEffect =
        RotateEffect.to(pathAngle, controller, onComplete: () {
      // Start arrow motion along travel path
      final pathEffect = MoveAlongPathEffect(
        travelPath,
        absolute: true,
        oriented: true,
        onComplete: () {
          _doTravelPath(
              travelPath == _travelPath1 ? _travelPath2 : _travelPath1);
        },
        EffectController(
          startDelay: 2.0,
          duration: 5.0,
          curve: Curves.easeInOut,
        ),
      );
      arrowComponent.add(pathEffect);
    });
    arrowComponent.add(rotateEffect);
  }
}

class ArrowComponent extends PositionComponent {
  final PreRenderedLayer arrow;

  ArrowComponent(this.arrow, {angle = 0.0, nativeAngle = 0.0})
      : super(
            anchor: Anchor.center,
            size: Vector2.all(30),
            angle: angle,
            nativeAngle: nativeAngle);

  @override
  void render(Canvas canvas) {
    arrow.render(canvas);
    super.render(canvas);
  }
}

class WFArrow extends PreRenderedLayer {
  @override
  void drawLayer() {
    Path path = Path()
      //..shift(const Offset(50, 0))
      ..moveTo(30, 15)
      ..lineTo(20, 25)
      ..lineTo(20, 20)
      ..lineTo(0, 20)
      ..lineTo(0, 10)
      ..lineTo(20, 10)
      ..lineTo(20, 5)
      ..lineTo(30, 15);
    canvas.drawPath(path, Paint()..color = Colors.green);
  }
}

class NFArrow extends PreRenderedLayer {
  @override
  void drawLayer() {
    Path path = Path()
      //..shift(const Offset(50, 0))
      ..moveTo(15, 0)
      ..lineTo(25, 10)
      ..lineTo(20, 10)
      ..lineTo(20, 30)
      ..lineTo(10, 30)
      ..lineTo(10, 10)
      ..lineTo(5, 10)
      ..lineTo(15, 0);
    canvas.drawPath(path, Paint()..color = Colors.red);
  }
}
