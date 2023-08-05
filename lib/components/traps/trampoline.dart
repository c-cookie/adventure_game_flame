import 'dart:async';

import 'package:adventure_game/adventure_game.dart';
import 'package:adventure_game/components/player_hitbox.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

enum TrampState { idle, activated }

class Trampoline extends SpriteAnimationGroupComponent
    with HasGameRef<AdventureGame>, CollisionCallbacks {
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation activatedAnimation;

  double stepTime = 0.06;

  double pathLengthX = 190;
  late Vector2 initPosition;

  PlayerHitbox hitbox = PlayerHitbox(
    offsetX: 2,
    offsetY: 16,
    width: 28,
    height: 14,
  );

  Trampoline({
    position,
  }) : super(position: position);

  @override
  FutureOr<void> onLoad() {
    initPosition = Vector2(position.x, position.y);
    _loadAllAnimations();

    add(
      RectangleHitbox(
          position: Vector2(hitbox.offsetX, hitbox.offsetY),
          size: Vector2(hitbox.width, hitbox.height),
          collisionType: CollisionType.passive),
    );

    // debugMode = false;

    return super.onLoad();
  }

  SpriteAnimation _spriteAnimation(
      String state, int amount, double x, double y) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Traps/Trampoline/$state.png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2(x, y),
      ),
    );
  }

  void _loadAllAnimations() {
    idleAnimation = _spriteAnimation('Idle', 1, 28, 28);
    activatedAnimation = _spriteAnimation('Jump (28x28)', 8, 28, 28);

    // List of all animations
    animations = {
      TrampState.idle: idleAnimation,
      TrampState.activated: activatedAnimation,
    };

    // Set current animation

    current = TrampState.idle;
  }

  void trampolineActivate() async {
    current = TrampState.activated;
    await Future.delayed(const Duration(milliseconds: 300));
    current = TrampState.idle;
  }
}
