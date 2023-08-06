import 'dart:async';

import 'package:adventure_game/adventure_game.dart';
import 'package:adventure_game/components/background_tile.dart';
import 'package:adventure_game/components/collision_block.dart';
import 'package:adventure_game/components/enemies/angry_pig.dart';
import 'package:adventure_game/components/enemies/bat.dart';
import 'package:adventure_game/components/enemies/bee.dart';
import 'package:adventure_game/components/enemies/chicken.dart';
import 'package:adventure_game/components/enemies/mushroom.dart';
import 'package:adventure_game/components/fruit.dart';
import 'package:adventure_game/components/traps/arrow.dart';
import 'package:adventure_game/components/traps/fan.dart';
import 'package:adventure_game/components/traps/fire.dart';
import 'package:adventure_game/components/traps/rock_head.dart';
import 'package:adventure_game/components/traps/saw.dart';
import 'package:adventure_game/components/traps/spike.dart';
import 'package:adventure_game/components/traps/spike_head.dart';
import 'package:adventure_game/components/traps/trampoline.dart';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:adventure_game/components/player.dart';

import 'box.dart';

class Level extends World with HasGameRef<AdventureGame> {
  late TiledComponent level;
  final String levelName;
  final Player player;

  List<CollisionBlock> collisionBlocks = [];
  List<Box> boxBlocks = [];

  final int blockSize = 16;

  Level({required this.levelName, required this.player});

  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load('$levelName.tmx', Vector2.all(16));

    add(level);
    // TODO: Adding a background kills performance
    // _scrollingBackground();

    _spawnObjects();
    _addCollisions();

    return super.onLoad();
  }

  @override
  void update(double dt) {
    // Respawn player when dead
    if (player.isRemoved) {
      player.position = player.initPos;
      add(player);
    }
    super.update(dt);
  }

  void _scrollingBackground() {
    final backgroundLayer = level.tileMap.getLayer('Background');
    const tileSize = 64;

    final numTilesY = (game.size.y / tileSize).floor();
    final numTilesX = (game.size.x / tileSize).floor();

    if (backgroundLayer != null) {
      final backgroundColor =
          backgroundLayer.properties.getValue('BackgroundColor');

      for (double y = 0; y < game.size.y / numTilesY; y++) {
        for (double x = 0; x < numTilesX; x++) {
          final backgroundTile = BackgroundTile(
            color: backgroundColor ?? 'Blue',
            position: Vector2(x * tileSize, y * tileSize - tileSize),
          );

          add(backgroundTile);
        }
      }
    }
  }

  void _spawnObjects() {
    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>('Spawnpoints');

    if (spawnPointsLayer != null) {
      for (final spawnPoint in spawnPointsLayer.objects) {
        switch (spawnPoint.class_) {
          case 'Player':
            player.position = Vector2(spawnPoint.x, spawnPoint.y);
            add(player);
            break;
          case 'Fruit':
            final Fruit fruit = Fruit(fruitName: 'Apple');
            fruit.position = Vector2(spawnPoint.x, spawnPoint.y);
            add(fruit);
            break;
          case 'Box':
            final Box box = Box(boxName: 'Box3');
            box.position = Vector2(spawnPoint.x, spawnPoint.y - 5);
            add(box);
            boxBlocks.add(box);
            break;
          case 'Mushroom':
            final Mushroom mush = Mushroom(
              hPath: spawnPoint.properties.getValue('pathX') * blockSize,
              position: Vector2(spawnPoint.x, spawnPoint.y),
            );
            add(mush);
            break;
          case 'Chicken':
            final Chicken chicken = Chicken(
              hPath: spawnPoint.properties.getValue('pathX') * blockSize,
              position: Vector2(spawnPoint.x, spawnPoint.y),
            );
            add(chicken);
            break;
          case 'AngryPig':
            final AngryPig pig = AngryPig(
              hPath: spawnPoint.properties.getValue('pathX') * blockSize,
              position: Vector2(spawnPoint.x, spawnPoint.y),
            );
            add(pig);
            break;
          case 'Bee':
            final Bee bee = Bee(
              lenX: spawnPoint.properties.getValue('lenX'),
              lenY: spawnPoint.properties.getValue('lenY'),
              position: Vector2(spawnPoint.x, spawnPoint.y),
            );
            add(bee);
            break;
          case 'Bat':
            final Bat bat = Bat(
              followRadius: spawnPoint.properties.getValue('followRadius'),
              position: Vector2(spawnPoint.x, spawnPoint.y),
            );
            add(bat);
            break;
          case 'Spikes':
            final Spikes spike = Spikes(
              position: Vector2(spawnPoint.x, spawnPoint.y),
            );
            add(spike);
            break;
          case 'Arrow':
            final Arrow arrow = Arrow(
              position: Vector2(spawnPoint.x, spawnPoint.y),
            );
            add(arrow);
            break;
          case 'Fire':
            final Fire fire = Fire(
              position: Vector2(spawnPoint.x, spawnPoint.y),
            );
            add(fire);
            break;
          case 'Fan':
            final Fan fan = Fan(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              flowHeight:
                  spawnPoint.properties.getValue('flyHeight') * blockSize,
              waitTime: spawnPoint.properties.getValue('waitTime'),
            );
            add(fan);
            break;
          case 'Saw':
            final Saw spike = Saw(
              isVertical: spawnPoint.properties.getValue('isVertical'),
              pathLengthX: spawnPoint.properties.getValue('pathX') * blockSize,
              pathLengthY: spawnPoint.properties.getValue('pathY') * blockSize,
              position: Vector2(spawnPoint.x, spawnPoint.y),
            );
            add(spike);
            break;
          case 'RockHead':
            final RockHead rock = RockHead(
              isVertical: spawnPoint.properties.getValue('isVertical'),
              pathLengthX: spawnPoint.properties.getValue('pathX') * blockSize,
              pathLengthY: spawnPoint.properties.getValue('pathY') * blockSize,
              position: Vector2(spawnPoint.x, spawnPoint.y),
            );
            add(rock);
            break;
          case 'SpikeHead':
            final SpikeHead sHead = SpikeHead(
              isVertical: spawnPoint.properties.getValue('isVertical'),
              pathLengthX: spawnPoint.properties.getValue('pathX'),
              pathLengthY: spawnPoint.properties.getValue('pathY'),
              position: Vector2(spawnPoint.x, spawnPoint.y),
            );
            add(sHead);
            break;

          case 'Trampoline':
            final Trampoline tramp = Trampoline(
              position: Vector2(spawnPoint.x, spawnPoint.y),
            );
            add(tramp);
            break;
          default:
        }
      }
    }

    player.boxBlocks = boxBlocks;
  }

  void _addCollisions() {
    final collisionsLayer = level.tileMap.getLayer<ObjectGroup>('Collisions');

    if (collisionsLayer != null) {
      for (final collision in collisionsLayer.objects) {
        switch (collision.class_) {
          case 'Platform':
            final platform = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
              isPlatform: true,
            );
            collisionBlocks.add(platform);
            add(platform);
            break;

          default:
            final block = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
            );
            collisionBlocks.add(block);
            add(block);
            break;
        }
      }
    }
    player.collisionBlocks = collisionBlocks;
  }
}
