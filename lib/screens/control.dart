import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:atlantida_mobile/models/diving_spot_return.dart';
import 'package:atlantida_mobile/screens/certificate_screen.dart';
import 'package:atlantida_mobile/screens/dive_sites.dart';
import 'package:atlantida_mobile/screens/home.dart';
import 'package:atlantida_mobile/screens/profile.dart';
import 'package:atlantida_mobile/screens/statistics.dart';

class MainNavigationScreen extends StatefulWidget {
  final int index;
  final DivingSpotReturn? diveSpot;

  const MainNavigationScreen({super.key, this.index = 2, this.diveSpot});

  @override
  // ignore: library_private_types_in_public_api
  _MainNavigationScreenState createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _selectedIndex;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.index;

    _pages = [
      const StatisticsScreen(),
      if (widget.diveSpot == null)
        const MapScreen()
      else
        MapScreen(diveSpot: widget.diveSpot),
      const HomeScreen(),
      const CertificatesScreen(),
      const ProfileScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (int selectedIndex) {
          if (selectedIndex == 1) {

            if(widget.diveSpot == null){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MapScreen()),
              );
            }
            else{
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MapScreen(diveSpot: widget.diveSpot)),
              );
            }
          } else {
            _onItemTapped(selectedIndex);
          }
        },
        backgroundColor: const Color(0xFF0077F0),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white60,
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/estatistica.svg',
              color: _selectedIndex == 0 ? Colors.white : Colors.white60,
            ),
            label: 'Gráficos',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/locais.svg',
              color: _selectedIndex == 1 ? Colors.white : Colors.white60,
            ),
            label: 'Locais',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/inicio.svg',
              color: _selectedIndex == 2 ? Colors.white : Colors.white60,
            ),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/certificados.svg',
              color: _selectedIndex == 3 ? Colors.white : Colors.white60,
            ),
            label: 'Certificados',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/perfil.svg',
              color: _selectedIndex == 4 ? Colors.white : Colors.white60,
            ),
            label: 'Perfil',
          ),
        ],
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        iconSize: 24,
      ),
    );
  }
}
