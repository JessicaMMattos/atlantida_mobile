import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:atlantida_mobile/components/button.dart';
import 'package:atlantida_mobile/screens/login_screen.dart';

class FirstScreen extends StatefulWidget {
  const FirstScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FirstScreenState createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  int _currentPage = 0;
  final List<String> _phrases = [
    'Memórias visualmente incríveis!\nAdicione fotos nos registros de\nmergulho.',
    'Explore águas extraordinárias\ncom confiança e reviva cada\nmomento subaquático.',
    'Guia subaquático pessoal!\nDescubra, registre, compartilhe\ne acompanhe sua evolução!',
  ];
  final List<String> _images = [
    'assets/images/image1.jpg',
    'assets/images/image2.jpg',
    'assets/images/image3.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CarouselSlider.builder(
            itemCount: _images.length,
            itemBuilder: (context, index, realIndex) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(_images[index]),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        _phrases[index],
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 120.0), // Espaçamento entre texto e bolinhas
                  ],
                ),
              );
            },
            options: CarouselOptions(
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 10),
              onPageChanged: (index, reason) {
                setState(() {
                  _currentPage = index;
                });
              },
              viewportFraction: 1.0,
              enlargeCenterPage: false,
              height: MediaQuery.of(context).size.height,
            ),
          ),

          // Bolinhas de paginação
          Positioned(
            bottom: 90, // Ajustado para garantir o mesmo espaçamento
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _images.asMap().entries.map((entry) {
                return Indicator(
                  isActive: entry.key == _currentPage,
                  color: Colors.white,
                );
              }).toList(),
            ),
          ),

          // Botão "Fazer Login"
          Positioned(
            bottom: 20.0,
            left: 20.0,
            right: 20.0,
            child: Button(
              titleButton: 'FAZER LOGIN',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Indicator extends StatelessWidget {
  final bool isActive;
  final Color color;

  const Indicator({super.key, required this.isActive, required this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isActive ? 12 : 8,
      height: isActive ? 12 : 8,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isActive ? color : Colors.grey,
        borderRadius: BorderRadius.circular(50),
      ),
    );
  }
}
