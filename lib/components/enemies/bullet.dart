import 'dart:async';

import 'package:adventure_game/adventure_game.dart';
import 'package:adventure_game/components/collision_block.dart';
import 'package:adventure_game/components/player_hitbox.dart';
import 'package:adventure_game/components/utils.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Bullet extends SpriteComponent
    with CollisionCallbacks, HasGameRef<AdventureGame> {
  PlayerHitbox hitbox = PlayerHitbox(
    offsetX: 5,
    offsetY: 5,
    width: 6,
    height: 6,
  );

  List<CollisionBlock> collisionBlocks = [];

  double verticalSpeed = 120;

  Bullet({
    position,
  }) : super(position: position);

  @override
  FutureOr<void> onLoad() {
    // debugMode = true;

    // Filter those collisions above the bullet (no chance of touching them)
    // We need a copy of them, not the reference !!
    collisionBlocks = game.world.collisionBlocks.toList();
    collisionBlocks.removeWhere(
      (block) {
        return block.y <= position.y;
      },
    );

    sprite = Sprite(game.images.fromCache('Enemies/Bee/Bullet.png'));

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
    _checkCollision();
    _bulletFall(dt);

    super.update(dt);
  }

  // TODO: Add particle physics after impact
  void _checkCollision() {
    for (final block in collisionBlocks) {
      if (checkCollision(this, block)) {
        removeFromParent();
      }
    }
  }

  void _bulletFall(double dt) {
    position.y += verticalSpeed * dt;
  }
}
