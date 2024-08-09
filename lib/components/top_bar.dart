import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onPressed;
  final bool haveReturn;

  const TopBar({super.key, required this.haveReturn, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: haveReturn
          ? IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Color(0xFF007FFF),
              ),
              onPressed: onPressed,
            )
          : null,
      title: SvgPicture.asset(
        'assets/icons/logo.svg',
        height: 24,
        fit: BoxFit.contain,
      ),
      centerTitle: true,
      actions: const [
        SizedBox(width: 48),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(50.0);
}
