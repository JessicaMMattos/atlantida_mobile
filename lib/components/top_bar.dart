import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onPressed;
  final bool haveReturn;

  const TopBar({Key? key, required this.haveReturn, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      height: 50.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          haveReturn
              ? IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Color(0xFF007FFF),
                  ),
                  onPressed: onPressed,
                )
              : const SizedBox(width: 48),
          Center(
            child: SvgPicture.asset(
              'assets/icons/logo.svg',
              height: 20,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(50.0);
}
