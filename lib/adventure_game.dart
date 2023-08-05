import 'dart:async';
import 'dart:math';

import 'package:adventure_game/components/player.dart';
import 'package:adventure_game/components/level.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/painting.dart';

class AdventureGame extends FlameGame
    with HasKeyboardHandlerComponents, DragCallbacks, HasCollisionDetection {
  @override
  Color backgroundColor() => const Color(0xFF211F30);
  late CameraComponent cam;
  late Level world;
  Player player = Player(character: 'Pink Man');
  late JoystickComponent joystick;

  bool showJoystick = true;

  int maxLevel = 2;
  int level = 2;

  List<String> characters = [
    'Mask Dude',
    'Ninja Frog',
    'Pink Man',
    'Virtual Guy'
  ];

  @override
  FutureOr<void> onLoad() async {
    // load em all into cache, might cause loading problems
    await images.loadAllImages();

    world = Level(
      levelName: 'level-02',
      player: player,
    );

    cam = CameraComponent.withFixedResolution(
      world: world,
      width: 640,
      height: 360,
    );
    cam.viewfinder.anchor = Anchor.topLeft;

    addAll([cam, world]);
    add(FpsTextComponent());

    // if (showJoystick) {
    //   addJoystick();
    // }

    return super.onLoad();
  }

  void updateJoystick() {
    switch (joystick.direction) {
      case JoystickDirection.left:
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
        player.horizontalMovement = -1;
        //player.playerDirection = PlayerDirection.left;
        break;
      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
        player.horizontalMovement = 1;
        //player.playerDirection = PlayerDirection.right;
        break;

      default:
        //player.playerDirection = PlayerDirection.none;
        break;
    }
  }

  @override
  void update(double dt) {
    // if (showJoystick) {
    //   updateJoystick();
    // }
    super.update(dt);
  }

  void addJoystick() {
    joystick = JoystickComponent(
      knob: SpriteComponent(
        sprite: Sprite(
          images.fromCache('HUD/Knob.png'),
        ),
      ),
      background: SpriteComponent(
        sprite: Sprite(
          images.fromCache('HUD/Joystick.png'),
        ),
      ),
      margin: const EdgeInsets.only(left: 32, bottom: 86),
    );
    add(joystick);
  }

  void nextLevel() {
    if (++level <= maxLevel) {
      final newWorld = Level(
          levelName: 'Level-0$level', player: Player(character: 'Pink Man'));

      removeAll([world, cam]);

      cam = CameraComponent.withFixedResolution(
        world: newWorld,
        width: 640,
        height: 360,
      );
      cam.viewfinder.anchor = Anchor.topLeft;
      world = newWorld;

      addAll([cam, world]);
    } else {
      level--;
    }
  }

  void prevLevel() {
    if (--level <= maxLevel && level >= 0) {
      String randomChar = characters[Random().nextInt(4)];
      final newWorld = Level(
          levelName: 'Level-0$level', player: Player(character: randomChar));

      removeAll([world, cam]);

      cam = CameraComponent.withFixedResolution(
        world: newWorld,
        width: 640,
        height: 360,
      );
      cam.viewfinder.anchor = Anchor.topLeft;
      world = newWorld;

      addAll([cam, world]);
    } else {
      ++level;
    }
  }

  // Toggle pause action
  void gamePauseToggle() {
    if (!paused) {
      paused = true;
      overlays.add('PauseMenu');
    } else if (paused) {
      paused = false;
      overlays.remove('PauseMenu');
    }
  }
}
