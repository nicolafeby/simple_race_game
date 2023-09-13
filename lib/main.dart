import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:simple_race_game/presentations/game_menu/menu/game_menu.dart';
import 'package:simple_race_game/presentations/game_over/game_over.dart';
import 'package:simple_race_game/presentations/racing_game/racing_game.dart';

void main() {
  runApp(const PadracingWidget());
}

class PadracingWidget extends StatelessWidget {
  const PadracingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PadRacing',
      home: GameWidget<PadRacingGame>(
        game: PadRacingGame(),
        loadingBuilder: (context) => Center(
          child: Text(
            'Loading...',
            style: Theme.of(context).textTheme.displayLarge,
          ),
        ),
        overlayBuilderMap: {
          'menu': (_, game) => Menu(game),
          'gameover': (_, game) => GameOver(game),
        },
        initialActiveOverlays: const ['menu'],
      ),
      theme: _buildTheme(),
    );
  }
}

ThemeData _buildTheme() {
  return ThemeData(
    useMaterial3: true,
    textTheme: TextTheme(
      displayLarge: GoogleFonts.vt323(
        fontSize: 35,
        color: Colors.white,
      ),
      labelLarge: GoogleFonts.vt323(
        fontSize: 30,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: GoogleFonts.vt323(
        fontSize: 28,
        color: Colors.grey,
      ),
      bodyMedium: GoogleFonts.vt323(
        fontSize: 18,
        color: Colors.grey,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        minimumSize: const Size(150, 50),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      hoverColor: Colors.red.shade700,
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
      ),
      border: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
      ),
      errorBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: Colors.red.shade700,
        ),
      ),
    ),
  );
}
