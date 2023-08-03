import 'dart:async';

import 'package:adventure_game/adventure_game.dart';
import 'package:adventure_game/components/player_hitbox.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

enum FanState { off, on }

class Fan extends SpriteAnimationGroupComponent
    with HasGameRef<AdventureGame>, CollisionCallbacks {
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation activatedAnimation;

  double stepTime = 0.06;
  double totalTime = 0;

  late final double waitTime;
  late final double flowHeight;

  bool fanActive = false;

  Fan({
    position,
    required this.waitTime,
    required this.flowHeight,
  }) : super(position: position);

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();

    PlayerHitbox hitbox = PlayerHitbox(
        offsetX: 0, offsetY: -flowHeight, width: 24, height: flowHeight);

    add(RectangleHitbox(
        position: Vector2(hitbox.offsetX, hitbox.offsetY),
        size: Vector2(hitbox.width, hitbox.height),
        isSolid: true,
        collisionType: CollisionType.passive));

    // debugMode = true;

    return super.onLoad();
  }

  @override
  void update(double dt) {
    totalTime += dt;
    if (totalTime >= waitTime) {
      _toggleState();
    }

    super.update(dt);
  }

  SpriteAnimation _spriteAnimation(
      String state, int amount, double x, double y) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Traps/Fan/$state.png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2(x, y),
      ),
    );
  }

  void _loadAllAnimations() {
    idleAnimation = _spriteAnimation('Off', 1, 24, 8);
    activatedAnimation = _spriteAnimation('On (24x8)', 4, 24, 8);

    // List of all animations
    animations = {
      FanState.off: idleAnimation,
      FanState.on: activatedAnimation,
    };

    // Set current animation

    current = FanState.off;
  }

  void _toggleState() {
    totalTime = 0;

    // toggle
    fanActive = fanActive ? false : true;
    current = current == FanState.on ? FanState.off : FanState.on;
  }
}
