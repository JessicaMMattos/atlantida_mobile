import 'package:flutter/material.dart';

class SenhaTextField extends StatefulWidget {
  final String label;
  final String description;
  final TextEditingController controller;
  final String errorMessage;

  const SenhaTextField({
    super.key,
    required this.label,
    required this.description,
    required this.controller,
    required this.errorMessage,
  });

  @override
  // ignore: library_private_types_in_public_api
  _SenhaTextFieldState createState() => _SenhaTextFieldState();
}

class _SenhaTextFieldState extends State<SenhaTextField> {
  bool _obscureText = true;

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Color(0xFF263238),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: widget.controller,
          obscureText: _obscureText,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: widget.errorMessage.isNotEmpty ? Colors.red : Colors.grey,
              ),
            ),
            hintText: widget.description,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: widget.errorMessage.isNotEmpty ? Colors.red : Colors.grey,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: widget.errorMessage.isNotEmpty ? Colors.red : const Color(0xFF263238),
              ),
            ),
            suffixIcon: IconButton(
              onPressed: _toggleObscureText,
              icon: Icon(
                _obscureText ? Icons.visibility_off : Icons.visibility,
              ),
            ),
          ),
        ),
        if (widget.errorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: Text(
              widget.errorMessage,
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
