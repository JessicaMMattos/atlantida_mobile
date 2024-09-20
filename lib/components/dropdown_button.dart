import 'package:flutter/material.dart';

class CustomDropdownField extends StatelessWidget {
  final List<String> list;
  final String? selected;
  final String hintString;
  final ValueChanged<String?> onChanged;

  const CustomDropdownField({
    super.key,
    required this.list,
    required this.selected,
    required this.hintString,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: list.contains(selected) ? selected : null,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.grey,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.grey,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Color(0xFF263238),
          ),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      icon: const Icon(
        Icons.arrow_drop_down,
        color: Colors.grey,
      ),
      elevation: 16,
      style: const TextStyle(color: Colors.black),
      onChanged: onChanged,
      hint: Text(
        hintString,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      items: list.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      dropdownColor: Colors.white,
      isExpanded: true,
    );
  }
}