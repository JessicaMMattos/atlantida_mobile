import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:atlantida_mobile/components/lateral_menu.dart';
import 'package:atlantida_mobile/components/navigation_bar.dart';
import 'package:atlantida_mobile/models/certificate_return.dart';
import 'package:atlantida_mobile/screens/details_certificate.dart';
import 'package:atlantida_mobile/screens/register_certificate.dart';
import 'package:atlantida_mobile/controllers/certificate_controller.dart';

class CertificatesScreen extends StatefulWidget {
  const CertificatesScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CertificatesScreenState createState() => _CertificatesScreenState();
}

class _CertificatesScreenState extends State<CertificatesScreen> {
  final CertificateController _certificateController = CertificateController();
  List<CertificateReturn>? _certificates;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCertificates();
  }

  Future<void> _fetchCertificates() async {
    try {
      // Buscar todos os certificados
      List<CertificateReturn> certificates =
          await _certificateController.getCertificatesByToken();

      // Buscar certificados vencidos
      List<CertificateReturn> expiredCertificates =
          await _certificateController.getExpiredCertificates();

      // Verifica quais certificados na lista original estão vencidos e marca-os
      for (var cert in certificates) {
        if (expiredCertificates
            .any((expiredCert) => expiredCert.id == cert.id)) {
          cert.isExpired = true;
        }
      }

      setState(() {
        _certificates = certificates;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      // Lida com o erro de forma apropriada, exibe mensagem, etc.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const LateralMenu(),
      drawer: const LateralMenuDrawer(),
      bottomNavigationBar: const NavBar(index: 3),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                const Text(
                  'Certificados',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Color(0xFF263238),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Registre e visualize seus certificados de forma prática e organizada.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    color: Color(0xFF263238),
                  ),
                ),
                const SizedBox(height: 25),
                const SizedBox(
                  width: double.infinity,
                  child: Text(
                    'Seus certificados',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF263238),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.blue,
                          ),
                        )
                      : _certificates == null || _certificates!.isEmpty
                          ? const Center(
                              child: Text('Nenhum certificado encontrado.'))
                          : ListView.builder(
                              itemCount: _certificates!.length,
                              itemBuilder: (context, index) {
                                CertificateReturn certificate =
                                    _certificates![index];
                                return _buildCertificateTile(
                                    certificate, constraints.maxWidth);
                              },
                            ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF007FFF),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CertificateRegistrationScreen(),
            ),
          );
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildCertificateTile(
      CertificateReturn certificate, double screenWidth) {
    bool isWideScreen = screenWidth > 600;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 5.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(
          color: certificate.isExpired ? Colors.red : Colors.grey.shade400,
        ),
      ),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 150.0,
            width: double.infinity,
            color: Colors.white,
            child: certificate.certificateImage != null
                ? Image.memory(
                    base64Decode(certificate.certificateImage!.data),
                    fit: BoxFit.contain,
                  )
                : const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      size: 48.0,
                      color: Colors.grey,
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/certificados.svg',
                      height: 30.0,
                      width: 20.0,
                      color: const Color(0xFF007FFF),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        certificate.certificateName,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.bold,
                          fontSize: isWideScreen ? 20.0 : 18.0,
                          color: const Color(0xFF263238),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: SvgPicture.asset(
                        'assets/icons/view-certificate.svg',
                        height: 24.0,
                        width: 24.0,
                        color: const Color(0xFF007FFF),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CertificateDetailsScreen(
                                certificate: certificate),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Wrap(
                  children: [
                    const Text(
                      'Certificadora: ',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.normal,
                        fontSize: 14.0,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      certificate.accreditor,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                Wrap(
                  children: [
                    const Text(
                      'Número de Certificação: ',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.normal,
                        fontSize: 14.0,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      certificate.certificationNumber,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                if (certificate.isExpired)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Vencido',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                        fontSize: isWideScreen ? 18.0 : 16.0,
                        color: Colors.red,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
