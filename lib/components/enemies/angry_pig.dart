import 'dart:async';

import 'package:adventure_game/adventure_game.dart';
import 'package:adventure_game/components/player_hitbox.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

enum PigState { idle, walking, running, dead, angry }

// we have a group of animations , SAGC is good for that

class AngryPig extends SpriteAnimationGroupComponent
    with HasGameRef<AdventureGame>, CollisionCallbacks {
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  late final SpriteAnimation walkAnimation;
  late final SpriteAnimation deadAnimation;
  late final SpriteAnimation angryAnimation;

  final double stepTime = 0.05;
  final Duration hitDuration = const Duration(milliseconds: 250);

  double horizontalMovement = -1;
  late double moveSpeed;
  Vector2 velocity = Vector2.zero();
  late final Vector2 initPos;

  bool hitOnce = false;

  PlayerHitbox hitbox = PlayerHitbox(
    offsetX: 0,
    offsetY: 0,
    width: 36,
    height: 30,
  );

  double hPath; //horizontal path limit
  AngryPig({
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

    add(RectangleHitbox(
        position: Vector2(hitbox.offsetX, hitbox.offsetY),
        size: Vector2(hitbox.width, hitbox.height)));

    return super.onLoad();
  }

  @override
  void update(double dt) {
    _updateEnemyMovement(dt);
    _updateEnemyState();

    super.update(dt);
  }

  // All done initially
  void _loadAllAnimations() async {
    idleAnimation = _spriteAnimation('Idle (36x30)', 9);
    walkAnimation = _spriteAnimation('Walk (36x30)', 16);
    runningAnimation = _spriteAnimation('Run (36x30)', 12);
    angryAnimation = _spriteAnimation('Hit 1 (36x30)', 5);
    deadAnimation = _spriteAnimation('Hit 2 (36x30)', 5);

    // List of all animations
    animations = {
      PigState.walking: walkAnimation,
      PigState.idle: idleAnimation,
      PigState.running: runningAnimation,
      PigState.angry: angryAnimation,
      PigState.dead: deadAnimation
    };

    // Set current animation
    current = PigState.idle;
  }

  // some cool abstraction for loading sprite animation
  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Enemies/AngryPig/$state.png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2(36, 30),
      ),
    );
  }

  void _updateEnemyMovement(double dt) async {
    if (position.x > initPos.x + hPath) {
      flipHorizontallyAroundCenter();
      horizontalMovement = -1;
    } else if (position.x < initPos.x - hPath) {
      flipHorizontallyAroundCenter();
      horizontalMovement = 1;
    }

    moveSpeed = current == PigState.running ? 150 : 100;

    velocity.x = horizontalMovement * moveSpeed;
    position.x += velocity.x * dt;
  }

  void _updateEnemyState() {
    if (velocity.x == 0) {
      current = PigState.idle;
    } else {
      current = hitOnce ? PigState.running : PigState.walking;
    }
  }

  void _setAttributes() {
    moveSpeed = current == PigState.running ? 150 : 100;
    hitOnce = false;
  }

  // checks both hit conditions
  void gotHit() async {
    velocity = Vector2.zero();
    if (!hitOnce) {
      current = PigState.angry;
      await Future.delayed(hitDuration).then((value) => hitOnce = true);
    } else {
      current = PigState.dead;
      await Future.delayed(hitDuration);
      removeFromParent();
    }
  }
}
