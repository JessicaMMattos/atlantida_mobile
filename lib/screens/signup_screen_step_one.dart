import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:atlantida_mobile/screens/signup_screen_step_two.dart';
import 'package:atlantida_mobile/controllers/user_controller.dart';
import 'package:atlantida_mobile/components/text_field.dart';
import 'package:atlantida_mobile/screens/login_screen.dart';
import 'package:atlantida_mobile/components/top_bar.dart';
import 'package:atlantida_mobile/components/button.dart';
import 'package:atlantida_mobile/models/user.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SignupScreenStepOne extends StatefulWidget {
  final User? newUser;

  const SignupScreenStepOne({super.key, this.newUser});

  @override
  _SignupScreenStepOneState createState() => _SignupScreenStepOneState();
}

class _SignupScreenStepOneState extends State<SignupScreenStepOne> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String _nameErrorMessage = '';
  String _surnameErrorMessage = '';
  String _birthdateErrorMessage = '';
  String _birthdate = '';
  String _emailErrorMessage = '';
  String _passwordErrorMessage = '';
  String _confirmPasswordErrorMessage = '';
  bool _isObscure1 = true;
  bool _isObscure2 = true;

    final birthdateMaskFormatter = MaskTextInputFormatter(
    mask: '##/##/####',
    filter: {'#': RegExp(r'[0-9]')},
  );

  @override
  void initState() {
    super.initState();
    if (widget.newUser != null) {
      _nameController.text = widget.newUser!.firstName;
      _surnameController.text = widget.newUser!.lastName;
      _birthdateController.text = DateFormat('dd/MM/yyyy').format(DateTime.parse(widget.newUser!.birthDate));
      _emailController.text = widget.newUser!.email;
      _passwordController.text = widget.newUser!.password;
      _confirmPasswordController.text = widget.newUser!.password;
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  Map<String, String> _validateBirthdate(String birthdate) {
    final Map<String, String> errors = {};

    try {
      if (birthdate.isEmpty) {
        errors['format'] = 'Campo obrigatório.';
        return errors;
      }

      final parts = birthdate.split('/');
      if (parts.length != 3) {
        errors['format'] = 'Data de nascimento inválida (formato DD/MM/AAAA).';
      } else {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);

        if (month < 1 || month > 12) {
          errors['format'] = 'Data de nascimento inválida (formato DD/MM/AAAA).';
        } else {
          final daysInMonth = _daysInMonth(month, year);
          if (day < 1 || day > daysInMonth) {
            errors['format'] = 'Data de nascimento inválida (formato DD/MM/AAAA).';
          } else {
            final currentDate = DateTime.now();
            final minAgeDate = DateTime(currentDate.year - 10, currentDate.month, currentDate.day);
            final birthDate = DateTime(year, month, day);
            if (birthDate.isAfter(minAgeDate)) {
              errors['age'] = 'Usuário deve ter no mínimo 10 anos de idade.';
            }
            _birthdate = DateFormat('yyyy-MM-dd').format(birthDate);
          }
        }
      }
    } catch (e) {
      errors['format'] = 'Data de nascimento inválida (formato DD/MM/AAAA).';
    }

    return errors;
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

  void _signupUser() async {
    final birthdateValidation = _validateBirthdate(_birthdateController.text);
    
    setState(() {
      _nameErrorMessage = _nameController.text.isEmpty ? 'Campo obrigatório.' : '';
      _surnameErrorMessage = _surnameController.text.isEmpty ? 'Campo obrigatório.' : '';
      _birthdateErrorMessage = birthdateValidation['format'] ?? birthdateValidation['age'] ?? '';
      _emailErrorMessage = _emailController.text.isEmpty
          ? 'Campo obrigatório.'
          : !_isValidEmail(_emailController.text)
              ? 'E-mail inválido.'
              : '';
      _passwordErrorMessage = _passwordController.text.isEmpty ? 'Campo obrigatório.' : '';
      _confirmPasswordErrorMessage = _confirmPasswordController.text.isEmpty ? 'Campo obrigatório.' : '';
      
      if (_passwordController.text != _confirmPasswordController.text) {
        _confirmPasswordErrorMessage = 'Senhas não coincidem.';
      }
    });

    if (_nameErrorMessage.isEmpty &&
        _surnameErrorMessage.isEmpty &&
        _birthdateErrorMessage.isEmpty &&
        _emailErrorMessage.isEmpty &&
        _passwordErrorMessage.isEmpty &&
        _confirmPasswordErrorMessage.isEmpty) {
      
      try {
        final emailExists = await UserController().findUserByEmail(context, _emailController.text);

        if (emailExists) {
          setState(() {
            _emailErrorMessage = 'O e-mail informado já está em uso.';
          });
        } else {
          User newUser = User(
            firstName: _nameController.text,
            lastName: _surnameController.text,
            email: _emailController.text,
            password: _passwordController.text,
            birthDate: _birthdate,
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SignupScreenStepTwo(newUser: newUser)),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro na primeira etapa do cadastro, tente novamente.')),
        );
      }
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
            MaterialPageRoute(builder: (context) => LoginScreen()),
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
                    'Dados pessoais',
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
                        color: Color(0xFFF2F2F2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text(
                'Etapa 1 de 2',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  color: Color(0xFF777777),
                ),
              ),
              SizedBox(height: 30),

              // Campo de nome
              CustomTextField(
                label: 'Nome',
                description: 'Digite seu nome',
                controller: _nameController,
                errorMessage: _nameErrorMessage,
                isRequired: true,
              ),
              SizedBox(height: 20),

              // Campo de sobrenome
              CustomTextField(
                label: 'Sobrenome',
                description: 'Digite seu sobrenome',
                controller: _surnameController,
                errorMessage: _surnameErrorMessage,
                isRequired: true,
              ),
              SizedBox(height: 20),

               // Campo de data de nascimento
              Text(
                'Data de Nascimento',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF263238),
                ),
              ),
              SizedBox(height: 10),

              TextField(
                controller: _birthdateController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  birthdateMaskFormatter,
                  LengthLimitingTextInputFormatter(10),
                ],
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _birthdateErrorMessage.isNotEmpty ? Colors.red : Colors.grey,
                    ),
                  ),
                  hintText: 'dd/mm/aaaa',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _birthdateErrorMessage.isNotEmpty ? Colors.red : Colors.grey,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _birthdateErrorMessage.isNotEmpty ? Colors.red : Color(0xFF263238),
                    ),
                  ),
                ),
              ),

              if (_birthdateErrorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: Text(
                    _birthdateErrorMessage,
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              SizedBox(height: 20),

              // Campo de e-mail
              CustomTextField(
                label: 'E-mail',
                description: 'Digite seu e-mail',
                controller: _emailController,
                errorMessage: _emailErrorMessage,
                isRequired: true,
              ),
              SizedBox(height: 20),

              // Campo de senha
              Text(
                'Senha',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF263238),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                obscureText: _isObscure1,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _passwordErrorMessage.isNotEmpty ? Colors.red : Colors.grey,
                    ),
                  ),
                  hintText: 'Digite sua senha',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _passwordErrorMessage.isNotEmpty ? Colors.red : Colors.grey,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _passwordErrorMessage.isNotEmpty ? Colors.red : Color(0xFF263238),
                    ),
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _isObscure1 = !_isObscure1;
                      });
                    },
                    icon: Icon(
                      _isObscure1
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                  ),
                ),
              ),
              if (_passwordErrorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: Text(
                    _passwordErrorMessage,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ),
              SizedBox(height: 20),

              // Campo de confirmação de senha
              Text(
                'Confirme sua senha',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF263238),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _confirmPasswordController,
                obscureText: _isObscure2,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _confirmPasswordErrorMessage.isNotEmpty ? Colors.red : Colors.grey,
                    ),
                  ),
                  hintText: 'Digite sua senha novamente',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _confirmPasswordErrorMessage.isNotEmpty ? Colors.red : Colors.grey,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _confirmPasswordErrorMessage.isNotEmpty ? Colors.red : Color(0xFF263238),
                    ),
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _isObscure2 = !_isObscure2;
                      });
                    },
                    icon: Icon(
                      _isObscure2
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                  ),
                ),
              ),
              if (_confirmPasswordErrorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: Text(
                    _confirmPasswordErrorMessage,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ),
              SizedBox(height: 20),

              Container(
                width: MediaQuery.of(context).size.width - 40,
                child: Button(
                  titleButton: 'CONTINUAR',
                  onPressed: _signupUser,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
