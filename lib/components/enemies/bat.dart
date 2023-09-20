import 'dart:async';

import 'package:adventure_game/adventure_game.dart';
import 'package:adventure_game/components/player_hitbox.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

enum BatState { idle, flying, hit }

class Bat extends SpriteAnimationGroupComponent
    with HasGameRef<AdventureGame>, CollisionCallbacks {
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation flyingAnimation;
  late final SpriteAnimation hitAnimation;

  final double stepTime = 0.05;

  // When the player enters this radius once, bat will never stop.
  final double followRadius;

  late Vector2 playerPos;

  late final double moveSpeed;
  Vector2 velocity = Vector2.zero();

  bool followsPlayer = false;
  bool isFacingRight = false;
  bool gotHit = false;

  PlayerHitbox hitbox = PlayerHitbox(
    offsetX: 4,
    offsetY: 4,
    width: 38,
    height: 22,
  );

  Bat({
    position,
    required this.followRadius,
  }) : super(position: position);

  @override
  FutureOr<void> onLoad() {
    // debugMode = true;

    _loadAllAnimations();
    _setAttributes();

    //modified hitbox
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
    playerPos = game.world.player.position;
    if (!gotHit) {
      _updateBatState();
      _updateEnemyMovement(dt);
    }
    super.update(dt);
  }

  // All done initially
  void _loadAllAnimations() async {
    idleAnimation = _spriteAnimation('Idle (46x30)', 12);
    hitAnimation = _spriteAnimation('Hit (46x30)', 5);
    flyingAnimation = _spriteAnimation('Flying (46x30)', 7);

    // List of all animations
    animations = {
      BatState.hit: hitAnimation,
      BatState.idle: idleAnimation,
      BatState.flying: flyingAnimation
    };

    // Set current animation
    current = BatState.idle;
  }

  // some cool abstraction for loading sprite animation
  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Enemies/Bat/$state.png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2(46, 30),
      ),
    );
  }

  void _updateEnemyMovement(double dt) async {
    if (followsPlayer && !game.world.player.gotHit) {
      position.moveToTarget(playerPos, moveSpeed * dt);
    }
  }

  // Follows when the player crosses a certain radius
  // Bat will not collide anywhere (im just lazy)
  // Would be funny if the bat ate fruits upon collision though
  void _updateBatState() {
    if (position.distanceTo(playerPos) < followRadius) {
      followsPlayer = true;
      current = BatState.flying;
    }

    if (followsPlayer) {
      if (isFacingRight && position.x > playerPos.x) {
        isFacingRight = false;
        flipHorizontallyAroundCenter();
      }
      if (!isFacingRight && position.x < playerPos.x) {
        isFacingRight = true;
        flipHorizontallyAroundCenter();
      }
    }
  }

  void _setAttributes() {
    moveSpeed = 50;
  }

  void die() async {
    gotHit = true;
    current = BatState.hit;
    await Future.delayed(const Duration(milliseconds: 250));
    removeFromParent();
  }
}
