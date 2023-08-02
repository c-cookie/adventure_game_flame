import 'package:flame/components.dart';

class CollisionBlock extends PositionComponent {
  bool isPlatform;

  CollisionBlock({
    size,
    position,
    this.isPlatform = false,
  }) : super(
          size: size,
          position: position,
        ) {
    // debugMode = true;
  }
}
