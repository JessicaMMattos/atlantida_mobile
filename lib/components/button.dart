import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  const Button({super.key, required this.titleButton, required this.onPressed});

  final String titleButton;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final double buttonWidth = MediaQuery.of(context).size.width * 0.7;

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        fixedSize: Size(buttonWidth, 50),
        backgroundColor: Color(0xFF007FFF)
      ),
      child: Text(
        titleButton,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 15.0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
