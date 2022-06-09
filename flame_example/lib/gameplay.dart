import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'game.dart';

// Creating this as a file private object so as to
// avoid unwanted rebuilds of the whole game object.
SlimeGame _slimeGame = SlimeGame();

// This class represents the actual game screen
// where all the action happens.
class GamePlay extends StatelessWidget {
  const GamePlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // WillPopScope provides us a way to decide if
    // this widget should be poped or not when user
    // presses the back button.
    return WillPopScope(
      onWillPop: () async => false,
      // GameWidget is useful to inject the underlying
      // widget of any class extending from Flame's Game class.
      child: SafeArea(
        child: GameWidget(
          game: _slimeGame,
        ),
      ),
    );
  }
}
