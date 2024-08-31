import 'package:atlantida_mobile/screens/certificate_screen.dart';
import 'package:atlantida_mobile/screens/dive_sites.dart';
import 'package:atlantida_mobile/screens/home.dart';
import 'package:atlantida_mobile/screens/profile.dart';
import 'package:atlantida_mobile/screens/statistics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NavBar extends StatelessWidget {
  const NavBar({super.key, required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: index,
      onTap: (int selectedIndex) {
        if (selectedIndex == 2) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else if (selectedIndex == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const StatisticsScreen()),
          );
        } else if (selectedIndex == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MapScreen()),
          );
        } else if (selectedIndex == 3) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const CertificatesScreen()),
          );
        } else if (selectedIndex == 4) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
        }
      },
      backgroundColor: const Color(0xFF0077F0),
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white60,
      items: [
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/icons/estatistica.svg',
            color: index == 0 ? Colors.white : Colors.white60,
          ),
          label: 'Gráficos',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/icons/locais.svg',
            color: index == 1 ? Colors.white : Colors.white60,
          ),
          label: 'Locais',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/icons/inicio.svg',
            color: index == 2 ? Colors.white : Colors.white60,
          ),
          label: 'Início',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/icons/certificados.svg',
            color: index == 3 ? Colors.white : Colors.white60,
          ),
          label: 'Certificados',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/icons/perfil.svg',
            color: index == 4 ? Colors.white : Colors.white60,
          ),
          label: 'Perfil',
        ),
      ],
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: const TextStyle(fontSize: 12),
      unselectedLabelStyle: const TextStyle(fontSize: 12),
      iconSize: 24,
    );
  }
}
