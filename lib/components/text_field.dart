import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String description;
  final TextEditingController controller;
  final String errorMessage;
  final bool isRequired;

  const CustomTextField({
    Key? key,
    required this.label,
    required this.description,
    required this.controller,
    this.errorMessage = '',
    this.isRequired = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Color(0xFF263238),
          ),
        ),
        SizedBox(height: 10),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: isRequired && errorMessage.isNotEmpty
                    ? Colors.red
                    : Colors.grey,
              ),
            ),
            hintText: description,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: isRequired && errorMessage.isNotEmpty
                    ? Colors.red
                    : Colors.grey,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: isRequired && errorMessage.isNotEmpty
                    ? Colors.red
                    : Color(0xFF263238),
              ),
            ),
          ),
        ),
        if (isRequired && errorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: Text(
              errorMessage,
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}

class Title1 extends StatelessWidget {
  final String title;

  const Title1({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.bold,
        fontSize: 14,
        color: Color(0xFF263238),
      ),
    );
  }
}

class Title2 extends StatelessWidget {
  final String title;

  const Title2({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.normal,
        fontSize: 14,
        color: Color(0xFF263238),
      ),
    );
  }
}