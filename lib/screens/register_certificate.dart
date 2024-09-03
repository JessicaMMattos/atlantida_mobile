import 'dart:convert';
import 'package:atlantida_mobile/components/custom_alert_dialog.dart';
import 'package:atlantida_mobile/components/text_field.dart';
import 'package:atlantida_mobile/controllers/certificate_controller.dart';
import 'package:atlantida_mobile/models/certificate.dart';
import 'package:atlantida_mobile/models/certificate_return.dart';
import 'package:atlantida_mobile/screens/details_certificate.dart';
import 'package:atlantida_mobile/screens/certificate_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CertificateRegistrationScreen extends StatefulWidget {
  final CertificateReturn? certificate;

  const CertificateRegistrationScreen({super.key, this.certificate});

  @override
  // ignore: library_private_types_in_public_api
  _CertificateRegistrationScreenState createState() =>
      _CertificateRegistrationScreenState();
}

class _CertificateRegistrationScreenState
    extends State<CertificateRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  Uint8List? _imageData;
  String? _imageContentType;

  final _certificateNameController = TextEditingController();
  final _accreditorController = TextEditingController();
  final _certificationNumberController = TextEditingController();
  final _certificationLevelController = TextEditingController();
  final _issueDateController = TextEditingController();
  final _expirationDateController = TextEditingController();

  String _nameErrorMessage = '';
  String _accreditorErrorMessage = '';
  String _certificationNumberErrorMessage = '';
  String _issueDateErrorMessage = '';
  String _expirationDateErrorMessage = '';
  String _date = '';

  bool _isProcessing = false;

  // ignore: prefer_typing_uninitialized_variables
  var newCertificate;
  var hasUpdate = false;
  // ignore: prefer_typing_uninitialized_variables
  var updateCertificate;

  @override
  void initState() {
    super.initState();
    _resetForm();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.certificate != null) {
      final cert = widget.certificate!;
      updateCertificate = cert;
      hasUpdate = true;

      _certificateNameController.text = cert.certificateName;
      _accreditorController.text = cert.accreditor;
      _certificationNumberController.text = cert.certificationNumber;

      if (cert.certificationLevel != null) {
        _certificationLevelController.text = cert.certificationLevel!;
      }

      if (cert.issuanceDate != null) {
        _issueDateController.text = _formatDate(cert.issuanceDate!);
      }

      if (cert.expirationDate != null) {
        _expirationDateController.text = _formatDate(cert.expirationDate!);
      }

      if (cert.certificateImage != null) {
        final imageData = base64Decode(cert.certificateImage!.data);
        setState(() {
          _imageData = imageData;
          _imageContentType = cert.certificateImage!.contentType;
        });
      }
    }
  }

  String _formatDate(String dateUtc) {
    final utcDate = DateTime.parse(dateUtc);
    final localDate = utcDate.toLocal();
    return DateFormat('dd/MM/yyyy').format(localDate);
  }

  String _formatDateForSaving(String date) {
    try {
      DateFormat inputFormat = DateFormat('dd/MM/yyyy');
      DateFormat outputFormat = DateFormat('yyyy-MM-dd');
      DateTime parsedDate = inputFormat.parseStrict(date);
      return outputFormat.format(parsedDate);
    } catch (e) {
      throw const FormatException('Invalid date format');
    }
  }

  int _daysInMonth(int month, int year) {
    switch (month) {
      case 4:
      case 6:
      case 9:
      case 11:
        return 30;
      case 2:
        if ((year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)) {
          return 29;
        }
        return 28;
      default:
        return 31;
    }
  }

  Map<String, String> _validateDate(String date) {
    final Map<String, String> errors = {};

    try {
      if (date.isNotEmpty) {
        final parts = date.split('/');
        if (parts.length != 3) {
          errors['format'] = 'Data inválida (formato DD/MM/AAAA).';
        } else {
          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final year = int.parse(parts[2]);

          if (month < 1 || month > 12) {
            errors['format'] = 'Data inválida (formato DD/MM/AAAA).';
          } else {
            final daysInMonth = _daysInMonth(month, year);
            if (day < 1 || day > daysInMonth) {
              errors['format'] = 'Data inválida (formato DD/MM/AAAA).';
            } else {
              final currentDate = DateTime.now();
              final date = DateTime(year, month, day);
              if (date.isAfter(currentDate.add(const Duration(days: 1)))) {
                errors['age'] = 'Data inválida.';
              }
              _date = DateFormat('yyyy-MM-dd').format(date);
            }
          }
        }
      }
    } catch (e) {
      errors['format'] = 'Data de nascimento inválida (formato DD/MM/AAAA).';
    }

    return errors;
  }

  Map<String, String> _expirationDateValidateDate(String date) {
    final Map<String, String> errors = {};

    try {
      if (date.isNotEmpty) {
        final parts = date.split('/');
        if (parts.length != 3) {
          errors['format'] = 'Data inválida (formato DD/MM/AAAA).';
        } else {
          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final year = int.parse(parts[2]);

          if (month < 1 || month > 12) {
            errors['format'] = 'Data inválida (formato DD/MM/AAAA).';
          } else {
            final daysInMonth = _daysInMonth(month, year);
            if (day < 1 || day > daysInMonth) {
              errors['format'] = 'Data inválida (formato DD/MM/AAAA).';
            } else {
              final currentDate = DateTime.now();
              final date = DateTime(year, month, day);
              if (date.isBefore(currentDate)) {
                errors['age'] = 'Certificação vencida.';
              }
              _date = DateFormat('yyyy-MM-dd').format(date);
            }
          }
        }
      }
    } catch (e) {
      errors['format'] = 'Data de nascimento inválida (formato DD/MM/AAAA).';
    }

    return errors;
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final Uint8List imageData = await image.readAsBytes();

      if (imageData != null) {
        setState(() {
          _imageData = imageData;
          _imageContentType = image.mimeType;
        });
      }
    }
  }

  void _resetForm() {
    setState(() {
      _certificateNameController.clear();
      _accreditorController.clear();
      _certificationNumberController.clear();
      _certificationLevelController.clear();
      _issueDateController.clear();
      _expirationDateController.clear();

      _nameErrorMessage = '';
      _accreditorErrorMessage = '';
      _certificationNumberErrorMessage = '';
      _issueDateErrorMessage = '';
      _expirationDateErrorMessage = '';
      _date = '';
      newCertificate = null;

      _imageData = null;

      hasUpdate = false;
    });
  }

  void _cancel() {
    _resetForm();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const CertificatesScreen(),
      ),
    );
  }

  void _nextStep() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      if (_issueDateController.text.isNotEmpty) {
        final issueDateValidation = _validateDate(_issueDateController.text);

        setState(() {
          _issueDateErrorMessage =
              issueDateValidation['format'] ?? issueDateValidation['age'] ?? '';
        });
      }

      if (_expirationDateController.text.isNotEmpty) {
        final expirationDateValidation =
            _expirationDateValidateDate(_expirationDateController.text);

        setState(() {
          _expirationDateErrorMessage = expirationDateValidation['format'] ??
              expirationDateValidation['age'] ??
              '';
        });
      }

      setState(() {
        _nameErrorMessage =
            _certificateNameController.text.isEmpty ? 'Campo obrigatório.' : '';
        _accreditorErrorMessage =
            _accreditorController.text.isEmpty ? 'Campo obrigatório.' : '';
        _certificationNumberErrorMessage =
            _certificationNumberController.text.isEmpty
                ? 'Campo obrigatório.'
                : '';
      });

      if (_nameErrorMessage.isEmpty &&
          _accreditorErrorMessage.isEmpty &&
          _certificationNumberErrorMessage.isEmpty &&
          _expirationDateErrorMessage.isEmpty &&
          _issueDateErrorMessage.isEmpty) {
        newCertificate = Certificate(
            certificateName: _certificateNameController.text,
            accreditor: _accreditorController.text,
            certificationNumber: _certificationNumberController.text);

        if (_certificationLevelController.text.isNotEmpty) {
          newCertificate.certificationLevel =
              _certificationLevelController.text;
        }

        if (_expirationDateController.text.isNotEmpty) {
          newCertificate.expirationDate = _formatDateForSaving(_expirationDateController.text);
        }

        if (_issueDateController.text.isNotEmpty) {
          newCertificate.issuanceDate = _formatDateForSaving(_issueDateController.text);
        }

        if (_imageData != null) {
          final imageData = base64Encode(_imageData!);
          CertificateImage image = CertificateImage(
            data: imageData,
            contentType: _imageContentType ?? 'image/jpeg',
          );
          newCertificate.certificateImage = image;
        }

        if (hasUpdate) {
          var newCert = await CertificateController()
              .updateCertificate(updateCertificate.id, newCertificate);

          showDialog(
            // ignore: use_build_context_synchronously
            context: context,
            builder: (BuildContext context) {
              return CustomAlertDialog(
                text: 'Certificado atualizado com sucesso!',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CertificateDetailsScreen(certificate: newCert),
                    ),
                  );
                },
              );
            },
          );
        } else {
          await CertificateController().createCertificate(newCertificate);

          showDialog(
            // ignore: use_build_context_synchronously
            context: context,
            builder: (BuildContext context) {
              return CustomAlertDialog(
                text: 'Certificado cadastrado com sucesso!',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CertificatesScreen(),
                    ),
                  );
                },
              );
            },
          );
        }

        _resetForm();
      }
    } catch (error) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao cadastrar certificado, tente novamente.'),
        ),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

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
          hasUpdate ? 'Editar Certificado' : 'Adicionar Certificado',
          style: const TextStyle(
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 10),
              Text(
                hasUpdate ? 'Editar Certificado' : 'Adicionar Certificado',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Color(0xFF263238),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                hasUpdate
                    ? 'Altere as informações abaixo de seu certificado'
                    : 'Complete as informações abaixo para registrar um novo certificado',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                  color: Color(0xFF263238),
                ),
              ),
              const SizedBox(height: 25),

              // Campo de Nome
              CustomTextField(
                label: 'Nome do certificado',
                controller: _certificateNameController,
                description: 'Ex. Plongeur diver Buceador',
                isRequired: true,
                errorMessage: _nameErrorMessage,
              ),
              const SizedBox(height: 20),

              // Campo de Credenciadora
              CustomTextField(
                label: 'Credenciadora',
                controller: _accreditorController,
                description: 'Entidade que concedeu o certificado',
                isRequired: true,
                errorMessage: _accreditorErrorMessage,
              ),
              const SizedBox(height: 20),

              // Número de certificação
              CustomTextField(
                label: 'Número de certificação',
                controller: _certificationNumberController,
                description: '',
                isRequired: true,
                errorMessage: _certificationNumberErrorMessage,
              ),
              const SizedBox(height: 20),

              // Campo de Nível de certificação
              CustomTextFieldOptional(
                  label: 'Nível de certificação',
                  controller: _certificationLevelController,
                  description: 'Ex. Beginner'),
              const SizedBox(height: 20),

              // Campo de Data de emissão
              const Row(
                children: [
                  Text(
                    'Data de emissão',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF263238),
                    ),
                  ),
                  Text(
                    ' (Opcional)',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              TextField(
                controller: _issueDateController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  createDateMaskFormatter(),
                  LengthLimitingTextInputFormatter(10),
                ],
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _issueDateErrorMessage.isNotEmpty
                          ? Colors.red
                          : Colors.grey,
                    ),
                  ),
                  hintText: 'dd/mm/aaaa',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _issueDateErrorMessage.isNotEmpty
                          ? Colors.red
                          : Colors.grey,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _issueDateErrorMessage.isNotEmpty
                          ? Colors.red
                          : const Color(0xFF263238),
                    ),
                  ),
                ),
              ),

              if (_issueDateErrorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: Text(
                    _issueDateErrorMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 20),

              // Campo de data de validade
              const Row(
                children: [
                  Text(
                    'Data de validade',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF263238),
                    ),
                  ),
                  Text(
                    ' (Opcional)',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              TextField(
                controller: _expirationDateController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  createDateMaskFormatter(),
                  LengthLimitingTextInputFormatter(10),
                ],
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _expirationDateErrorMessage.isNotEmpty
                          ? Colors.red
                          : Colors.grey,
                    ),
                  ),
                  hintText: 'dd/mm/aaaa',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _expirationDateErrorMessage.isNotEmpty
                          ? Colors.red
                          : Colors.grey,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _expirationDateErrorMessage.isNotEmpty
                          ? Colors.red
                          : const Color(0xFF263238),
                    ),
                  ),
                ),
              ),

              if (_expirationDateErrorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: Text(
                    _expirationDateErrorMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 20),

              // Campo para adicionar imagem
              const Row(
                children: [
                  Title1(
                    title: 'Imagem do certificado',
                  ),
                  Text(
                    ' (Opcional)',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 2),
              Title2(
                title: hasUpdate
                    ? 'Altere a imagem de seu certificado'
                    : 'Insira uma imagem de seu certificado',
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _pickImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(
                    color: Colors.blue,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt,
                      color: Colors.blue,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Escolher imagem',
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              if (_imageData != null)
                Column(
                  children: [
                    const SizedBox(height: 10),
                    Stack(
                      children: [
                        Image.memory(
                          _imageData!,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _imageData = null;
                              });
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

              //Botão
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: screenWidth * 0.4,
                    child: ElevatedButton(
                      onPressed: _cancel,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFF007FFF)),
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
                        'CANCELAR',
                        style: TextStyle(
                          color: Color(0xFF007FFF),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: screenWidth * 0.4,
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _nextStep,
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
                      child: _isProcessing
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      )
                    : Text(
                        hasUpdate ? 'EDITAR' : 'ADICIONAR',
                        style: const TextStyle(
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
}
