import 'package:flutter/material.dart';

void main() async {
  runApp(const AtlantidaApp());
}

class AtlantidaApp extends StatelessWidget {
  const AtlantidaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Hello World!'),
        ),
      ),
    );
  }
}
