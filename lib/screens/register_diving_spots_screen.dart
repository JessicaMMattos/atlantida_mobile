import 'dart:convert';
import 'dart:math';

import 'package:atlantida_mobile/components/button.dart';
import 'package:atlantida_mobile/components/text_field.dart';
import 'package:atlantida_mobile/components/top_bar.dart';
import 'package:atlantida_mobile/controllers/diving_spot_controller.dart';
import 'package:atlantida_mobile/models/diving_spot_create.dart';
import 'package:atlantida_mobile/screens/home_screen.dart';
import 'package:atlantida_mobile/services/maps_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

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
  String? _cityState;
  Uint8List? _imageData;
  String? _imageContentType;

  String _nameErrorMessage = '';

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final Uint8List imageData = await image.readAsBytes();
      setState(() {
        _imageData = imageData;
        _imageContentType = image.mimeType;
      });
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
    _nameErrorMessage =
        _nameController.text.isEmpty ? 'Campo obrigatório.' : '';

    if (_formKey.currentState!.validate() &&
        _longitudeController.text.isNotEmpty &&
        _latitudeController.text.isNotEmpty &&
        _nameController.text.isNotEmpty) {

      // Cria o objeto Location com coordenadas válidas
      Location location = Location(
        type: 'Point',
        coordinates: [
          double.parse(_latitudeController.text),
          double.parse(_longitudeController.text)
        ],
      );

      // Cria o objeto DivingSpotCreate com o nome e localização
      DivingSpotCreate divingSpot = DivingSpotCreate(
        name: _nameController.text,
        location: location,
      );

      // Adiciona a descrição se fornecida
      if (_descriptionController.text.isNotEmpty) {
        divingSpot.description = _descriptionController.text;
      }

      // Adiciona a imagem se fornecida
      if (_imageData != null && _imageContentType != null) {
        String imageData = base64Encode(_imageData!);

        ImageData image = ImageData(
          data: imageData,
          contentType: _imageContentType ?? 'image/jpeg',
        );
        divingSpot.image = image;
      }

      // Envia o objeto para o controlador
      var response = await DivingSpotController().createDivingSpot(divingSpot);

      // Exibe o diálogo de sucesso
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Color(0xFF007FFF)),
                SizedBox(width: 10),
                Text('Local de mergulho Cadastrado!'),
              ],
            ),
            content: const Text(
              'Muito obrigado(a) por contribuir com a plataforma cadastrando um novo local.',
              style: TextStyle(color: Color(0xFF263238)),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text(
                  'OK',
                  style: TextStyle(color: Color(0xFF007FFF)),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HomeScreen(),
                    ),
                  );
                },
              ),
            ],
          );
        },
      );
    }
  } catch (error) {
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Erro ao cadastrar Ponto de Mergulho, tente novamente.'),
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

              // Campo de Descrição
              const Title1(
                title: 'Descrição',
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
                          decimal: true, signed: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^-?\d*\.?\d{0,14}$')),
                        LengthLimitingTextInputFormatter(22),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Latitude',
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
                            color: Colors.black,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.red,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        if (_latitudeController.text.isNotEmpty) {
                          _getCityAndState(
                            double.parse(value),
                            double.parse(_latitudeController.text),
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
                          decimal: true, signed: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^-?\d*\.?\d{0,14}$')),
                        LengthLimitingTextInputFormatter(22),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Longitude',
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
                            color: Colors.black,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.red,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        if (_longitudeController.text.isNotEmpty) {
                          _getCityAndState(
                            double.parse(_longitudeController.text),
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
                title: 'Adicionar Imagem',
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
                    Image.memory(
                      _imageData!,
                      height: 200,
                      fit: BoxFit.cover,
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
