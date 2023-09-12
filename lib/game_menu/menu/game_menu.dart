import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide Image, Gradient;
import 'package:simple_race_game/core/game_collor/game_color.dart';
import 'package:simple_race_game/game_menu/menu_card.dart/menu_card.dart';
import 'package:simple_race_game/racing_game/racing_game.dart';
import 'package:universal_html/html.dart' as html;

class Menu extends StatelessWidget {
  const Menu(this.game, {super.key});

  final PadRacingGame game;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Wrap(
          children: [
            Column(
              children: [
                MenuCard(
                  children: [
                    Text(
                      'PadRacing',
                      style: textTheme.displayLarge,
                    ),
                    Text(
                      'First to 3 laps win',
                      style: textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      child: const Text('1 Player'),
                      onPressed: () {
                        game.prepareStart(numberOfPlayers: 1);
                      },
                    ),
                    Text(
                      'Arrow keys',
                      style: textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      child: const Text('2 Players'),
                      onPressed: () {
                        game.prepareStart(numberOfPlayers: 2);
                      },
                    ),
                    Text(
                      'ASDW',
                      style: textTheme.bodyMedium,
                    ),
                  ],
                ),
                MenuCard(
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Made by ',
                            style: textTheme.bodyMedium,
                          ),
                          TextSpan(
                            text: 'Nicola Feby',
                            style: textTheme.bodyMedium
                                ?.copyWith(color: GameColors.green.color),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                //ignore: unsafe_html
                                html.window.open(
                                  'https://github.com/nicolafeby',
                                  '_blank',
                                );
                              },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Checkout the ',
                            style: textTheme.bodyMedium,
                          ),
                          TextSpan(
                            text: 'repository',
                            style: textTheme.bodyMedium
                                ?.copyWith(color: GameColors.green.color),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                //ignore: unsafe_html
                                html.window.open(
                                  'https://github.com/nicolafeby/simple_race_game',
                                  '_blank',
                                );
                              },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
