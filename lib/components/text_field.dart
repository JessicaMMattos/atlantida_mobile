import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String description;
  final TextEditingController controller;
  final String errorMessage;
  final bool isRequired;
  final bool haveCapitalization;

  const CustomTextField({
    super.key,
    required this.label,
    required this.description,
    required this.controller,
    this.errorMessage = '',
    this.isRequired = false,
    this.haveCapitalization = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Color(0xFF263238),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          textCapitalization: haveCapitalization
              ? TextCapitalization.sentences
              : TextCapitalization.none,
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
                    : const Color(0xFF263238),
              ),
            ),
          ),
        ),
        if (isRequired && errorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: Text(
              errorMessage,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}

class CustomTextFieldOptional extends StatelessWidget {
  final String label;
  final String description;
  final TextEditingController controller;
  final String errorMessage;
  final bool isRequired;

  const CustomTextFieldOptional({
    super.key,
    required this.label,
    required this.description,
    required this.controller,
    this.errorMessage = '',
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Title1(title: label),
            const Text(
              ' (Opcional)',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
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
                    : const Color(0xFF263238),
              ),
            ),
          ),
        ),
        if (isRequired && errorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: Text(
              errorMessage,
              style: const TextStyle(
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
    super.key,
    required this.title,
  });

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
    super.key,
    required this.title,
  });

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

MaskTextInputFormatter createDateMaskFormatter() {
  return MaskTextInputFormatter(
    mask: '##/##/####',
    filter: {'#': RegExp(r'[0-9]')},
  );
}
