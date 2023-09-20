import 'dart:async';

import 'package:adventure_game/adventure_game.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import 'player_hitbox.dart';

enum BoxState { idle, hit, broken }

class Box extends SpriteAnimationGroupComponent
    with HasGameRef<AdventureGame>, CollisionCallbacks {
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation hitAnimation;
  late final SpriteAnimation breakAnimation;

  final double stepTime = 0.05;
  bool hitOnce = false;

  PlayerHitbox hitbox = PlayerHitbox(
    offsetX: 4,
    offsetY: 3,
    width: 20,
    height: 19,
  );

  String boxName;
  Box({
    position,
    this.boxName = 'Box1',
  }) : super(position: position);

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();
    // debugMode = true;
    add(
      RectangleHitbox(
          position: Vector2(hitbox.offsetX, hitbox.offsetY),
          size: Vector2(hitbox.width, hitbox.height),
          collisionType: CollisionType.passive),
    );
    return super.onLoad();
  }

  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Items/Boxes/$boxName/$state.png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2(28, 24),
      ),
    );
  }

  void _loadAllAnimations() {
    idleAnimation = _spriteAnimation('Idle', 1);
    breakAnimation = _spriteAnimation('Break', 4);
    hitAnimation = _spriteAnimation('Hit (28x24)', 3);

    // List of all animations
    animations = {
      BoxState.idle: idleAnimation,
      BoxState.hit: hitAnimation,
      BoxState.broken: breakAnimation
    };

    // Set current animation
    current = BoxState.idle;
  }

  void boxHit() async {
    current = BoxState.hit;
    await Future.delayed(const Duration(milliseconds: 150));
    if (hitOnce) {
      current = BoxState.broken;
      await Future.delayed(const Duration(milliseconds: 200));
      removeFromParent();
      return;
    }
    hitOnce = true;
    current = BoxState.idle;
  }
}
