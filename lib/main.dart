import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';

import 'adventure_game.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();

  // AdventureGame game = AdventureGame();

  runApp(GameWidget(
    game: AdventureGame(),
    overlayBuilderMap: {
      'PauseMenu': (context, game) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              child: Container(
                alignment: Alignment.centerLeft,
                color: Colors.blueAccent,
                height: 75,
                child: const Text('Game paused.',
                    style: TextStyle(
                        color: Colors.tealAccent,
                        fontWeight: FontWeight.w500,
                        fontSize: 40)),
              ),
            )
          ],
        );
      },
      'Buttons': (context, AdventureGame game) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              height: 25,
              width: 25,
              child: GestureDetector(
                child: const FittedBox(
                  fit: BoxFit.cover,
                  child: Image(
                      image: AssetImage('images/Menu/Buttons/Restart.png')),
                ),
                onTap: () {
                  game.restart();
                },
              ),
            ),
            SizedBox(
              height: 25,
              width: 25,
              child: GestureDetector(
                child: const FittedBox(
                  fit: BoxFit.cover,
                  child: Image(
                      image: AssetImage('images/Menu/Buttons/Previous.png')),
                ),
                onTap: () {
                  game.prevLevel();
                },
              ),
            ),
            SizedBox(
              height: 25,
              width: 25,
              child: GestureDetector(
                child: const FittedBox(
                  fit: BoxFit.cover,
                  child:
                      Image(image: AssetImage('images/Menu/Buttons/Next.png')),
                ),
                onTap: () {
                  game.nextLevel();
                },
              ),
            ),
            SizedBox(
              height: 25,
              width: 25,
              child: GestureDetector(
                child: const FittedBox(
                  fit: BoxFit.cover,
                  child:
                      Image(image: AssetImage('images/Menu/Buttons/Close.png')),
                ),
                onTap: () {
                  game.gamePauseToggle();
                },
              ),
            ),
          ],
        );
      },
    },
    initialActiveOverlays: const ['Buttons'],
  ));
  // runApp(GameWidget(game: kDebugMode ? AdventureGame() : game));
}
