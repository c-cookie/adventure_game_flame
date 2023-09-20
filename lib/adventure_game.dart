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
    with
        HasKeyboardHandlerComponents,
        DragCallbacks,
        HasCollisionDetection,
        HasGameRef {
  @override
  Color backgroundColor() => const Color(0xFF211F30);
  late CameraComponent cam;
  late Level world;
  Player player = Player(character: 'Pink Man');
  late JoystickComponent joystick;
  late ButtonComponent button;

  bool useMobileControls = true;

  int maxLevel = 5;
  int level = 0;

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
      levelName: 'level-0$level',
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

    if (useMobileControls) {
      addJoystick();
      addButton();
    }

    return super.onLoad();
  }

  void updateJoystick() {
    switch (joystick.direction) {
      case JoystickDirection.left:
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
        player.horizontalMovement = -1;
        break;
      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
        player.horizontalMovement = 1;
        break;

      default:
        player.horizontalMovement = 0;
        break;
    }
  }

  @override
  void update(double dt) {
    if (useMobileControls) {
      updateJoystick();
    }
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
      priority: 10,
    );
    add(joystick);
  }

  void addButton() {
    button = ButtonComponent(
      button: SpriteComponent(
        sprite: Sprite(
          images.fromCache('HUD/Rectangle 1.png'),
        ),
      ),
      onPressed: () {
        if (!player.hasJumped) {
          player.hasJumped = true;
        }
      },
      priority: 10,
    );
    //TODO: Modify button position and remove background
    button.position = gameRef.size - Vector2(150, 150);

    add(button);
  }

  void nextLevel() {
    if (++level <= maxLevel) {
      String randomChar = characters[Random().nextInt(4)];
      player = Player(character: randomChar);

      final newWorld = Level(
        levelName: 'level-0$level',
        player: player,
      );

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
      player = Player(character: randomChar);

      final newWorld = Level(
        levelName: 'level-0$level',
        player: player,
      );

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
      overlays.add('PauseMenu');
      paused = true;
    } else if (paused) {
      overlays.remove('PauseMenu');
      paused = false;
    }
  }

  void restart() {
    String randomChar = characters[Random().nextInt(4)];
    player = Player(character: randomChar);
    final newWorld = Level(
      levelName: 'level-0$level',
      player: player,
    );

    removeAll([world, cam]);

    cam = CameraComponent.withFixedResolution(
      world: newWorld,
      width: 640,
      height: 360,
    );
    cam.viewfinder.anchor = Anchor.topLeft;
    world = newWorld;

    addAll([cam, world]);
  }
}
