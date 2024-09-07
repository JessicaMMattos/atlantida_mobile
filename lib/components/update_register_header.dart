import 'package:flutter/material.dart';

class UpdateOrRegisterHeader extends StatelessWidget {
  final bool hasUpdate;

  const UpdateOrRegisterHeader({
    super.key,
    required this.hasUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Text(
          hasUpdate ? 'Editar Mergulho' : 'Registro de Mergulho',
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Color(0xFF263238),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          hasUpdate
              ? 'Edite as informações abaixo de seu registro de mergulho.'
              : 'Complete as informações abaixo para registrar seu mergulho.',
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
            fontSize: 16,
            color: Color(0xFF263238),
          ),
        ),
        const SizedBox(height: 25),
      ],
    );
  }
}
