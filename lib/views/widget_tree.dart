import 'package:flutter/material.dart';
import 'package:twilight_foodz_customer/data/notifiers.dart';
import 'package:twilight_foodz_customer/views/pages/home.dart';
import 'package:twilight_foodz_customer/views/pages/profile.dart';
import 'package:twilight_foodz_customer/views/widgets/navigation.dart';
import 'package:twilight_foodz_customer/views/widgets/theme.dart';

List<Widget> pages = [Home(), Profile()];

class WidgetTree extends StatelessWidget {
  const WidgetTree({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Weather"),
        actions: [ThemeButton()],
        actionsPadding: EdgeInsets.only(right: 20),
        centerTitle: true,
      ),
      drawer: Drawer(),
      body: ValueListenableBuilder(
        valueListenable: selectedPageNotifier,
        builder: (context, selectedPage, child) {
          return pages.elementAt(selectedPage);
        },
      ),
      bottomNavigationBar: Navigation(),
    );
  }
}
