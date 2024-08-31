import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:atlantida_mobile/models/certificate.dart';
import 'package:atlantida_mobile/models/certificate_return.dart';
import 'package:atlantida_mobile/screens/certificate_screen.dart';
import 'package:atlantida_mobile/screens/register_certificate.dart';
import 'package:atlantida_mobile/controllers/certificate_controller.dart';

class CertificateDetailsScreen extends StatefulWidget {
  final CertificateReturn certificate;

  const CertificateDetailsScreen({super.key, required this.certificate});

  @override
  // ignore: library_private_types_in_public_api
  _CertificateDetailsScreenStateState createState() =>
      _CertificateDetailsScreenStateState();
}

class _CertificateDetailsScreenStateState
    extends State<CertificateDetailsScreen> {
  late CertificateReturn certificate;

  @override
  void initState() {
    super.initState();
    certificate = widget.certificate;
  }

  String _formatDate(String dateUtc) {
    final utcDate = DateTime.parse(dateUtc);
    final localDate = utcDate.toLocal();
    return DateFormat('dd/MM/yyyy').format(localDate);
  }

  Widget _buildImage(CertificateImage photo) {
    final imageData = photo.data;

    if (imageData.isEmpty) {
      return Container(
        width: 200,
        height: 200,
        color: Colors.grey,
        child: const Icon(Icons.error, color: Colors.red),
      );
    }

    try {
      final decodedImage = base64Decode(imageData);
      return Image.memory(
        decodedImage,
        fit: BoxFit.cover,
        width: 200,
        height: 200,
      );
    } catch (e) {
      return Container(
        width: 200,
        height: 200,
        color: Colors.grey,
        child: const Icon(Icons.error, color: Colors.red),
      );
    }
  }

  void _deleteCertificate() async {
    try {
      bool? shouldUpdate = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            contentPadding: const EdgeInsets.all(20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            content: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8,
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Excluir certificado',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF263238),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tem certeza de que deseja excluir permanentemente este certificado?',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: Color(0xFF263238),
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text(
                  'CANCELAR',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF007FFF),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              TextButton(
                child: const Text(
                  'EXCLUIR',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.red,
                  ),
                ),
                onPressed: () async {
                  try {
                    await CertificateController()
                        .deleteCertificate(certificate.id);
                    // ignore: duplicate_ignore
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Certificado excluído com sucesso.'),
                      ),
                    );
                    Navigator.pushReplacement(
                      // ignore: use_build_context_synchronously
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CertificatesScreen()),
                    );
                  } catch (err) {
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Erro ao deletar Certificado.'),
                      ),
                    );
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop(false);
                  }
                },
              ),
            ],
          );
        },
      );

      if (shouldUpdate == true) {
        setState(() {});
      }
    } catch (err) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao exibir diálogo de exclusão.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

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
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const CertificatesScreen(),
              ),
            );
          },
        ),
        title: Text(
          certificate.certificateName,
          style: const TextStyle(
            color: Color(0xFF007FFF),
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (certificate.certificateImage != null)
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullScreenImageView(
                              photo: certificate.certificateImage!),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: _buildImage(certificate.certificateImage!),
                      ),
                    ),
                  ),
                ),
              _buildDetailRowWithIcon(
                  label: "Nome do certificado",
                  value: _capitalize(certificate.certificateName)),
              _buildDetailRowWithIcon(
                  label: "Credenciadora",
                  value: _capitalize(certificate.accreditor)),
              _buildDetailRowWithIcon(
                  label: "Número de certificação",
                  value: certificate.certificationNumber),
              if (certificate.certificationLevel != null)
                _buildDetailRowWithIcon(
                    label: "Nível de certificação",
                    value: certificate.certificationLevel!),
              if (certificate.issuanceDate != null)
                _buildDetailRowWithIcon(
                    label: "Data de emissão",
                    value: _formatDate(certificate.issuanceDate!)),
              if (certificate.expirationDate != null)
                _buildDetailRowWithIcon(
                    label: "Data de validade",
                    value: _formatDate(certificate.expirationDate!)),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: screenWidth * 0.4,
                    child: ElevatedButton(
                      onPressed: () {
                        _deleteCertificate();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(
                            vertical: 22, horizontal: 30),
                        textStyle: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      child: const Text(
                        'DELETAR',
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: screenWidth * 0.4,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CertificateRegistrationScreen(
                              certificate: certificate,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007FFF),
                        padding: const EdgeInsets.symmetric(
                            vertical: 22, horizontal: 30),
                        textStyle: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      child: const Text(
                        'EDITAR',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRowWithIcon(
      {required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.normal,
              color: Colors.black54,
              fontSize: 16,
              fontFamily: 'Inter',
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.normal,
              color: Colors.black,
              fontSize: 16,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  String _capitalize(String text) {
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}

class FullScreenImageView extends StatelessWidget {
  final CertificateImage photo;

  const FullScreenImageView({super.key, required this.photo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: InteractiveViewer(
          child: Image.memory(base64Decode(photo.data)),
        ),
      ),
    );
  }
}
