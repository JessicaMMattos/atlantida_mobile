import 'package:atlantida_mobile/screens/control.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';

class LateralMenu extends StatelessWidget implements PreferredSizeWidget {
  final bool isReturn;
  final VoidCallback? onPressed;

  const LateralMenu({super.key, this.isReturn = false, this.onPressed});

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
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) {
            return Row(
              children: [
                if (isReturn)
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF007FFF),
                    ),
                    onPressed: onPressed ?? () => Navigator.of(context).pop(),
                  )
              ],
            );
          },
        ),
        title: GestureDetector(
          onTap: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => const MainNavigationScreen()),
              (Route<dynamic> route) => false,
            );
          },
          child: SvgPicture.asset(
            'assets/icons/logo.svg',
            height: 24,
            fit: BoxFit.contain,
          ),
        ),
        centerTitle: true,
        actions: const [
          SizedBox(width: 48),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(50.0);
}
