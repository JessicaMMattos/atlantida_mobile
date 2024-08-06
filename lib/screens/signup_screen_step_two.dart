import 'package:atlantida_mobile/screens/login_screen.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:atlantida_mobile/screens/signup_screen_step_one.dart';
import 'package:atlantida_mobile/controllers/address_controller.dart';
import 'package:atlantida_mobile/controllers/user_controller.dart';
import 'package:atlantida_mobile/components/text_field.dart';
import 'package:atlantida_mobile/components/top_bar.dart';
import 'package:atlantida_mobile/components/button.dart';
import 'package:atlantida_mobile/models/address.dart';
import 'package:atlantida_mobile/models/user.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignupScreenStepTwo extends StatefulWidget {
  final User newUser;

  SignupScreenStepTwo({required this.newUser});

  @override
  _SignupScreenStepTwoState createState() => _SignupScreenStepTwoState();
}

class _SignupScreenStepTwoState extends State<SignupScreenStepTwo> {
  final TextEditingController _cepController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _complementController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();

  String _cepErrorMessage = '';
  String _countryErrorMessage = '';
  String _stateErrorMessage = '';
  String _cityErrorMessage = '';
  String _districtErrorMessage = '';
  String _streetErrorMessage = '';
  String _numberErrorMessage = '';

  bool _isValidCep(String cep) {
    return RegExp(r'^\d{5}-\d{3}$').hasMatch(cep);
  }

  final cepMaskFormatter = MaskTextInputFormatter(
    mask: '#####-###',
    filter: {'#': RegExp(r'[0-9]')},
  );

