import 'dart:async';

import 'package:adventure_game/adventure_game.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Saw extends SpriteAnimationComponent
    with HasGameRef<AdventureGame>, CollisionCallbacks {
  late final SpriteAnimation idleAnimation;

  double stepTime = 0.06;

  late double horizontalMovement;
  late double verticalMovement;
  late final double pathLengthX;
  late final double pathLengthY;
  double moveSpeed = 150;

  bool isVertical;

  late Vector2 initPos;
  Vector2 velocity = Vector2.zero();

  Saw({
    position,
    required this.pathLengthX,
    required this.pathLengthY,
    required this.isVertical,
  }) : super(position: position);

  @override
  FutureOr<void> onLoad() {
    priority = -1;
    verticalMovement = isVertical ? 1 : 0;
    horizontalMovement = isVertical ? 0 : 1;
    initPos = Vector2(position.x, position.y);

    add(CircleHitbox(collisionType: CollisionType.passive));

    // debugMode = true;

    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Traps/Saw/On (38x38).png'),
      SpriteAnimationData.sequenced(
        amount: 8,
        stepTime: stepTime,
        textureSize: Vector2(38, 38),
      ),
    );

    return super.onLoad();
  }

  @override
  void update(double dt) {
    _moveSaw(dt);
    _checkPath();

    super.update(dt);
  }

  void _moveSaw(double dt) {
    if (isVertical) {
      velocity.y = verticalMovement * moveSpeed;
      position.y += velocity.y * dt;
    } else {
      velocity.x = horizontalMovement * moveSpeed;
      position.x += velocity.x * dt;
    }
  }

  void _checkPath() {
    if (!isVertical) {
      if (initPos.x + pathLengthX <= position.x) {
        horizontalMovement = -1;
      } else if (position.x < initPos.x) {
        horizontalMovement = 1;
      }
    } else {
      if (initPos.y + height - pathLengthY <= position.y) {
        verticalMovement = 1;
      } else if (position.x > initPos.y) {
        verticalMovement = -1;
      }
    }
  }
}
