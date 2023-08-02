import 'dart:async';

import 'package:adventure_game/adventure_game.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

enum ArrowState { idle, hit }

class Arrow extends SpriteAnimationGroupComponent
    with HasGameRef<AdventureGame>, CollisionCallbacks {
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation hitAnimation;

  double stepTime = 0.06;

  Arrow({
    position,
  }) : super(position: position);

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();

    add(CircleHitbox());

    debugMode = true;

    return super.onLoad();
  }

  SpriteAnimation _spriteAnimation(
      String state, int amount, double x, double y) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Traps/Arrow/$state.png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2(x, y),
      ),
    );
  }

  void _loadAllAnimations() {
    idleAnimation = _spriteAnimation('Idle (18x18)', 10, 18, 18);
    hitAnimation = _spriteAnimation('Hit (18x18)', 10, 18, 18);

    // List of all animations
    animations = {
      ArrowState.idle: idleAnimation,
      ArrowState.hit: hitAnimation,
    };

    current = ArrowState.idle;
  }

  void arrowHit() async {
    current = ArrowState.hit;
    await Future.delayed(const Duration(milliseconds: 500))
        .then((value) => removeFromParent());
  }
}
