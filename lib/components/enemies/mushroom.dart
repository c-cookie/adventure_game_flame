import 'dart:async';

import 'package:adventure_game/adventure_game.dart';
import 'package:adventure_game/components/player_hitbox.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

enum MushState { idle, running, hit }

// we have a group of animations , SAGC is good for that

class Mushroom extends SpriteAnimationGroupComponent
    with HasGameRef<AdventureGame>, CollisionCallbacks {
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  late final SpriteAnimation hitAnimation;

  final double stepTime = 0.05;

  double horizontalMovement = -1;
  late final double moveSpeed;
  Vector2 velocity = Vector2.zero();
  late final Vector2 initPos;

  bool isFacingRight = true;

  PlayerHitbox hitbox = PlayerHitbox(
    offsetX: 0,
    offsetY: 16,
    width: 32,
    height: 16,
  );

  double hPath; //horizontal path limit
  Mushroom({
    position,
    required this.hPath,
  }) : super(position: position);

  // Similar to initstate() in original
  @override
  FutureOr<void> onLoad() {
    // debugMode = true;
    initPos = Vector2(position.x, position.y);

    _loadAllAnimations();
    _setAttributes();

    add(
      RectangleHitbox(
          position: Vector2(hitbox.offsetX, hitbox.offsetY),
          size: Vector2(hitbox.width, hitbox.height),
          collisionType: CollisionType.passive),
    );

    return super.onLoad();
  }

  @override
  void update(double dt) {
    _updateEnemyMovement(dt);
    _updateMushState();

    super.update(dt);
  }

  // All done initially
  void _loadAllAnimations() async {
    idleAnimation = _spriteAnimation('Idle (32x32)', 14, 32, 32);
    hitAnimation = _spriteAnimation('Hit', 5, 32, 32);
    runningAnimation = _spriteAnimation('Run (32x32)', 16, 32, 32);

    // List of all animations
    animations = {
      MushState.hit: hitAnimation,
      MushState.idle: idleAnimation,
      MushState.running: runningAnimation
    };

    // Set current animation
    current = MushState.running;
  }

  // some cool abstraction for loading sprite animation
  SpriteAnimation _spriteAnimation(
      String state, int amount, double x, double y) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Enemies/Mushroom/$state.png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2(x, y),
      ),
    );
  }

  void _updateEnemyMovement(double dt) async {
    if (position.x > initPos.x + hPath + width) {
      flipHorizontallyAroundCenter();
      horizontalMovement = -1;
    } else if (position.x < initPos.x - hPath) {
      flipHorizontallyAroundCenter();
      horizontalMovement = 1;
    }

    velocity.x = horizontalMovement * moveSpeed;
    position.x += velocity.x * dt;
  }

  void _updateMushState() {}

  void _setAttributes() {
    moveSpeed = 60;
  }

  void die() async {
    current = MushState.hit;
    await Future.delayed(const Duration(milliseconds: 250));
    removeFromParent();
  }
}
