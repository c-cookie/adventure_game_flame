import 'dart:async';
import 'dart:math';

import 'package:adventure_game/adventure_game.dart';
import 'package:adventure_game/components/enemies/bullet.dart';
import 'package:adventure_game/components/player_hitbox.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

enum BeeState { idle, attack, hit }

// we have a group of animations , SAGC is good for that

class Bee extends SpriteAnimationGroupComponent
    with HasGameRef<AdventureGame>, CollisionCallbacks {
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation attackAnimation;
  late final SpriteAnimation hitAnimation;

  final double stepTime = 0.06;

  double horizontalMovement = -1;
  late final double moveSpeed;
  Vector2 velocity = Vector2.zero();
  late final Vector2 initPos;

  PlayerHitbox hitbox = PlayerHitbox(
    offsetX: 2,
    offsetY: 0,
    width: 32,
    height: 34,
  );

  late double pathLength;
  final int lenX;
  final int lenY;
  late Vector2 coorI, coorII, coorIII, coorIV;
  late bool passI, passII, passIII, passIV;
  double timeElapsed = 0;

  bool isAttacking = false;

  Bee({
    position,
    required this.lenX,
    required this.lenY,
  }) : super(position: position);

  // Similar to initstate() in original
  @override
  FutureOr<void> onLoad() {
    // debugMode = true;
    initPos = Vector2(position.x, position.y);

    _initialValues();
    _loadAllAnimations();
    _setAttributes();
    _updateBeeState();

    add(RectangleHitbox(
        position: Vector2(hitbox.offsetX, hitbox.offsetY),
        size: Vector2(hitbox.width, hitbox.height)));

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (!isAttacking) {
      timeElapsed += dt;
    }
    _checkPasses();
    _updateBeeMovement(dt);
    _updateBeeState();

    super.update(dt);
  }

  // All done initially
  void _loadAllAnimations() async {
    idleAnimation = _spriteAnimation('Idle (36x34)', 6, 36, 34);
    hitAnimation = _spriteAnimation('Hit (36x34)', 4, 36, 34);
    attackAnimation = _spriteAnimation('Attack (36x34)', 8, 36, 34);

    // List of all animations
    animations = {
      BeeState.hit: hitAnimation,
      BeeState.idle: idleAnimation,
      BeeState.attack: attackAnimation
    };

    // Set current animation
    current = BeeState.idle;
  }

  // some cool abstraction for loading sprite animation
  SpriteAnimation _spriteAnimation(
      String state, int amount, double x, double y) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Enemies/Bee/$state.png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2(x, y),
      ),
    );
  }

  void _updateBeeMovement(double dt) {
    if (!passI && !passIV) {
      position.moveToTarget(coorI, moveSpeed * dt);
    } else if (passIV && !passI) {
      position.moveToTarget(coorI, moveSpeed * dt);
    } else if (passIII) {
      position.moveToTarget(coorIV, moveSpeed * dt);
    } else if (passII) {
      position.moveToTarget(coorIII, moveSpeed * dt);
    } else if (passI) {
      position.moveToTarget(coorII, moveSpeed * dt);
    }
    if (passI && passII && passIII && passIV) {
      _initialValues();
      position.moveToTarget(coorI, moveSpeed * dt);
    }
  }

  void _checkPasses() {
    if (position == coorI) {
      passI = true;
    }
    if (position == coorII) {
      passII = true;
    }
    if (position == coorIII) {
      passIII = true;
    }
    if (position == coorIV) {
      passIV = true;
    }
  }

  void _updateBeeState() async {
    if (timeElapsed >= 4) {
      timeElapsed = 0;
      isAttacking = true;
      current = BeeState.attack;
      for (int i = 0; i < 4; i++) {
        await Future.delayed(const Duration(milliseconds: 600)).then((value) {
          _fireBullet();
        });
      }
      isAttacking = false;
      current = BeeState.idle;
    }
  }

  void _setAttributes() {
    moveSpeed = 100;
  }

  void _fireBullet() {
    game.world.add(Bullet(
      position: Vector2(position.x + width / 2, position.y + height),
    ));
  }

  void die() async {
    current = BeeState.hit;
    await Future.delayed(const Duration(milliseconds: 250));
    removeFromParent();
  }

  void _initialValues() {
    coorI = coorII = coorIII = coorIV = initPos;
    passI = passII = passIII = passIV = false;

    coorI += Vector2(lenX.toDouble(), Random().nextInt(lenY).toDouble());
    coorII += Vector2(Random().nextInt(lenX).toDouble(), lenY.toDouble());
    coorIII += Vector2(0, Random().nextInt(lenY).toDouble());
    coorIV += Vector2(Random().nextInt(lenX).toDouble(), 0);
  }
}
