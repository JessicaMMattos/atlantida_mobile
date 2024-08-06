import 'dart:convert';

import 'package:atlantida_mobile/controllers/dive_log_controller.dart';
import 'package:atlantida_mobile/controllers/diving_spot_controller.dart';
import 'package:atlantida_mobile/models/diving_spot_return.dart';
import 'package:atlantida_mobile/screens/oioi/EXEMPL.dart';
import 'package:atlantida_mobile/screens/register_diving_spots_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:atlantida_mobile/components/lateral_menu.dart';
import 'package:atlantida_mobile/services/maps_service.dart';
import 'package:atlantida_mobile/components/text_field.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:atlantida_mobile/models/dive_log.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class DiveRegistrationScreen extends StatefulWidget {
  const DiveRegistrationScreen();

  @override
  _DiveRegistrationScreenState createState() => _DiveRegistrationScreenState();
}

final TextEditingController _titleController = TextEditingController();
final TextEditingController _locationController = TextEditingController();
final TextEditingController _dateController = TextEditingController();
final List<String> _diveTypes = ['NA COSTA', 'BARCO', 'OUTROS'];
String _locationDivingSpotId = '';
String _selectedDiveType = '';
String _date = '';

String _titleErrorMessage = '';
String _dateErrorMessage = '';
String _typeErrorMessage = '';
String _locationErrorMessage = '';

bool _isLocationNotFound = false;
bool _isFormSubmitted = false;
List<DivingSpotReturn> _locationSuggestions = [];
Map<String, String> _locationDetails = {};

final TextEditingController _depthController = TextEditingController();
final TextEditingController _bottomTimeInMinutesController =
    TextEditingController();

String _depthErrorMessage = '';
String _bottomTimeInMinutesErrorMessage = '';

final TextEditingController _temperatureAirController = TextEditingController();
final TextEditingController _temperatureSurfaceController =
    TextEditingController();
final TextEditingController _temperatureBottomController =
    TextEditingController();

final List<String> _weatherConditions = [
  '',
  'ENSOLARADO',
  'PARCIALMENTE NUBLADO',
  'NUBLADO',
  'CHUVOSO',
  'COM VENTO',
  'COM NEBLINA'
];
final List<String> _waterType = ['SALGADA', 'DOCE'];
final List<String> _waterBody = [
  '',
  'OCEANO',
  'LAGO',
  'PEDREIRA',
  'RIO',
  'OUTRO'
];
final List<String> _visibility = ['ALTA', 'BAIXA', 'MODERADA'];
final List<String> _waves = ['', 'NENHUMA', 'PEQUENA', 'MÉDIA', 'GRANDE'];
final List<String> _current = ['', 'NENHUM', 'LEVE', 'MÉDIA', 'FORTE'];
final List<String> _surge = ['', 'LEVE', 'MÉDIA', 'FORTE'];
String _selectedWeatherConditions = '';
String _selectedWaterType = '';
String _selectedWaterBody = '';
String _selectedVisibility = '';
String _selectedWaves = '';
String _selectedCurrent = '';
String _selectedSurge = '';

final TextEditingController _weightController = TextEditingController();
final TextEditingController _cylinderSizeController = TextEditingController();
final TextEditingController _cylinderInitialPressureController =
    TextEditingController();
final TextEditingController _cylinderFinalPressureController =
    TextEditingController();
final TextEditingController _usedAmountController = TextEditingController();

final List<String> _suit = [
  '',
  'NENHUM',
  'ROUPA LONGA 3MM',
  'ROUPA LONGA 5MM',
  'ROUPA LONGA 7MM',
  'CURTA',
  'SEMI SECA',
  'ROUPA SECA'
];
final List<String> _cylinderType = ['AÇO', 'ALUMÍNIO', 'OUTROS'];
final List<String> _cylinderGasMixture = [
  '',
  'AR',
  'EANX32',
  'EANX36',
  'EANX40',
  'HELIOX',
  'TRIMIX',
  'HYDROX',
  'OXYGEN',
  'OUTRO'
];
final List<String> _additionalEquipment = ['LUVAS', 'BOTAS', 'LANTERNA'];

String _selectedSuit = '';
String _selectedCylinderType = '';
String _selectedCylinderGasMixture = '';
List<String> _selectedAdditionalEquipment = [];

final TextEditingController _notesController = TextEditingController();
double? _rating;
int? _difficulty;
List<Photo> _media = [];

var newDiveLog;

class DecimalTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll(',', '.');

    final regExp = RegExp(r'^-?\d*\.?\d{0,2}$');

    if (regExp.hasMatch(text)) {
      final newText = text.replaceAll(RegExp(r'\.(?=.*\.)'), '');

      return newValue.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    }

    return oldValue;
  }
}

class _DiveRegistrationScreenState extends State<DiveRegistrationScreen> {
  final dateMaskFormatter = MaskTextInputFormatter(
    mask: '##/##/####',
    filter: {'#': RegExp(r'[0-9]')},
  );

  void _cancel() {}

