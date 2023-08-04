import 'dart:async';

import 'package:adventure_game/adventure_game.dart';
import 'package:adventure_game/components/player_hitbox.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

enum FireState { idle, hit, activated }

class Fire extends SpriteAnimationGroupComponent
    with HasGameRef<AdventureGame>, CollisionCallbacks {
  bool fireActive = false;

  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation activatedAnimation;
  late final SpriteAnimation hitAnimation;

  double stepTime = 0.06;
  double waitTime = 0;

  double pathLengthX = 190;

  PlayerHitbox hitbox = PlayerHitbox(
    offsetX: 0,
    offsetY: 16,
    width: 16,
    height: 1,
  );

  Fire({
    position,
  }) : super(position: position);

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();

    add(RectangleHitbox(
        position: Vector2(hitbox.offsetX, hitbox.offsetY),
        size: Vector2(hitbox.width, hitbox.height),
        collisionType: CollisionType.passive));

    // debugMode = false;

    return super.onLoad();
  }

  SpriteAnimation _spriteAnimation(
      String state, int amount, double x, double y) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Traps/Fire/$state.png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2(x, y),
      ),
    );
  }

  void _loadAllAnimations() {
    idleAnimation = _spriteAnimation('Off', 1, 16, 32);
    activatedAnimation = _spriteAnimation('On (16x32)', 3, 16, 32);
    hitAnimation = _spriteAnimation('Hit (16x32)', 4, 16, 32);

    // List of all animations
    animations = {
      FireState.idle: idleAnimation,
      FireState.activated: activatedAnimation,
      FireState.hit: hitAnimation,
    };

    // Set current animation

    current = FireState.idle;
  }

  void fireActivated() async {
    current = FireState.hit;

    await Future.delayed(const Duration(milliseconds: 500))
        .then((value) => current = FireState.activated);
    fireActive = true;
    await Future.delayed(const Duration(seconds: 2))
        .then((value) => current = FireState.idle);
    fireActive = false;
  }
}
