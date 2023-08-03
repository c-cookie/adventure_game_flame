import 'dart:async';

import 'package:adventure_game/adventure_game.dart';
import 'package:adventure_game/components/collision_block.dart';
import 'package:adventure_game/components/enemies/angry_pig.dart';
import 'package:adventure_game/components/enemies/chicken.dart';
import 'package:adventure_game/components/player_hitbox.dart';
import 'package:adventure_game/components/traps/arrow.dart';
import 'package:adventure_game/components/traps/fan.dart';
import 'package:adventure_game/components/traps/fire.dart';
import 'package:adventure_game/components/traps/saw.dart';
import 'package:adventure_game/components/traps/spike.dart';
import 'package:adventure_game/components/traps/spike_head.dart';
import 'package:adventure_game/components/traps/static_trap.dart';
import 'package:adventure_game/components/utils.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';

import 'box.dart';
import 'fruit.dart';

enum PlayerState { idle, running, jumping, falling, doubleJump, hit, spawn }

// we have a group of animations , SAGC is good for that

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<AdventureGame>, KeyboardHandler, CollisionCallbacks {
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  late final SpriteAnimation jumpingAnimation;
  late final SpriteAnimation fallingAnimation;
  late final SpriteAnimation dblJumpAnimation;
  late final SpriteAnimation hitAnimation;
  late final SpriteAnimation spawnAnimation;

  final double stepTime = 0.05;
  final double _gravity = 12;
  final double _jumpForce = 275;
  final double _terminalVelocity = 300;
  late double diti;

  int jumpCount = 0;

  double horizontalMovement = 0;
  double moveSpeed = 150.0;
  Vector2 velocity = Vector2.zero();
  late final Vector2 initPos;

  List<CollisionBlock> collisionBlocks = [];
  List<Box> boxBlocks = [];
  List<Trap> trapBlocks = [];

  bool isFacingRight = true;
  bool isOnGround = true;
  bool hasJumped = false;
  bool isDead = false;
  bool gotHit = false;

  PlayerHitbox hitbox = PlayerHitbox(
    offsetX: 10,
    offsetY: 4,
    width: 14,
    height: 28,
  );

  String character;
  Player({
    position,
    this.character = 'Virtual Guy',
  }) : super(position: position);

  // Similar to initstate() in original
  @override
  FutureOr<void> onLoad() {
    initPos = Vector2(position.x, position.y);
    _loadAllAnimations();
    // debugMode = true;
    add(RectangleHitbox(
        position: Vector2(hitbox.offsetX, hitbox.offsetY),
        size: Vector2(hitbox.width, hitbox.height)));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    diti = dt;
    if (!gotHit) {
      _updatePlayerMovement(dt);
      if (isOnGround) {
        jumpCount = 0;
      }
      _updatePlayerState();
      _checkHorizontalCollisions(dt);

      _applyGravity(dt);
      _checkVerticalCollisions(dt);
    } // all other general collisions goes here

    super.update(dt);
  }

  @override
  void onRemove() {
    _resetAttributes();
    super.onRemove();
  }

  @override
  void onMount() {
    _spawn();
    super.onMount();
  }

  // This func listens for keyboard events
  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (!isDead) {
      horizontalMovement = 0;

      final isLeftKeyPressed =
          keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
              keysPressed.contains(LogicalKeyboardKey.keyA);
      final isRightKeyPressed =
          keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
              keysPressed.contains(LogicalKeyboardKey.keyD);

      horizontalMovement += isLeftKeyPressed ? -1 : 0;
      horizontalMovement += isRightKeyPressed ? 1 : 0;

      hasJumped = keysPressed.contains(LogicalKeyboardKey.arrowUp) ||
          keysPressed.contains(LogicalKeyboardKey.keyW) ||
          keysPressed.contains(LogicalKeyboardKey.space);
    }
    return super.onKeyEvent(event, keysPressed);
  }

  //TODO: WHAT A GREAT WAY TO CHECK COLLISIONS !!!!
  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Fruit) {
      other.doCollectedAnimation();
    } else if (other is Spikes || other is Saw || other is SpikeHead) {
      _playerDead();
    } else if (other is Chicken) {
      if (velocity.y > 0) {
        _playerJump(diti);
        other.die();
      } else {
        _playerDead();
      }
    } else if (other is AngryPig) {
      if (velocity.y > 0) {
        _playerJump(diti);
        other.gotHit();
      } else {
        _playerDead();
      }
    } else if (other is Arrow) {
      jumpCount = 0;
      _playerJump(diti);
      other.arrowHit();
    } else if (other is Fire) {
      other.fireActive ? _playerDead() : other.fireActivated();
    } else if (other is Fan && other.fanActive) {
      _playerFly(diti);
    }

    super.onCollision(intersectionPoints, other);
  }

  // All done initially
  void _loadAllAnimations() async {
    idleAnimation = _spriteAnimation('Idle', 11);
    runningAnimation = _spriteAnimation('Run', 12);
    jumpingAnimation = _spriteAnimation('Jump', 1);
    fallingAnimation = _spriteAnimation('Fall', 1);
    dblJumpAnimation = _spriteAnimation('Double Jump', 6);
    hitAnimation = _spriteAnimation('Hit', 7);
    spawnAnimation = _spriteAnimation('Appearing', 7);

    // List of all animations
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runningAnimation,
      PlayerState.jumping: jumpingAnimation,
      PlayerState.falling: fallingAnimation,
      PlayerState.doubleJump: dblJumpAnimation,
      PlayerState.hit: hitAnimation,
      PlayerState.spawn: spawnAnimation
    };

    // Set current animation
    current = PlayerState.idle;
  }

  // some cool abstraction for loading sprite animation
  SpriteAnimation _spriteAnimation(String state, int amount) {
    bool isDisAppearing = state.contains('ppearing');
    return SpriteAnimation.fromFrameData(
      isDisAppearing
          ? game.images.fromCache('Main Characters/$state (96x96).png')
          : game.images
              .fromCache('Main Characters/$character/$state (32x32).png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: isDisAppearing ? Vector2.all(96) : Vector2.all(32),
      ),
    );
  }

  void _playerDead() async {
    gotHit = true;
    current = PlayerState.hit;
    await Future.delayed(const Duration(milliseconds: 350)).then((value) {
      scale.x = 1;
      position = initPos - Vector2.all(32);
      current = PlayerState.spawn;
      Future.delayed(const Duration(milliseconds: 350)).then((value) {
        velocity = Vector2.zero();
        position = initPos;
        current = PlayerState.idle;
        Future.delayed(const Duration(milliseconds: 400))
            .then((value) => gotHit = false);
      });
    });
  }

  void _updatePlayerMovement(double dt) {
    // velocity = Vector2(posX, 0);
    if ((hasJumped && isOnGround) ||
        (!isOnGround &&
            jumpCount == 1 &&
            (current == PlayerState.jumping ||
                current == PlayerState.falling) &&
            hasJumped)) {
      _playerJump(dt);
    }
    velocity.x = horizontalMovement * moveSpeed;
    position.x += velocity.x * dt;
  }

  void _playerJump(double dt) {
    if (jumpCount == 2) {
      jumpCount = 0;
      return;
    }
    velocity.y = -_jumpForce;
    position.y += velocity.y * dt;

    hasJumped = false;
    isOnGround = false;
    jumpCount++;
  }

  void _playerFly(double dt) {
    velocity.y = -_jumpForce / 5;
    position.y += velocity.y * dt;
  }

  void _playerLongJump(double dt) {
    if (jumpCount == 2) {
      jumpCount = 0;
      return;
    }
    velocity.y = -_jumpForce * 8;
    position.y += velocity.y * dt;

    hasJumped = false;
    isOnGround = false;
    jumpCount++;
  }

  void _updatePlayerState() {
    PlayerState playerState = PlayerState.idle;

    if (velocity.x < 0 && scale.x > 0) {
      flipHorizontallyAroundCenter();
    } else if (velocity.x > 0 && scale.x < 0) {
      flipHorizontallyAroundCenter();
    }

    if (velocity.x > 0 || velocity.x < 0) playerState = PlayerState.running;

    if (velocity.y > _gravity) playerState = PlayerState.falling;

    if (velocity.y < 0) playerState = PlayerState.jumping;

    if (jumpCount >= 2 && !isOnGround) playerState = PlayerState.doubleJump;

    current = playerState;
  }

  void _checkHorizontalCollisions(double dt) {
    for (final block in collisionBlocks) {
      if (!block.isPlatform) {
        if (checkCollision(this, block)) {
          if (velocity.x > 0) {
            velocity.x = 0;
            position.x = block.x - hitbox.offsetX - hitbox.width;
          }
          if (velocity.x < 0) {
            velocity.x = 0;
            position.x = block.x + block.width + hitbox.width + hitbox.offsetX;
          }
        }
      }
    }
  }

  void _applyGravity(double dt) {
    velocity.y += _gravity;
    velocity.y = velocity.y.clamp(-_jumpForce, _terminalVelocity);
    position.y += velocity.y * dt;
  }

  void _checkVerticalCollisions(double dt) {
    for (final block in collisionBlocks) {
      // Platforms only collide when landing
      if (block.isPlatform) {
        if (velocity.y > 0) {
          velocity.y = 0;
          position.y = block.y - hitbox.height - hitbox.offsetY;
          isOnGround = true;
          break;
        }
      }
      // Not a platform
      else {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;
            break;
          }
          if (velocity.y < 0) {
            velocity.y = 0;
            position.y = block.y + block.height - hitbox.offsetY;
          }
        }
      }
    }

    // Checks for box collision
    for (final box in boxBlocks) {
      if (checkCollisionBox(this, box)) {
        if (box.isRemoved) {
          // Prevents the invisible hitbox to block movement after box breaks
          jumpCount = 1;
          break;
        }
        if (velocity.y > 0) {
          // Jump on it once
          jumpCount = 1;
          _playerJump(dt);
          box.boxHit();
        }
        // Else it acts like a block
        else {
          if (velocity.x > 0) {
            velocity.x = 0;
            position.x = box.x - hitbox.offsetX - hitbox.width;
          }
          if (velocity.x < 0) {
            velocity.x = 0;
            position.x = box.x + box.width + hitbox.width + hitbox.offsetX;
          }
        }
      }
    }

    for (final trap in trapBlocks) {
      switch (trap.trapName) {
        case 'Trampoline':
          if (checkCollisionBox(this, trap)) {
            _playerLongJump(dt);
            jumpCount = 0;
            trap.trampolineActivate();
          }
          break;
        default:
      }
    }
  }

  void _resetAttributes() {
    horizontalMovement = 0;
    current = PlayerState.idle;
    isFacingRight = true;
    isOnGround = false;
    hasJumped = false;
    isDead = false;
    gotHit = false;
  }

  void _spawn() async {
    current = PlayerState.spawn;
    await Future.delayed(const Duration(seconds: 2))
        .then((value) => current = PlayerState.idle);
  }
}