  void _nextStep() {
    final dateValidation = _validateDate(_dateController.text);
    _isFormSubmitted = true;

    setState(() {
      _titleErrorMessage =
          _titleController.text.isEmpty ? 'Campo obrigatório.' : '';
      _locationErrorMessage =
          _locationDivingSpotId.isEmpty ? 'Selecione um local cadastrado.' : '';
      _locationErrorMessage = _locationController.text.isEmpty
          ? 'Campo obrigatório.'
          : _locationErrorMessage;
      _dateErrorMessage =
          dateValidation['format'] ?? dateValidation['age'] ?? '';
      _typeErrorMessage = _selectedDiveType.isEmpty ? 'Campo obrigatório.' : '';
    });

    if (_titleErrorMessage.isEmpty &&
        _dateErrorMessage.isEmpty &&
        _typeErrorMessage.isEmpty &&
        _locationErrorMessage.isEmpty) {
      newDiveLog = DiveLog(
        title: _titleController.text,
        divingSpotId: _locationDivingSpotId,
        date: _date,
        type: _selectedDiveType,
      );

      try {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DiveRegistrationScreen2(),
          ),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Erro na primeira etapa do registro, tente novamente.')),
        );
      }
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
      if (date.isEmpty) {
        errors['format'] = 'Campo obrigatório.';
        return errors;
      }

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
            final birthDate = DateTime(year, month, day);
            if (birthDate.isAfter(currentDate)) {
              errors['age'] = 'Data inválida.';
            }
            _date = DateFormat('yyyy-MM-dd').format(birthDate);
          }
        }
      }
    } catch (e) {
      errors['format'] = 'Data de nascimento inválida (formato DD/MM/AAAA).';
    }

    return errors;
  }

  Future<void> _fetchLocationSuggestions(String query) async {
    if (query.isNotEmpty) {
      try {
        List<DivingSpotReturn> suggestions =
            await DivingSpotController().getDivingSpotsByName(query);

        // Obter detalhes de localização para cada sugestão
        final Map<String, String> details = {};
        for (var spot in suggestions) {
          final latitude = spot.location.coordinates[0];
          final longitude = spot.location.coordinates[1];
          final result =
              await GoogleMapsService().getCityAndState(latitude, longitude);
          details[spot.name] = '${result['name']}, ${result['state']}';
        }

        setState(() {
          _locationSuggestions = suggestions;
          _locationDetails = details;
          _isLocationNotFound = _locationSuggestions.isEmpty;
        });
      } catch (e) {
        setState(() {
          _locationSuggestions = [];
          _locationDetails = {};
          _isLocationNotFound = false;
        });
      }
    } else {
      setState(() {
        _locationSuggestions = [];
        _locationDetails = {};
        _isLocationNotFound = false;
      });
    }
  }

  void _handleSearchChange(String value) {
    _locationErrorMessage = '';
    _fetchLocationSuggestions(value);
  }

  void _handleLocationSelect(DivingSpotReturn spot) {
    setState(() {
      _locationDivingSpotId = spot.id;
      _locationController.text = spot.name;
      _locationSuggestions = [];
      _isLocationNotFound = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: LateralMenu(),
      drawer: LateralMenuDrawer(),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding:
                    EdgeInsets.symmetric(horizontal: screenSize.width * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              const Text(
                'Registro de Mergulho',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Color(0xFF263238),
                ),
              ),
              SizedBox(height: 10),
              const Text(
                'Complete as informações abaixo para registrar seu mergulho.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                  color: Color(0xFF263238),
                ),
              ),
              SizedBox(height: 25),
              Row(
                children: [
                  Container(
                    width: 25,
                    height: 25,
                    decoration: BoxDecoration(
                      color: Color(0xFF007FFF),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Center(
                      child: Text(
                        '1',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Informações Gerais',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF263238),
                    ),
                  ),
                  Text(
                    ' (Obrigatório)',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: screenHeight * 0.007,
                      decoration: BoxDecoration(
                        color: Color(0xFF007FFF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: screenHeight * 0.007,
                      decoration: BoxDecoration(
                        color: Color(0xFFF2F2F2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: screenHeight * 0.007,
                      decoration: BoxDecoration(
                        color: Color(0xFFF2F2F2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: screenHeight * 0.007,
                      decoration: BoxDecoration(
                        color: Color(0xFFF2F2F2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: screenHeight * 0.007,
                      decoration: BoxDecoration(
                        color: Color(0xFFF2F2F2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 10),
              Text(
                'Etapa 1 de 5',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  color: Color(0xFF777777),
                ),
              ),
              SizedBox(height: 30),

              // Campo de título
              CustomTextField(
                label: 'Título',
                description: 'Digite o título do mergulho',
                controller: _titleController,
                errorMessage: _titleErrorMessage,
                isRequired: true,
              ),
              SizedBox(height: 20),

              // Campo de local
              Text(
                'Local',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF263238),
                ),
              ),
              SizedBox(height: 10),
              // Campo de local
              TextField(
                controller: _locationController,
                decoration: InputDecoration(
                  hintText: 'Digite o nome do local',
                  suffixIcon: _isLocationNotFound
                      ? IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            final currentRoute = ModalRoute.of(context)?.settings.name;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DivingSpotRegistrationScreen(previousRoute: currentRoute),
                              ),
                            );
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color:
                          _isFormSubmitted && _locationErrorMessage.isNotEmpty
                              ? Colors.red
                              : Colors.grey,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color:
                          _isFormSubmitted && _locationErrorMessage.isNotEmpty
                              ? Colors.red
                              : Colors.grey,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color:
                          _isFormSubmitted && _locationErrorMessage.isNotEmpty
                              ? Colors.red
                              : Color(0xFF263238),
                    ),
                  ),
                ),
                onChanged: _handleSearchChange,
              ),
              if (!_locationErrorMessage.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _locationErrorMessage,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ),
              if (_isLocationNotFound && _locationController.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Não encontrado, por favor cadastre.',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ),
              if (_locationSuggestions.isNotEmpty) ...[
                SizedBox(height: 10),
                Container(
                  height: 80,
                  child: Stack(
                    children: [
                      ListView.builder(
                        itemCount: _locationSuggestions.length,
                        itemBuilder: (context, index) {
                          final spot = _locationSuggestions[index];
                          return ListTile(
                            title: Text(spot.name),
                            subtitle: Text(_locationDetails[spot.name] ?? ''),
                            onTap: () => _handleLocationSelect(spot),
                          );
                        },
                        scrollDirection: Axis.vertical,
                        physics: BouncingScrollPhysics(),
                      ),
                    ],
                  ),
                ),
              ],
              SizedBox(height: 20),

              // Campo de data
              Text(
                'Data',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF263238),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _dateController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  dateMaskFormatter,
                  LengthLimitingTextInputFormatter(10),
                ],
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _dateErrorMessage.isNotEmpty
                          ? Colors.red
                          : Colors.grey,
                    ),
                  ),
                  hintText: 'dd/mm/aaaa',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _dateErrorMessage.isNotEmpty
                          ? Colors.red
                          : Colors.grey,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _dateErrorMessage.isNotEmpty
                          ? Colors.red
                          : Color(0xFF263238),
                    ),
                  ),
                ),
              ),
              if (_dateErrorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: Text(
                    _dateErrorMessage,
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              SizedBox(height: 20),

              Text(
                'Tipo de Mergulho',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF263238),
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Como você entrou na água?',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.normal,
                  fontSize: 14,
                  color: Color(0xFF263238),
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _diveTypes.map((type) {
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedDiveType = type;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _selectedDiveType == type
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
                              color: _selectedDiveType == type
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
              if (_typeErrorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: Text(
                    _typeErrorMessage,
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              SizedBox(height: 20),

              // Botões
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _cancel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Color(0xFF007FFF)),
                      padding:
                          EdgeInsets.symmetric(vertical: 22, horizontal: 30),
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
                  ElevatedButton(
                    onPressed: _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF007FFF),
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
                      'PRÓXIMA ETAPA',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class DiveRegistrationScreen2 extends StatefulWidget {
  DiveRegistrationScreen2();

  @override
  _DiveRegistrationScreen2State createState() =>
      _DiveRegistrationScreen2State();
}

class _DiveRegistrationScreen2State extends State<DiveRegistrationScreen2> {
  void _toGoBack() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => DiveRegistrationScreen()),
    );
  }

  void _nextStep() {
    setState(() {
      _depthErrorMessage =
          _depthController.text.isEmpty ? 'Campo obrigatório.' : '';
      _bottomTimeInMinutesErrorMessage =
          _bottomTimeInMinutesController.text.isEmpty
              ? 'Campo obrigatório.'
              : '';
    });

    if (_depthErrorMessage.isEmpty &&
        _bottomTimeInMinutesErrorMessage.isEmpty) {
      try {
        int timeInMinutes = convertFormattedBottomTimeToMinutes(
            _bottomTimeInMinutesController.text);

        newDiveLog.depth = double.parse(_depthController.text);
        newDiveLog.bottomTimeInMinutes = timeInMinutes;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DiveRegistrationScreen3()),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Erro na segunda etapa do registro, tente novamente.')),
        );
      }
    }
  }

  String formatBottomTime(String value) {
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.isEmpty) return '';

    final paddedValue = digitsOnly.padLeft(4, '0');

    final hours = int.parse(paddedValue.substring(0, paddedValue.length - 2));
    final minutes = int.parse(paddedValue.substring(paddedValue.length - 2));

    return '${hours.toString()}:${minutes.toString().padLeft(2, '0')}';
  }

  int convertFormattedBottomTimeToMinutes(String formattedTime) {
    final parts = formattedTime.split(':');
    if (parts.length != 2) return 0;

    final hours = int.tryParse(parts[0]) ?? 0;
    final minutes = int.tryParse(parts[1]) ?? 0;

    return (hours * 60) + minutes;
  }

  String formatDepth(String value) {
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.isEmpty) return '0.00';
    final depth = int.parse(digitsOnly).toDouble() / 100;

    return depth.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: const LateralMenu(),
      drawer: const LateralMenuDrawer(),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding:
                    EdgeInsets.symmetric(horizontal: screenSize.width * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              Text(
                'Registro de Mergulho',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Color(0xFF263238),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Complete as informações abaixo para registrar seu mergulho.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                  color: Color(0xFF263238),
                ),
              ),
              SizedBox(height: 25),
              Row(
                children: [
                  Container(
                    width: 25,
                    height: 25,
                    decoration: BoxDecoration(
                      color: Color(0xFF007FFF),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Center(
                      child: Text(
                        '2',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Profundidade e Tempo',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF263238),
                    ),
                  ),
                  Text(
                    ' (Obrigatório)',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: screenHeight * 0.007,
                      decoration: BoxDecoration(
                        color: Color(0xFF007FFF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: screenHeight * 0.007,
                      decoration: BoxDecoration(
                        color: Color(0xFF007FFF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: screenHeight * 0.007,
                      decoration: BoxDecoration(
                        color: Color(0xFFF2F2F2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: screenHeight * 0.007,
                      decoration: BoxDecoration(
                        color: Color(0xFFF2F2F2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: screenHeight * 0.007,
                      decoration: BoxDecoration(
                        color: Color(0xFFF2F2F2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text(
                'Etapa 2 de 5',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  color: Color(0xFF777777),
                ),
              ),
              SizedBox(height: 30),

              // Campo de Profundidade
              Text(
                'Profundidade máxima',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF263238),
                ),
              ),
              SizedBox(height: 2),
              Text(
                'A que profundidade você chegou? (Em metros)',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.normal,
                  fontSize: 14,
                  color: Color(0xFF263238),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _depthController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    if (newValue.text.isEmpty) {
                      return newValue;
                    }
                    final formattedValue = formatDepth(newValue.text);
                    return newValue.copyWith(
                      text: formattedValue,
                      selection: TextSelection.collapsed(
                          offset: formattedValue.length),
                    );
                  }),
                ],
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _depthErrorMessage.isNotEmpty
                          ? Colors.red
                          : Colors.grey,
                    ),
                  ),
                  hintText: '0.00 m',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _depthErrorMessage.isNotEmpty
                          ? Colors.red
                          : Colors.grey,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _depthErrorMessage.isNotEmpty
                          ? Colors.red
                          : Color(0xFF263238),
                    ),
                  ),
                ),
              ),
              if (_depthErrorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: Text(
                    _depthErrorMessage,
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              SizedBox(height: 20),

              // Campo de Tempo no fundo
              Text(
                'Tempo no fundo',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF263238),
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Quanto tempo levou o seu mergulho? (Em horas e minutos)',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.normal,
                  fontSize: 14,
                  color: Color(0xFF263238),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _bottomTimeInMinutesController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    if (newValue.text.isEmpty) {
                      return newValue;
                    }
                    final formattedValue = formatBottomTime(newValue.text);
                    return newValue.copyWith(
                      text: formattedValue,
                      selection: TextSelection.collapsed(
                          offset: formattedValue.length),
                    );
                  }),
                ],
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _bottomTimeInMinutesErrorMessage.isNotEmpty
                          ? Colors.red
                          : Colors.grey,
                    ),
                  ),
                  hintText: '0:00 h',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _bottomTimeInMinutesErrorMessage.isNotEmpty
                          ? Colors.red
                          : Colors.grey,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _bottomTimeInMinutesErrorMessage.isNotEmpty
                          ? Colors.red
                          : Color(0xFF263238),
                    ),
                  ),
                ),
              ),
              if (_bottomTimeInMinutesErrorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: Text(
                    _bottomTimeInMinutesErrorMessage,
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              SizedBox(height: 20),

              // Botões
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _toGoBack,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Color(0xFF007FFF)),
                      padding:
                          EdgeInsets.symmetric(vertical: 22, horizontal: 30),
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
                      'ETAPA ANTERIOR',
                      style: TextStyle(
                        color: Color(0xFF007FFF),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF007FFF),
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
                      'PRÓXIMA ETAPA',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class DiveRegistrationScreen3 extends StatefulWidget {
  DiveRegistrationScreen3();

  @override
  _DiveRegistrationScreen3State createState() =>
      _DiveRegistrationScreen3State();
}

class _DiveRegistrationScreen3State extends State<DiveRegistrationScreen3> {
  void _toGoBack() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => DiveRegistrationScreen2()),
    );
  }

  void _nextStep() {
    try {
      if (_temperatureAirController.text.isNotEmpty ||
          _temperatureSurfaceController.text.isNotEmpty ||
          _temperatureBottomController.text.isNotEmpty) {
        double? air = _temperatureAirController.text.isNotEmpty
            ? double.tryParse(_temperatureAirController.text)
            : null;
        double? surface = _temperatureSurfaceController.text.isNotEmpty
            ? double.tryParse(_temperatureSurfaceController.text)
            : null;
        double? bottom = _temperatureBottomController.text.isNotEmpty
            ? double.tryParse(_temperatureBottomController.text)
            : null;

        if (air != null || surface != null || bottom != null) {
          newDiveLog.temperature = Temperature(
            air: air,
            surface: surface,
            bottom: bottom,
          );
        }
      }
      if (_selectedWeatherConditions.isNotEmpty) {
        newDiveLog.weatherConditions = _selectedWeatherConditions;
      }
      if (_selectedWaterType.isNotEmpty) {
        newDiveLog.waterType = _selectedWaterType;
      }
      if (_selectedWaterBody.isNotEmpty) {
        newDiveLog.waterBody = _selectedWaterBody;
      }
      if (_selectedVisibility.isNotEmpty) {
        newDiveLog.visibility = _selectedVisibility;
      }
      if (_selectedWaves.isNotEmpty) {
        newDiveLog.waves = _selectedWaves;
      }
      if (_selectedCurrent.isNotEmpty) {
        newDiveLog.current = _selectedCurrent;
      }
      if (_selectedSurge.isNotEmpty) {
        newDiveLog.surge = _selectedSurge;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DiveRegistrationScreen4()),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Erro na terceira etapa do registro, tente novamente.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: const LateralMenu(),
      drawer: const LateralMenuDrawer(),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding:
                    EdgeInsets.symmetric(horizontal: screenSize.width * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              const Text(
                'Registro de Mergulho',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Color(0xFF263238),
                ),
              ),
              SizedBox(height: 10),
              const Text(
                'Complete as informações abaixo para registrar seu mergulho.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                  color: Color(0xFF263238),
                ),
              ),
              SizedBox(height: 25),
              Row(
                children: [
                  Container(
                    width: 25,
                    height: 25,
                    decoration: BoxDecoration(
                      color: Color(0xFF007FFF),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Center(
                      child: Text(
                        '3',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Condições Ambientais',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF263238),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: screenHeight * 0.007,
                      decoration: BoxDecoration(
                        color: Color(0xFF007FFF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: screenHeight * 0.007,
                      decoration: BoxDecoration(
                        color: Color(0xFF007FFF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: screenHeight * 0.007,
                      decoration: BoxDecoration(
                        color: Color(0xFF007FFF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: screenHeight * 0.007,
                      decoration: BoxDecoration(
                        color: Color(0xFFF2F2F2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: screenHeight * 0.007,
                      decoration: BoxDecoration(
                        color: Color(0xFFF2F2F2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 10),
              Text(
                'Etapa 3 de 5',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  color: Color(0xFF777777),
                ),
              ),
              SizedBox(height: 30),

              // Campos de Condições Climáticas
              const Title1(
                title: 'Condições Climáticas',
              ),
              SizedBox(height: 2),
              const Title2(
                title: 'Como estavam as condições climáticas?',
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedWeatherConditions,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color(0xFF263238),
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                icon: const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.grey,
                ),
                elevation: 16,
                style: const TextStyle(color: Colors.black),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedWeatherConditions = newValue!;
                  });
                },
                items: _weatherConditions
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                dropdownColor: Colors.white,
              ),
              SizedBox(height: 20),

              // Campos de Temperatura
              const Title1(
                title: 'Temperatura',
              ),
              SizedBox(height: 2),
              const Title2(
                title: 'Como estava a temperatura? (Em Celsius)',
              ),
              SizedBox(height: 10),

              // Do Ar
              TextField(
                controller: _temperatureAirController,
                keyboardType: TextInputType.numberWithOptions(
                    decimal: true, signed: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'^-?\d*\.?\d{0,2}$')),
                  LengthLimitingTextInputFormatter(4),
                ],
                decoration: const InputDecoration(
                  hintText: 'Temperatura do Ar',
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
                ),
              ),
              SizedBox(height: 10),

              // Na Superfície
              TextField(
                controller: _temperatureSurfaceController,
                keyboardType: TextInputType.numberWithOptions(
                    decimal: true, signed: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'^-?\d*\.?\d{0,2}$')),
                  LengthLimitingTextInputFormatter(4),
                ],
                decoration: const InputDecoration(
                  hintText: 'Temperatura na Superfície',
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
                ),
              ),
              SizedBox(height: 10),

              // No Fundo
              TextField(
                controller: _temperatureBottomController,
                keyboardType: TextInputType.numberWithOptions(
                    decimal: true, signed: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'^-?\d*\.?\d{0,2}$')),
                  LengthLimitingTextInputFormatter(4),
                ],
                decoration: const InputDecoration(
                  hintText: 'Temperatura no Fundo',
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
                ),
              ),
              SizedBox(height: 10),

              // Campo Tipo de Água
              const Title1(
                title: 'Tipo de Água',
              ),
              SizedBox(height: 2),
              const Title2(
                title: 'Qual era o tipo de água?',
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _waterType.map((type) {
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          if (_selectedWaterType == type) {
                            _selectedWaterType = '';
                          } else {
                            _selectedWaterType = type;
                          }
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _selectedWaterType == type
                              ? Colors.grey
                              : Colors.white,
                          border: Border.all(color: Colors.grey, width: 1),
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
              SizedBox(height: 20),

              // Campo Corpo de Água
              const Title1(
                title: 'Corpo de Água',
              ),
              SizedBox(height: 2),
              const Title2(
                title: 'Em que corpo de água você mergulhou?',
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedWaterBody,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color(0xFF263238),
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                icon: const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.grey,
                ),
                elevation: 16,
                style: const TextStyle(color: Colors.black),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedWaterBody = newValue!;
                  });
                },
                items: _waterBody.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                dropdownColor: Colors.white,
              ),
              SizedBox(height: 20),

              // Campo Visibilidade
              const Title1(
                title: 'Visibilidade',
              ),
              SizedBox(height: 2),
              const Title2(
                title: 'Como estava a visibilidade?',
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _visibility.map((type) {
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          if (_selectedVisibility == type) {
                            _selectedVisibility = '';
                          } else {
                            _selectedVisibility = type;
                          }
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _selectedVisibility == type
                              ? Colors.grey
                              : Colors.white,
                          border: Border.all(color: Colors.grey, width: 1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Center(
                          child: Text(
                            type,
                            style: TextStyle(
                              color: _selectedVisibility == type
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
              SizedBox(height: 20),

              // Campo Ondas
              const Title1(
                title: 'Ondas',
              ),
              SizedBox(height: 2),
              const Title2(
                title: 'Como estavam as ondas?',
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedWaves,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color(0xFF263238),
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                icon: const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.grey,
                ),
                elevation: 16,
                style: const TextStyle(color: Colors.black),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedWaves = newValue!;
                  });
                },
                items: _waves.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                dropdownColor: Colors.white,
              ),
              SizedBox(height: 20),

              // Campo Correnteza
              const Title1(
                title: 'Correnteza',
              ),
              SizedBox(height: 2),
              const Title2(
                title: 'Como estava a correnteza?',
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedCurrent,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color(0xFF263238),
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                icon: const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.grey,
                ),
                elevation: 16,
                style: const TextStyle(color: Colors.black),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCurrent = newValue!;
                  });
                },
                items: _current.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                dropdownColor: Colors.white,
              ),
              SizedBox(height: 20),

              // Campo Correnteza
              const Title1(
                title: 'Ondulação',
              ),
              SizedBox(height: 2),
              const Title2(
                title: 'Como estava a ondulação?',
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedSurge,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color(0xFF263238),
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                icon: const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.grey,
                ),
                elevation: 16,
                style: const TextStyle(color: Colors.black),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedSurge = newValue!;
                  });
                },
                items: _surge.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                dropdownColor: Colors.white,
              ),
              SizedBox(height: 20),

              // Botões
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _toGoBack,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Color(0xFF007FFF)),
                      padding:
                          EdgeInsets.symmetric(vertical: 22, horizontal: 30),
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
                      'ETAPA ANTERIOR',
                      style: TextStyle(
                        color: Color(0xFF007FFF),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF007FFF),
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
                      'PRÓXIMA ETAPA',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class DiveRegistrationScreen4 extends StatefulWidget {
  DiveRegistrationScreen4();

  @override
  _DiveRegistrationScreen4State createState() =>
      _DiveRegistrationScreen4State();
}

