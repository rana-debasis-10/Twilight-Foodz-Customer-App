import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class Home extends StatefulWidget {
  final String jwt;

  const Home({super.key, required this.jwt});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? customerName;

  @override
  void initState() {
    Map<String, dynamic> jwt = JwtDecoder.decode(widget.jwt);
    customerName = jwt["sub"];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("The  Cusotmer name is : $customerName"),
            Text(
              "This is The Home Page",
              style: TextStyle(
                color: Colors.red,
                fontSize: 40,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
