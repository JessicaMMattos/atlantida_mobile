import 'package:atlantida_mobile/screens/home_screen.dart';
import 'package:atlantida_mobile/screens/statistics_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';

class NavBar extends StatelessWidget implements PreferredSizeWidget {
  const NavBar({super.key, required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF0077F0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(context, 'assets/icons/estatistica.svg', 'Estatísticas', 0),
          _buildNavItem(context, 'assets/icons/locais.svg', 'Locais', 1),
          _buildNavItem(context, 'assets/icons/inicio.svg', 'Início', 2),
          _buildNavItem(context, 'assets/icons/certificados.svg', 'Certificados', 3),
          _buildNavItem(context, 'assets/icons/perfil.svg', 'Perfil', 4),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, String iconPath, String label, int itemIndex) {
    bool isSelected = index == itemIndex;
    return GestureDetector(
      onTap: () {
        if (itemIndex == 2) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        } else if (itemIndex == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => StatisticsScreen()),
          );
        } else if (itemIndex == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        } else if (itemIndex == 3) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        } else if (itemIndex == 4) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        }
      },
      child: Container(
        color: isSelected ? Color(0xFF0066CC) : Colors.transparent,
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              iconPath,
              color: Colors.white,
              width: 24,
              height: 24,
            ),
            SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                fontWeight: FontWeight.normal,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
