import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF007FFF),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Sobre nós',
          style: TextStyle(
            color: Color(0xFF007FFF),
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: const [
          SizedBox(width: 48),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double screenWidth = constraints.maxWidth;

          int crossAxisCount = 2;
          double crossAxisSpacing = screenWidth * 0.05;

          if (screenWidth >= 1200) {
            crossAxisCount = 4;
            crossAxisSpacing = screenWidth * 0.04;
          } else if (screenWidth >= 800) {
            crossAxisCount = 3;
            crossAxisSpacing = screenWidth * 0.05;
          } else if (screenWidth >= 475) {
            crossAxisCount = 2;
            crossAxisSpacing = screenWidth * 0.05;
          } else {
            crossAxisCount = 1;
            crossAxisSpacing = screenWidth * 0.05;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/icons/logo.svg',
                  height: 35,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 18.0),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.black),
                    backgroundColor: Colors.transparent,
                  ),
                  child: const Text(
                    'Versão 1.1.0-beta',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                const Text(
                  'No Atlântida Mergulhos, nosso objetivo é simplificar o gerenciamento dos seus mergulhos. '
                  'Oferecemos ferramentas para organizar seus registros, manter seus certificados atualizados '
                  'e acompanhar sua evolução com estatísticas detalhadas, ajudando você a mergulhar com confiança e organização.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.normal,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 25.0),
                const Text(
                  'Nossa Equipe',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Color(0xFF263238),
                  ),
                ),
                const SizedBox(height: 16.0),
                GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: crossAxisSpacing,
                    mainAxisSpacing: 16.0,
                    mainAxisExtent: 230,
                  ),
                  itemCount: 4,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final members = [
                      {
                        'name': 'Jéssica Mattos',
                        'role': 'Desenvolvedora Full Stack',
                        'imagePath': 'assets/images/jessica-picture.png',
                        'linkedInUrl':
                            'https://www.linkedin.com/in/j%C3%A9ssicammattos/',
                      },
                      {
                        'name': 'Ícaro Vieira',
                        'role': 'UI/UX Designer',
                        'imagePath': 'assets/images/icaro-picture.png',
                        'linkedInUrl':
                            'https://www.linkedin.com/in/icaro-vieira1202/',
                      },
                      {
                        'name': 'Diego Negretto',
                        'role': 'Orientador',
                        'imagePath': 'assets/images/diego-picture.png',
                        'linkedInUrl':
                            'https://www.linkedin.com/in/diego-negretto-8653a7a2/',
                      },
                      {
                        'name': 'Camilo Perucci',
                        'role': 'Coorientador',
                        'imagePath': 'assets/images/camilo-picture.png',
                        'linkedInUrl':
                            'https://www.linkedin.com/in/camilo-perucci-98a14422/',
                      },
                    ];

                    final member = members[index];
                    return SizedBox(
                      height: 250, // Altura máxima do card fixa
                      child: _buildTeamMemberCard(
                        member['name']!,
                        member['role']!,
                        member['imagePath']!,
                        member['linkedInUrl']!,
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTeamMemberCard(
      String name, String role, String imagePath, String linkedInUrl) {
    return Card(
      color: Colors.white,
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.asset(
                imagePath,
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              role,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 14.0,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await _launchUrl(linkedInUrl);
                },
                icon: const Icon(Icons.link, color: Color(0xFF007FFF)),
                label: const Text(
                  'LinkedIn',
                  style: TextStyle(
                    color: Color(0xFF007FFF),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.normal,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFF007FFF)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw 'Could not launch $url';
    }
  }
}
