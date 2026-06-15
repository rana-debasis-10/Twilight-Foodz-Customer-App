import 'package:flutter/material.dart';
import 'package:twilight_foodz_customer/data/notifiers.dart';

class Navigation extends StatelessWidget {
  const Navigation({super.key});

  @override
  Widget build(BuildContext context) {

    return ValueListenableBuilder(
      valueListenable: selectedPageNotifier,
      builder: (context, selectedPage, child) {
        return NavigationBar(
          destinations: [
            NavigationDestination(icon: Icon(Icons.home), label: "Home"),
            NavigationDestination(
              icon: Icon(Icons.local_activity),
              label: "Location",
            ),
          ],
          onDestinationSelected: (pageSelected) {
            selectedPageNotifier.value = pageSelected;
            
          },
          selectedIndex: selectedPage,
        
        );
      },
    );
  }
}
