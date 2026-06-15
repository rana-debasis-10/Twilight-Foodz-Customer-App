import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController controller = TextEditingController();
  bool? isChecked = false;
  bool isOn = true;
  double sliderValue = 0.0;
  int? selectedInt = 15;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: controller,
                decoration: InputDecoration(border: OutlineInputBorder()),
                onEditingComplete: () {
                  setState(() {});
                },
              ),
            ),
            Text(controller.text),
            Checkbox.adaptive(
              shape: CircleBorder(eccentricity: 0.5),
              value: isChecked,
              onChanged: (value) {
                setState(() {
                  isChecked = value;
                });
              },
            ),
            SwitchListTile.adaptive(
              title: Text("This Is a Switch"),
              value: isOn,
              onChanged: (value) => setState(() {
                isOn = value;
              }),
            ),
            Slider.adaptive(
              value: sliderValue,
              onChanged: (value) => setState(() {
                sliderValue = value;
              }),
              max: 100,
              min: 0,
              divisions: 4,
            ),
            Image.asset("assets/download.jpeg"),
            SizedBox(height: 10, width: 10),
            Image.asset("assets/download.jpeg"),
            SizedBox(height: 10, width: 10),

            Image.asset("assets/download.jpeg"),
            SizedBox(height: 10, width: 10),

            Image.asset("assets/download.jpeg"),
            SizedBox(height: 10, width: 10),

            Image.asset("assets/download.jpeg"),
            SizedBox(height: 10, width: 10),

            ElevatedButton(onPressed: () => {}, child: Text("CLick Me")),
            FilledButton(onPressed: () => {}, child: Text("CLick Me")),
            OutlinedButton(onPressed: () => {}, child: Text("CLick Me")),
            TextButton(onPressed: () => {}, child: Text("CLick Me")),
            CloseButton(),
            BackButton(),
            DropdownButton(
              items: [
                DropdownMenuItem(
                  value: 10,
                  child: Text("This is Element no 1"),
                ),
                DropdownMenuItem(
                  value: 11,
                  child: Text("This is Element no 2"),
                ),
                DropdownMenuItem(
                  value: 13,
                  child: Text("This is Element no 3"),
                ),
                DropdownMenuItem(
                  value: 14,
                  child: Text("This is Element no 4"),
                ),
                DropdownMenuItem(
                  value: 15,
                  child: Text("This is Element no 5"),
                ),
                DropdownMenuItem(
                  value: 16,
                  child: Text("This is Element no 6"),
                ),
              ],
              value: selectedInt,
              onChanged: (value) {
                setState(() {
                  selectedInt = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
