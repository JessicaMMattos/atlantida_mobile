import 'dart:convert';

import 'package:atlantida_mobile/components/custom_alert_dialog.dart';
import 'package:atlantida_mobile/components/dropdown_button.dart';
import 'package:atlantida_mobile/controllers/diving_spot_controller.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:atlantida_mobile/models/diving_spot_create.dart';
import 'package:atlantida_mobile/services/maps_service.dart';
import 'package:atlantida_mobile/screens/home_screen.dart';
import 'package:atlantida_mobile/components/text_field.dart';
import 'package:atlantida_mobile/components/top_bar.dart';
import 'package:atlantida_mobile/components/button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class DivingSpotRegistrationScreen extends StatefulWidget {
  final String? previousRoute;

  const DivingSpotRegistrationScreen({super.key, this.previousRoute});

  @override
  // ignore: library_private_types_in_public_api
  _DivingSpotRegistrationScreenState createState() =>
      _DivingSpotRegistrationScreenState();
}

class _DivingSpotRegistrationScreenState
    extends State<DivingSpotRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final List<String> _waterType = ['SALGADA', 'DOCE'];
  String? _cityState;
  Uint8List? _imageData;
  String? _imageContentType;

  String _selectedWaterType = '';

  String _nameErrorMessage = '';
  String _waterTypeErrorMessage = '';
  String _latitudeErrorMessage = '';
  String _longitudeErrorMessage = '';

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final Uint8List? compressedImageData =
          await FlutterImageCompress.compressWithFile(
        image.path,
        quality: 70,
      );

      if (compressedImageData != null) {
        setState(() {
          _imageData = compressedImageData;
          _imageContentType = image.mimeType;
        });
      }
    }
  }

  Future<void> _getCityAndState(double latitude, double longitude) async {
    var result = await GoogleMapsService().getCityAndState(latitude, longitude);

    setState(() {
      _cityState = '${result['name']}, ${result['state']}'; // Example output
    });
  }

  Future<void> _submitForm() async {
    try {
      setState(() {
        _nameErrorMessage =
            _nameController.text.isEmpty ? 'Campo obrigatório.' : '';
        _waterTypeErrorMessage =
            _selectedWaterType.isEmpty ? 'Campo obrigatório.' : '';
        _latitudeErrorMessage =
            _latitudeController.text.isEmpty ? 'Campo obrigatório.' : '';
        _longitudeErrorMessage =
            _longitudeController.text.isEmpty ? 'Campo obrigatório.' : '';
      });

      if (_formKey.currentState!.validate() &&
          _nameErrorMessage.isEmpty &&
          _waterTypeErrorMessage.isEmpty &&
          _latitudeErrorMessage.isEmpty &&
          _longitudeErrorMessage.isEmpty) {
        Location location = Location(
          type: 'Point',
          coordinates: [
            double.parse(_latitudeController.text),
            double.parse(_longitudeController.text)
          ],
        );

        DivingSpotCreate divingSpot = DivingSpotCreate(
          name: _nameController.text,
          location: location,
          waterBody: _selectedWaterType,
        );

        if (_descriptionController.text.isNotEmpty) {
          divingSpot.description = _descriptionController.text;
        }

        if (_imageData != null) {
          String imageData = base64Encode(_imageData!);

          ImageData image = ImageData(
            data: imageData,
            contentType: _imageContentType ?? 'image/jpeg',
          );
          divingSpot.image = image;
        }

        await DivingSpotController().createDivingSpot(divingSpot);

        showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (BuildContext context) {
            return CustomAlertWithDescriptionDialog(
              title: 'Local de mergulho Cadastrado!',
              description:
                  'Muito obrigado(a) por contribuir com a plataforma cadastrando um novo local.',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomeScreen(),
                  ),
                );
              },
            );
          },
        );
      }
    } catch (error) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Erro ao cadastrar Ponto de Mergulho, tente novamente.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(
        haveReturn: true,
        onPressed: () {
          if (widget.previousRoute != null &&
              widget.previousRoute!.isNotEmpty) {
            Navigator.pushNamed(context, widget.previousRoute!);
          } else {
            Navigator.pop(context);
          }
        },
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 10),
              const Text(
                'Cadastro do Ponto de Mergulho',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Color(0xFF263238),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Complete as informações abaixo para registrar um novo ponto de mergulho.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                  color: Color(0xFF263238),
                ),
              ),
              const SizedBox(height: 25),

              // Campo de Nome
              CustomTextField(
                label: 'Nome do Local',
                controller: _nameController,
                description: 'Insira o nome do Ponto de Mergulho',
                isRequired: true,
                errorMessage: _nameErrorMessage,
              ),
              const SizedBox(height: 20),

              // Campo Tipo da Água
              const Text(
                'Tipo da Água',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF263238),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _waterType.map((type) {
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedWaterType = type;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _selectedWaterType == type
                              ? Colors.grey
                              : Colors.white,
                          border: Border.all(
                            color: Colors.grey,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Center(
                          child: Text(
                            type,
                            style: TextStyle(
                              color: _selectedWaterType == type
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (_waterTypeErrorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: Text(
                    _waterTypeErrorMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 20),

              // Campo de Descrição
              const Title1(
                title: 'Descrição (opcional)',
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Insira uma descrição para o Ponto de Mergulho',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFF263238),
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.black, // Cor preta ao focar
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.red,
                    ),
                  ),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 25),

              // Campo de Localização
              const Title1(
                title: 'Localização',
              ),
              const SizedBox(height: 2),
              const Title2(
                title: 'Insira a Latitude e Longitude do local',
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latitudeController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^-?\d*\.?\d{0,14}$'),
                        ),
                        LengthLimitingTextInputFormatter(22),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Latitude',
                        border: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey,
                          ),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey,
                          ),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xFF263238),
                          ),
                        ),
                        errorBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.red,
                          ),
                        ),
                        focusedErrorBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.red,
                          ),
                        ),
                        errorText: _latitudeErrorMessage.isNotEmpty
                            ? _latitudeErrorMessage
                            : null,
                      ),
                      onChanged: (value) {
                        if (_latitudeController.text.isNotEmpty) {
                          _getCityAndState(
                            double.parse(value),
                            double.parse(_longitudeController.text),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _longitudeController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^-?\d*\.?\d{0,14}$'),
                        ),
                        LengthLimitingTextInputFormatter(22),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Longitude',
                        border: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey,
                          ),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey,
                          ),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xFF263238),
                          ),
                        ),
                        errorBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.red,
                          ),
                        ),
                        focusedErrorBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.red,
                          ),
                        ),
                        errorText: _longitudeErrorMessage.isNotEmpty
                            ? _longitudeErrorMessage
                            : null,
                      ),
                      onChanged: (value) {
                        if (_longitudeController.text.isNotEmpty) {
                          _getCityAndState(
                            double.parse(_latitudeController.text),
                            double.parse(value),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
              if (_cityState != null) ...[
                const SizedBox(height: 10),
                Text(
                  'Localização: $_cityState',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                    color: Color(0xFF263238),
                  ),
                ),
              ],

              const SizedBox(height: 25),

              // Campo para adicionar imagem
              const Title1(
                title: 'Adicionar Imagem (opcional)',
              ),
              const SizedBox(height: 2),
              const Title2(
                title: 'Insira uma imagem do local',
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
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    child: Button(
                      titleButton: 'CADASTRAR PONTO',
                      onPressed: _submitForm,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}
