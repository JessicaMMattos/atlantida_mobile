import 'package:flutter/material.dart';

class CustomAlertDialog extends StatelessWidget {
  const CustomAlertDialog({
    super.key,
    required this.text,
    required this.onPressed,
  });

  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      title: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF007FFF), size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.normal,
                color: Colors.black,
                fontSize: 18,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      actions: <Widget>[
        TextButton(
          onPressed: onPressed,
          child: const Text(
            'OK',
            style: TextStyle(color: Color(0xFF007FFF)),
          ),
        ),
      ],
      contentPadding: EdgeInsets.zero,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}

class CustomAlertWithDescriptionDialog extends StatelessWidget {
  const CustomAlertWithDescriptionDialog({
    super.key,
    required this.title,
    required this.description,
    required this.onPressed,
  });

  final String title;
  final String description;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF007FFF)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.normal,
                color: Colors.black,
                fontSize: 18,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Text(
          description,
          style: const TextStyle(
            color: Color(0xFF263238),
            fontSize: 16,
          ),
          textAlign: TextAlign.left,
        ),
      ),
      actionsPadding: const EdgeInsets.only(right: 20, bottom: 10),
      actions: <Widget>[
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: onPressed,
            child: const Text(
              'OK',
              style: TextStyle(color: Color(0xFF007FFF)),
            ),
          ),
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      contentPadding: const EdgeInsets.all(20),
      insetPadding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.1,
      ),
    );
  }
}
