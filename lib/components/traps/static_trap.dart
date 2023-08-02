import 'dart:async';

import 'package:adventure_game/adventure_game.dart';
import 'package:adventure_game/components/player_hitbox.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

enum TrapState { idle, hit, activated }

class Trap extends SpriteAnimationGroupComponent
    with HasGameRef<AdventureGame>, CollisionCallbacks {
  bool isStatic; // otherwise it moves in a fixed path
  bool needCollbox;
  bool fireActive = false;

  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation activatedAnimation;
  late final SpriteAnimation hitAnimation;

  double stepTime = 0.06;
  double waitTime = 0;

  double horizontalMovement = 1;
  double verticalMovement = 0;
  double moveSpeed = 150;
  Vector2 velocity = Vector2.zero();

  double pathLengthX = 190;
  late Vector2 initPosition;

  PlayerHitbox hitbox =
      PlayerHitbox(offsetX: 0, offsetY: 0, width: 0, height: 0);

  String trapName;
  Trap({
    position,
    required this.trapName,
    this.isStatic = false,
    this.needCollbox = false,
  }) : super(position: position);

  @override
  FutureOr<void> onLoad() {
    initPosition = Vector2(position.x, position.y);
    _loadAllAnimations();

    if (needCollbox) {
      _addHitbox();
      add(RectangleHitbox(
          position: Vector2(hitbox.offsetX, hitbox.offsetY),
          size: Vector2(hitbox.width, hitbox.height)));
    }
    // debugMode = false;

    return super.onLoad();
  }

  @override
  void update(double dt) {
    waitTime += dt;
    if (waitTime >= 6) {
      _toggleState();
    }

    super.update(dt);
  }

  void _addHitbox() {
    switch (trapName) {
      case 'Trampoline':
        hitbox = PlayerHitbox(
          offsetX: 2,
          offsetY: 16,
          width: 28,
          height: 14,
        );
        break;
      case 'Fire':
        hitbox = PlayerHitbox(
          offsetX: 0,
          offsetY: 16,
          width: 16,
          height: 1,
        );
        break;
      default:
    }
  }

  SpriteAnimation _spriteAnimation(
      String state, int amount, double x, double y) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Traps/$trapName/$state.png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2(x, y),
      ),
    );
  }

  void _loadAllAnimations() {
    switch (trapName) {
      case 'Trampoline':
        idleAnimation = _spriteAnimation('Idle', 1, 28, 28);
        activatedAnimation = _spriteAnimation('Jump (28x28)', 8, 28, 28);
        hitAnimation = idleAnimation;
        break;
      case 'Fan':
        idleAnimation = _spriteAnimation('Off', 1, 24, 8);
        activatedAnimation = _spriteAnimation('On (24x8)', 4, 24, 8);
        hitAnimation = idleAnimation;
        break;
      case 'Fire':
        idleAnimation = _spriteAnimation('Off', 1, 16, 32);
        activatedAnimation = _spriteAnimation('On (16x32)', 3, 16, 32);
        hitAnimation = _spriteAnimation('Hit (16x32)', 4, 16, 32);
        break;
      case 'Arrow':
        idleAnimation = _spriteAnimation('Idle (18x18)', 10, 18, 18);
        hitAnimation = _spriteAnimation('Hit (18x18)', 10, 18, 18);
        activatedAnimation = idleAnimation;
        break;
      default:
    }

    // List of all animations
    animations = {
      TrapState.idle: idleAnimation,
      TrapState.activated: activatedAnimation,
      TrapState.hit: hitAnimation,
    };

    // Set current animation

    current = TrapState.idle;
  }

  void trampolineActivate() async {
    current = TrapState.activated;
    await Future.delayed(const Duration(milliseconds: 300));
    current = TrapState.idle;
  }

  void _toggleState() {
    waitTime = 0;

    // Toggle current state
    if (['Fan'].contains(trapName)) {
      current = current == TrapState.activated // toggle
          ? TrapState.idle
          : TrapState.activated;
    }
  }

  void fireActivated() async {
    current = TrapState.hit;

    await Future.delayed(const Duration(milliseconds: 500))
        .then((value) => current = TrapState.activated);
    fireActive = true;
    await Future.delayed(const Duration(seconds: 2))
        .then((value) => current = TrapState.idle);
    fireActive = false;
  }

  void arrowHit() async {
    current = TrapState.hit;
    await Future.delayed(const Duration(milliseconds: 500))
        .then((value) => removeFromParent());
  }
}
