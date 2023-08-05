import 'dart:async';

import 'package:adventure_game/adventure_game.dart';
import 'package:adventure_game/components/player_hitbox.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

enum RockState { idle, blink, bottom, top, left, right }

class SpikeHead extends SpriteAnimationGroupComponent
    with HasGameRef<AdventureGame>, CollisionCallbacks {
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation blinkAnimation;
  late final SpriteAnimation leftHitAnimation;
  late final SpriteAnimation rightHitAnimation;
  late final SpriteAnimation topHitAnimation;
  late final SpriteAnimation bottomHitAnimation;

  double stepTime = 0.06;

  final hitDuration = const Duration(milliseconds: 200);
  final waitDuration = const Duration(seconds: 1);

  late double horizontalMovement;
  late double verticalMovement;
  late final double pathLengthX;
  late final double pathLengthY;
  double moveSpeed = 150;

  bool isVertical;
  bool isHit = false;

  late Vector2 initPos;
  Vector2 velocity = Vector2.zero();

  PlayerHitbox hitbox =
      PlayerHitbox(offsetX: 4, offsetY: 4, width: 46, height: 44);

  SpikeHead({
    position,
    required this.pathLengthX,
    required this.pathLengthY,
    required this.isVertical,
  }) : super(position: position);

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();
    verticalMovement = isVertical ? 1 : 0;
    horizontalMovement = isVertical ? 0 : 1;
    initPos = Vector2(position.x, position.y);

    add(
      RectangleHitbox(
          position: Vector2(hitbox.offsetX, hitbox.offsetY),
          size: Vector2(hitbox.width, hitbox.height),
          collisionType: CollisionType.passive),
    );

    // debugMode = true;

    animations = {
      RockState.blink: blinkAnimation,
      RockState.idle: idleAnimation,
      RockState.top: topHitAnimation,
      RockState.bottom: bottomHitAnimation,
      RockState.left: leftHitAnimation,
      RockState.right: rightHitAnimation
    };

    current = RockState.idle;

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (!isHit) {
      _moveRock(dt);
      _checkPath();
    }
    super.update(dt);
  }

  void _moveRock(double dt) {
    if (isVertical) {
      velocity.y = verticalMovement * moveSpeed;
      position.y += velocity.y * dt;
    } else {
      velocity.x = horizontalMovement * moveSpeed;
      position.x += velocity.x * dt;
    }
  }

  void leftHit() async {
    velocity = Vector2.zero();
    isHit = true;
    current = RockState.left;
    await Future.delayed(hitDuration).then((value) {
      current = RockState.idle;
    });
    await Future.delayed(waitDuration);
    isHit = false;
  }

  void rightHit() async {
    velocity = Vector2.zero();
    isHit = true;
    current = RockState.right;
    await Future.delayed(hitDuration).then((value) {
      current = RockState.idle;
    });
    await Future.delayed(waitDuration);
    isHit = false;
  }

  void topHit() async {
    velocity = Vector2.zero();
    isHit = true;
    current = RockState.top;
    await Future.delayed(hitDuration).then((value) {
      current = RockState.idle;
    });
    isHit = false;
  }

  void bottomHit() async {
    velocity = Vector2.zero();
    isHit = true;
    current = RockState.bottom;
    await Future.delayed(hitDuration).then((value) {
      current = RockState.idle;
    });
    isHit = false;
  }

  void _checkPath() async {
    if (!isVertical) {
      if (initPos.x + pathLengthX < position.x) {
        rightHit();
        horizontalMovement = -1;
      } else if (position.x < initPos.x) {
        leftHit();
        horizontalMovement = 1;
      }
    } else {
      if (initPos.y + height - pathLengthY < position.y) {
        topHit();
        verticalMovement = 1;
      } else if (position.x > initPos.y) {
        bottomHit();
        verticalMovement = -1;
      }
    }
  }

  void _loadAllAnimations() {
    idleAnimation = _spriteAnimation('Idle', 1);
    blinkAnimation = _spriteAnimation('Blink (54x52)', 4);
    topHitAnimation = _spriteAnimation('Top Hit (54x52)', 4);
    bottomHitAnimation = _spriteAnimation('Bottom Hit (54x52)', 4);
    leftHitAnimation = _spriteAnimation('Left Hit (54x52)', 4);
    rightHitAnimation = _spriteAnimation('Right Hit (54x52)', 4);
  }

  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Traps/Spike Head/$state.png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2(54, 52),
      ),
    );
  }
}
