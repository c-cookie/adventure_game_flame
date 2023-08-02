import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../adventure_game.dart';
import 'player_hitbox.dart';

enum FruitState { idle, collected }

class Fruit extends SpriteAnimationGroupComponent
    with HasGameRef<AdventureGame>, CollisionCallbacks {
  late final SpriteAnimation appleAnimation;
  late final SpriteAnimation kiwiAnimation;
  late final SpriteAnimation collectedAnimation;

  final double stepTime = 0.04;

  PlayerHitbox hitbox = PlayerHitbox(
    offsetX: 9,
    offsetY: 8,
    width: 14,
    height: 14,
  );

  String fruitName;
  Fruit({
    position,
    this.fruitName = 'Apple',
  }) : super(position: position);

  List<Fruit> fruitBlocks = [];

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();
    // debugMode = true;
    add(RectangleHitbox(
        position: Vector2(hitbox.offsetX, hitbox.offsetY),
        size: Vector2(hitbox.width, hitbox.height),
        collisionType: CollisionType.passive));
    return super.onLoad();
  }

  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Items/Fruits/$state.png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
      ),
    );
  }

  // All done initially
  void _loadAllAnimations() {
    appleAnimation = _spriteAnimation('Apple', 17);
    kiwiAnimation = _spriteAnimation('Kiwi', 17);
    collectedAnimation = _spriteAnimation('Collected', 6);

    // List of all animations
    animations = {
      FruitState.idle: fruitName == 'Apple' ? appleAnimation : kiwiAnimation,
      FruitState.collected: collectedAnimation,
    };

    // Set current animation
    current = FruitState.idle;
  }

  Future<void> doCollectedAnimation() async {
    current = FruitState.collected;
    await Future.delayed(const Duration(milliseconds: 250));
    removeFromParent();
  }
}
