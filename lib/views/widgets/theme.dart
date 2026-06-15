import 'package:flutter/material.dart';
import 'package:twilight_foodz_customer/data/notifiers.dart';

const List<Widget> icons = [Icon(Icons.light_mode), Icon(Icons.dark_mode)];

class ThemeButton extends StatelessWidget {
  const ThemeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDarkMode, child) {
        return IconButton(
          onPressed: () {
            isDarkModeNotifier.value = !isDarkModeNotifier.value;
          },
          icon: icons.elementAt(isDarkMode ? 0 : 1),
        );
      },
    );
  }
}
