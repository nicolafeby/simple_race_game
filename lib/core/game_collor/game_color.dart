import 'package:flame/palette.dart';
import 'package:flutter/material.dart';

enum GameColors {
  green,
  blue,
}

extension GameColorExtension on GameColors {
  Color get color {
    switch (this) {
      case GameColors.green:
        return ColorExtension.fromRGBHexString('#14F596');
      case GameColors.blue:
        return ColorExtension.fromRGBHexString('#81DDF9');
    }
  }

  Paint get paint => Paint()..color = color;
}