class _DiveRegistrationScreen4State extends State<DiveRegistrationScreen4> {
  @override
  void initState() {
    super.initState();

    _cylinderInitialPressureController.addListener(_calculateUsedAmount);
    _cylinderFinalPressureController.addListener(_calculateUsedAmount);
  }

  void _toGoBack() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => DiveRegistrationScreen3()),
    );
  }

  void _nextStep() {
    try {
      if (_weightController.text.isNotEmpty) {
        newDiveLog.weight = _weightController.text;
      }
      if (_cylinderSizeController.text.isNotEmpty ||
          _cylinderInitialPressureController.text.isNotEmpty ||
          _cylinderFinalPressureController.text.isNotEmpty ||
          _usedAmountController.text.isNotEmpty) {
        newDiveLog.cylinder = Cylinder(
          size: _cylinderSizeController.text.isNotEmpty
              ? double.tryParse(_cylinderSizeController.text)
              : null,
          initialPressure: _cylinderInitialPressureController.text.isNotEmpty
              ? double.tryParse(_cylinderInitialPressureController.text)
              : null,
          finalPressure: _cylinderFinalPressureController.text.isNotEmpty
              ? double.tryParse(_cylinderFinalPressureController.text)
              : null,
          usedAmount: _usedAmountController.text.isNotEmpty
              ? double.tryParse(_usedAmountController.text)
              : null,
          type: _selectedCylinderType.isNotEmpty ? _selectedCylinderType : null,
          gasMixture: _selectedCylinderGasMixture.isNotEmpty
              ? _selectedCylinderGasMixture
              : null,
        );
      }

      if (_selectedSuit.isNotEmpty) {
        newDiveLog.suit = _selectedSuit;
      }
      if (_selectedAdditionalEquipment.isNotEmpty) {
        newDiveLog.additionalEquipment = _selectedAdditionalEquipment;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DiveRegistrationScreen5()),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Erro na quarta etapa do registro, tente novamente.')),
      );
    }
  }

  void _calculateUsedAmount() {
    final String initialPressureText = _cylinderInitialPressureController.text;
    final String finalPressureText = _cylinderFinalPressureController.text;

    if (initialPressureText.isNotEmpty && finalPressureText.isNotEmpty) {
      final double? initialPressure = double.tryParse(initialPressureText);
      final double? finalPressure = double.tryParse(finalPressureText);

      if (initialPressure != null && finalPressure != null) {
        final double usedAmount = initialPressure - finalPressure;
        _usedAmountController.text = usedAmount.toStringAsFixed(2);
      } else {
        _usedAmountController.clear();
      }
    } else {
      _usedAmountController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: const LateralMenu(),
      drawer: const LateralMenuDrawer(),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding:
                    EdgeInsets.symmetric(horizontal: screenSize.width * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              Text(
                'Registro de Mergulho',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Color(0xFF263238),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Complete as informações abaixo para registrar seu mergulho.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                  color: Color(0xFF263238),
                ),
              ),
              SizedBox(height: 25),
              Row(
                children: [
                  Container(
                    width: 25,
                    height: 25,
                    decoration: BoxDecoration(
                      color: Color(0xFF007FFF),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Center(
                      child: Text(
                        '4',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Equipamentos',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF263238),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: screenHeight * 0.007,
                      decoration: BoxDecoration(
                        color: Color(0xFF007FFF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: screenHeight * 0.007,
                      decoration: BoxDecoration(
                        color: Color(0xFF007FFF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: screenHeight * 0.007,
                      decoration: BoxDecoration(
                        color: Color(0xFF007FFF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: screenHeight * 0.007,
                      decoration: BoxDecoration(
                        color: Color(0xFF007FFF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: screenHeight * 0.007,
                      decoration: BoxDecoration(
                        color: Color(0xFFF2F2F2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text(
                'Etapa 4 de 5',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  color: Color(0xFF777777),
                ),
              ),
              SizedBox(height: 30),

              // Campo de Roupa
              const Title1(
                title: 'Roupa',
              ),
              SizedBox(height: 2),
              const Title2(
                title: 'Que roupa você vestiu?',
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedSuit,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color(0xFF263238),
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                icon: const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.grey,
                ),
                elevation: 16,
                style: const TextStyle(color: Colors.black),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedSuit = newValue!;
                  });
                },
                items: _suit.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                dropdownColor: Colors.white,
              ),
              SizedBox(height: 20),

              // Campo Lastro
              const Title1(
                title: 'Lastro',
              ),
              SizedBox(height: 2),
              const Title2(
                title: 'Qual foi o peso do lastro que você usou? (Em Kg)',
              ),
              SizedBox(height: 10),
              TextField(
                controller: _weightController,
                keyboardType: TextInputType.numberWithOptions(
                    decimal: true, signed: true),
                inputFormatters: [
                  DecimalTextInputFormatter(),
                  LengthLimitingTextInputFormatter(6),
                ],
                decoration: const InputDecoration(
                  hintText: 'Lastro',
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
                ),
              ),
              SizedBox(height: 20),

              // Campo Tipo de Cilindro
              const Title1(
                title: 'Cilindro',
              ),
              SizedBox(height: 2),
              const Title2(
                title: 'Qual tipo de cilindro você usou?',
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _cylinderType.map((type) {
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          if (_selectedCylinderType == type) {
                            _selectedCylinderType = '';
                          } else {
                            _selectedCylinderType = type;
                          }
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _selectedCylinderType == type
                              ? Colors.grey
                              : Colors.white,
                          border: Border.all(color: Colors.grey, width: 1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Center(
                          child: Text(
                            type,
                            style: TextStyle(
                              color: _selectedCylinderType == type
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
              // Tamanho do cilindro
              SizedBox(height: 10),
              TextField(
                controller: _cylinderSizeController,
                keyboardType: TextInputType.numberWithOptions(
                    decimal: true, signed: true),
                inputFormatters: [
                  DecimalTextInputFormatter(),
                  LengthLimitingTextInputFormatter(6),
                ],
                decoration: const InputDecoration(
                  hintText: 'Tamanho do Cilindro (Em Litros)',
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
                ),
              ),
              SizedBox(height: 20),

              // Campo de Mistura Gasosa
              const Title1(
                title: 'Mistura Gasosa',
              ),
              SizedBox(height: 2),
              const Title2(
                title: 'Que tipo de gás você usou?',
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedCylinderGasMixture,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color(0xFF263238),
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                icon: const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.grey,
                ),
                elevation: 16,
                style: const TextStyle(color: Colors.black),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCylinderGasMixture = newValue!;
                  });
                },
                items: _cylinderGasMixture
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                dropdownColor: Colors.white,
              ),
              SizedBox(height: 20),

              // Campos de Pressão do Cilindro
              const Title1(
                title: 'Pressão do Cilindro',
              ),
              SizedBox(height: 10),

              // Inicial
              TextField(
                controller: _cylinderInitialPressureController,
                keyboardType: TextInputType.numberWithOptions(
                    decimal: true, signed: true),
                inputFormatters: [
                  DecimalTextInputFormatter(),
                  LengthLimitingTextInputFormatter(6),
                ],
                decoration: const InputDecoration(
                  hintText: 'Pressão Inicial (Em Bar)',
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
                ),
              ),
              SizedBox(height: 10),

              // Final
              TextField(
                controller: _cylinderFinalPressureController,
                keyboardType: TextInputType.numberWithOptions(
                    decimal: true, signed: true),
                inputFormatters: [
                  DecimalTextInputFormatter(),
                  LengthLimitingTextInputFormatter(6),
                ],
                decoration: const InputDecoration(
                  hintText: 'Pressão Final (Em Bar)',
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
                ),
              ),
              SizedBox(height: 10),

              // Quantidade Usada
              TextField(
                controller: _usedAmountController,
                keyboardType: TextInputType.numberWithOptions(
                    decimal: true, signed: true),
                inputFormatters: [
                  DecimalTextInputFormatter(),
                  LengthLimitingTextInputFormatter(6),
                ],
                decoration: const InputDecoration(
                  hintText: 'Quantidade Usada (Em Bar)',
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
                ),
              ),
              SizedBox(height: 10),

              // Campo Equipamentos Adicionais
              const Title1(
                title: 'Equipamentos Adicionais',
              ),
              SizedBox(height: 2),
              const Title2(
                title: 'Que outros equipamentos você usou?',
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _additionalEquipment.map((type) {
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          if (_selectedAdditionalEquipment.contains(type)) {
                            _selectedAdditionalEquipment.remove(type);
                          } else {
                            _selectedAdditionalEquipment.add(type);
                          }
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _selectedAdditionalEquipment.contains(type)
                              ? Colors.grey
                              : Colors.white,
                          border: Border.all(color: Colors.grey, width: 1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Center(
                          child: Text(
                            type,
                            style: TextStyle(
                              color: _selectedAdditionalEquipment.contains(type)
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
              SizedBox(height: 20),

              // Botões
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _toGoBack,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Color(0xFF007FFF)),
                      padding:
                          EdgeInsets.symmetric(vertical: 22, horizontal: 30),
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
                      'ETAPA ANTERIOR',
                      style: TextStyle(
                        color: Color(0xFF007FFF),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF007FFF),
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
                      'PRÓXIMA ETAPA',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class DiveRegistrationScreen5 extends StatefulWidget {
  DiveRegistrationScreen5();

  @override
  _DiveRegistrationScreen5State createState() =>
      _DiveRegistrationScreen5State();
}

class _DiveRegistrationScreen5State extends State<DiveRegistrationScreen5> {
  void _toGoBack() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => DiveRegistrationScreen4()),
    );
  }

  Future<void> _nextStep() async {
    try {
      if (_notesController.text.isNotEmpty) {
        newDiveLog.notes = _notesController.text;
      }

      if (_rating != null) {
        newDiveLog.rating = _rating;
      }

      if (_difficulty != null) {
        newDiveLog.difficulty = _difficulty;
      }

      if (_media.isNotEmpty) {
        newDiveLog.photos = _media;
      }

      var response =
          await DiveLogController().createDiveLog(context, newDiveLog);
      print(response.body);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Erro na ultima etapa do registro, tente novamente.')),
      );
    }
  }

  Future<void> _pickMedia() async {
    final ImagePicker _picker = ImagePicker();
    final List<XFile>? files = await _picker.pickMultiImage();
    List<Photo> tempMedia = [];

    if (files != null && files.isNotEmpty) {
      for (var file in files) {
        final Uint8List fileData = await file.readAsBytes();
        final String contentType = file.mimeType ?? 'image/jpeg';
        final String base64Data = base64Encode(fileData);
        tempMedia.add(Photo(data: base64Data, contentType: contentType));
      }
    }

    setState(() {
      _media.addAll(tempMedia);
    });
  }

Future<void> _pickVideo() async {
  final ImagePicker _picker = ImagePicker();
  final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
  List<Photo> tempMedia = [];

  if (video != null) {
    final Uint8List videoData = await video.readAsBytes();
    final String contentType = video.mimeType ?? 'video/mp4';
    final String base64Data = base64Encode(videoData); // Codifique os dados como uma string base64
    tempMedia.add(Photo(data: base64Data, contentType: contentType));
  }

  setState(() {
    _media.addAll(tempMedia);
  });
}


  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: const LateralMenu(),
      drawer: const LateralMenuDrawer(),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding:
                    EdgeInsets.symmetric(horizontal: screenSize.width * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              Text(
                'Registro de Mergulho',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Color(0xFF263238),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Complete as informações abaixo para registrar seu mergulho.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                  color: Color(0xFF263238),
                ),
              ),
              SizedBox(height: 25),
              Row(
                children: [
                  Container(
                    width: 25,
                    height: 25,
                    decoration: BoxDecoration(
                      color: Color(0xFF007FFF),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Center(
                      child: Text(
                        '5',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Experiência e Observações',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF263238),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: screenHeight * 0.007,
                      decoration: BoxDecoration(
                        color: Color(0xFF007FFF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: screenHeight * 0.007,
                      decoration: BoxDecoration(
                        color: Color(0xFF007FFF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: screenHeight * 0.007,
                      decoration: BoxDecoration(
                        color: Color(0xFF007FFF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: screenHeight * 0.007,
                      decoration: BoxDecoration(
                        color: Color(0xFF007FFF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: screenHeight * 0.007,
                      decoration: BoxDecoration(
                        color: Color(0xFF007FFF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 10),
              Text(
                'Etapa 5 de 5',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  color: Color(0xFF777777),
                ),
              ),
              SizedBox(height: 30),

              const Title1(
                title: 'Opinião',
              ),
              SizedBox(height: 2),
              const Title2(
                title: 'Dê uma nota para este local',
              ),
              SizedBox(height: 10),
              RatingBar.builder(
                initialRating: 0,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
                itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Color(0xFF007FFF),
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    _rating = rating;
                  });
                },
              ),
              SizedBox(height: 20),

              const Title1(
                title: 'Dificuldade',
              ),
              SizedBox(height: 2),
              const Title2(
                title: 'Qual foi o nível de dificuldade neste local?',
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pequena',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Color(0xFF263238),
                      ),
                    ),
                    Text(
                      'Grande',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Color(0xFF263238),
                      ),
                    ),
                  ],
                ),
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Color(0xFF007FFF),
                  inactiveTrackColor: Colors.lightBlue[100],
                  thumbColor: Color(0xFF007FFF),
                  overlayColor: Color(0xFF007FFF).withOpacity(0.2),
                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.0),
                  overlayShape: RoundSliderOverlayShape(overlayRadius: 28.0),
                  valueIndicatorTextStyle: TextStyle(
                    color: Colors.white,
                  ),
                  valueIndicatorColor: Color(0xFF007FFF),
                ),
                child: Slider(
                  value: _difficulty?.toDouble() ?? 1,
                  min: 1,
                  max: 5,
                  divisions: 4,
                  onChanged: (value) {
                    setState(() {
                      _difficulty = value.toInt();
                    });
                  },
                  label: '${_difficulty ?? 1}',
                ),
              ),
              SizedBox(height: 10),

              const Title1(
                title: 'Comentário',
              ),
              SizedBox(height: 2),
              const Title2(
                title: 'Anote as memórias do seu mergulho',
              ),
              TextField(
                controller: _notesController,
                maxLines: 6,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                  hintText: 'Insira sua avaliação aqui',
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
                ),
              ),
              SizedBox(height: 20),

              const Title1(
                title: 'Fotos',
              ),
              SizedBox(height: 2),
              const Title2(
                title: 'O que você viu durante seu mergulho?',
              ),
              SizedBox(height: 10),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _pickVideo,
                child: Text('Vídeos'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              SizedBox(height: 20),
_media.isNotEmpty
    ? GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: _media.length,
        itemBuilder: (context, index) {
  final media = _media[index];
  final isImage = media.contentType?.startsWith('image') ?? false;
  final imageData = media.data != null ? base64Decode(media.data!) : Uint8List(0);

  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      color: Colors.grey[200],
    ),
    child: isImage
        ? Image.memory(imageData, fit: BoxFit.cover)
        : Center(
            child: Icon(
              Icons.video_library,
              color: Colors.grey,
              size: 50,
            ),
          ),
  );
}
      )
    : Center(
        child: Text('Nenhuma mídia selecionada'),
      ),
SizedBox(height: 20),


              SizedBox(height: 20),

              // Botões
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _toGoBack,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Color(0xFF007FFF)),
                      padding:
                          EdgeInsets.symmetric(vertical: 22, horizontal: 30),
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
                      'ETAPA ANTERIOR',
                      style: TextStyle(
                        color: Color(0xFF007FFF),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF007FFF),
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
                      'REGISTRAR',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 10),
            ],
          ),
        ),
      ),
    );
  }
}
