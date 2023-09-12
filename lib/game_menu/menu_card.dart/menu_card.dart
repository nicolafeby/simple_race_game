import 'package:flutter/material.dart';
import 'package:simple_race_game/core/game_collor/game_color.dart';

class MenuCard extends StatelessWidget {
  const MenuCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black,
      shadowColor: GameColors.green.color,
      elevation: 10,
      margin: const EdgeInsets.only(bottom: 20),
      child: Container(
        margin: const EdgeInsets.all(20),
        child: Column(
          children: children,
        ),
      ),
    );
  }
}