  void _completeSignup() {
    setState(() async {
      try {
        _cepErrorMessage = _cepController.text.isEmpty || !_isValidCep(_cepController.text) ? 'Campo obrigatório.' : '';
        _countryErrorMessage = _countryController.text.isEmpty ? 'Campo obrigatório.' : '';
        _stateErrorMessage = _stateController.text.isEmpty ? 'Campo obrigatório.' : '';
        _cityErrorMessage = _cityController.text.isEmpty ? 'Campo obrigatório.' : '';
        _districtErrorMessage = _districtController.text.isEmpty ? 'Campo obrigatório.' : '';
        _streetErrorMessage = _streetController.text.isEmpty ? 'Campo obrigatório.' : '';
        _numberErrorMessage = _numberController.text.isEmpty ? 'Campo obrigatório.' : '';

        if (_cepErrorMessage.isEmpty &&
          _countryErrorMessage.isEmpty &&
          _stateErrorMessage.isEmpty &&
          _cityErrorMessage.isEmpty &&
          _districtErrorMessage.isEmpty &&
          _streetErrorMessage.isEmpty &&
          _numberErrorMessage.isEmpty) {

        var responseUser = await UserController().createUser(context, widget.newUser);
        var userId = json.decode(responseUser.body)['_id'];

          Address newAddress = Address(
            country: _countryController.text,
            state: _stateController.text,
            city: _cityController.text,
            neighborhood: _districtController.text,
            street: _streetController.text,
            number: int.parse(_numberController.text),
            complement: _complementController.text.isEmpty ? null : _complementController.text,
            postalCode: _cepController.text,
            userId: userId,
          );

          await AddressController().createAddress(context, newAddress);
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: Colors.white,
                title: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Color(0xFF007FFF)),
                    SizedBox(width: 10),
                    Text('Cadastro Realizado!'),
                  ],
                ),
                content: const Text(
                  'Seu cadastro foi realizado com sucesso. Por favor, faça o login para acessar o sistema.',
                  style: TextStyle(color: Color(0xFF263238)),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text(
                      'OK',
                      style: TextStyle(color: Color(0xFF007FFF)),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                  ),
                ],
              );
            },
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro no cadastro, tente novamente.')),
        );
      }
    });
  }

  void _searchCep() async {
    if (_isValidCep(_cepController.text)) {
      final response = await http.get(Uri.parse('https://viacep.com.br/ws/${_cepController.text}/json/'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _districtController.text = data['bairro'] ?? '';
          _cityController.text = data['localidade'] ?? '';
          _stateController.text = data['uf'] ?? '';
          _countryController.text = 'Brasil';
          _streetController.text = data['logradouro'] ?? '';
        });
      } else {
        setState(() {
          _cepErrorMessage = 'CEP não encontrado.';
        });
      }
    } else {
      setState(() {
        _cepErrorMessage = 'CEP inválido.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: TopBar(
        haveReturn: true,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SignupScreenStepOne(newUser: widget.newUser))
          );
        },
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              Text(
                'Crie sua conta',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Color(0xFF263238),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'O cadastro será realizado em duas etapas, preencha todos os campos atentamente.',
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
                    'Endereço',
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
                ],
              ),
              SizedBox(height: 10),
              Text(
                'Etapa 2 de 2',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  color: Color(0xFF777777),
                ),
              ),
              SizedBox(height: 30),

              // Campo de CEP
              Text(
                'CEP',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF263238),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _cepController,
                inputFormatters: [
                  cepMaskFormatter,
                  LengthLimitingTextInputFormatter(9),
                ],
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _cepErrorMessage.isNotEmpty ? Colors.red : Colors.grey,
                    ),
                  ),
                  hintText: '00000-000',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _cepErrorMessage.isNotEmpty ? Colors.red : Colors.grey,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _cepErrorMessage.isNotEmpty ? Colors.red : Color(0xFF263238),
                    ),
                  ),
                ),
                onChanged: (value) {
                  if (_isValidCep(value)) {
                    _searchCep();
                  }
                },
              ),
              if (_cepErrorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: Text(
                    _cepErrorMessage,
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              SizedBox(height: 20),

              // Campo de País
              CustomTextField(
                label: 'País',
                controller: _countryController,
                description: 'Digite seu país',
                isRequired: true,
                errorMessage: _countryErrorMessage,
              ),
              SizedBox(height: 20),

              // Campo de Estado
              CustomTextField(
                label: 'Estado',
                controller: _stateController,
                description: 'Digite seu estado',
                isRequired: true,
                errorMessage: _stateErrorMessage,
              ),
              SizedBox(height: 20),

              // Campo de Cidade
              CustomTextField(
                label: 'Cidade',
                controller: _cityController,
                description: 'Digite sua cidade',
                isRequired: true,
                errorMessage: _cityErrorMessage,
              ),
              SizedBox(height: 20),

              // Campo de Bairro
              CustomTextField(
                label: 'Bairro',
                controller: _districtController,
                description: 'Digite seu bairro',
                isRequired: true,
                errorMessage: _districtErrorMessage,
              ),
              SizedBox(height: 20),

              // Campo de Rua
              CustomTextField(
                label: 'Rua',
                controller: _streetController,
                description: 'Digite seu endereço',
                isRequired: true,
                errorMessage: _streetErrorMessage,
              ),
              SizedBox(height: 20),

              // Campo de Complemento
              CustomTextField(
                label: 'Complemento (opcional)',
                controller: _complementController,
                description: 'Apartamento, sala, conjunto, andar',
              ),
              SizedBox(height: 20),

              // Campo de Número
              Text(
                'Número',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF263238),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _numberController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _numberErrorMessage.isNotEmpty ? Colors.red : Colors.grey,
                    ),
                  ),
                  hintText: 'Digite o número do endereço',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _numberErrorMessage.isNotEmpty ? Colors.red : Colors.grey,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _numberErrorMessage.isNotEmpty ? Colors.red : Color(0xFF263238),
                    ),
                  ),
                ),
              ),
              if (_numberErrorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: Text(
                    _numberErrorMessage,
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              SizedBox(height: 40),

              Container(
                width: MediaQuery.of(context).size.width - 40,
                child: Button(
                  titleButton: 'CONTINUAR',
                  onPressed: _completeSignup,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
