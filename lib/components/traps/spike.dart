import 'dart:async';

import 'package:adventure_game/adventure_game.dart';
import 'package:adventure_game/components/player_hitbox.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Spikes extends SpriteAnimationComponent
    with HasGameRef<AdventureGame>, CollisionCallbacks {
  late final SpriteAnimation idleAnimation;
  double stepTime = 0.06;

  PlayerHitbox hitbox =
      PlayerHitbox(offsetX: 0, offsetY: 8, width: 16, height: 8);

  Spikes({
    position,
  }) : super(position: position);

  @override
  FutureOr<void> onLoad() {
    add(RectangleHitbox(
        position: Vector2(hitbox.offsetX, hitbox.offsetY),
        size: Vector2(hitbox.width, hitbox.height)));

    // debugMode = true;
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Traps/Spikes/Idle.png'),
      SpriteAnimationData.sequenced(
        amount: 1,
        stepTime: stepTime,
        textureSize: Vector2(16, 16),
      ),
    );

    return super.onLoad();
  }
}
