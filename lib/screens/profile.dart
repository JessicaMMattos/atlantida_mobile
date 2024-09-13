import 'package:atlantida_mobile/screens/about_us.dart';
import 'package:atlantida_mobile/screens/control.dart';
import 'package:atlantida_mobile/screens/terms_of_use.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:atlantida_mobile/controllers/address_controller.dart';
import 'package:atlantida_mobile/controllers/user_controller.dart';
import 'package:atlantida_mobile/components/custom_alert_dialog.dart';
import 'package:atlantida_mobile/components/lateral_menu.dart';
import 'package:atlantida_mobile/components/senha_field.dart';
import 'package:atlantida_mobile/components/text_field.dart';
import 'package:atlantida_mobile/components/top_bar.dart';
import 'package:atlantida_mobile/models/address_update.dart';
import 'package:atlantida_mobile/models/user.dart';
import 'package:atlantida_mobile/models/user_return.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserReturn? user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      var response = await UserController().findUserByToken();
      setState(() {
        user = response;
      });
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Erro ao acessar página de perfil, tente novamente mais tarde.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const LateralMenu(),
      backgroundColor: Colors.white,
      body: user == null
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Text(
                    '${user?.firstName} ${user?.lastName}',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Gerencie suas informações pessoais, preferências e configurações da conta.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ListTile(
                    leading:
                        const Icon(Icons.person_outline, color: Colors.black),
                    title: const Text('Minha conta'),
                    trailing: const Icon(Icons.arrow_forward_ios,
                        color: Colors.black),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AccountScreen(user: user!),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading:
                        const Icon(Icons.lock_outline, color: Colors.black),
                    title: const Text('Segurança'),
                    trailing: const Icon(Icons.arrow_forward_ios,
                        color: Colors.black),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SecurityScreen(user: user!),
                        ),
                      );
                    },
                  ),
                  const Spacer(),
                  ListTile(
                    leading: const Icon(Icons.description_outlined,
                        color: Colors.black),
                    title: const Text('Termos de uso'),
                    trailing: const Icon(Icons.arrow_forward_ios,
                        color: Colors.black),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TermsOfUseScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading:
                        const Icon(Icons.info_outline, color: Colors.black),
                    title: const Text('Sobre nós'),
                    trailing: const Icon(Icons.arrow_forward_ios,
                        color: Colors.black),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AboutUsScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.exit_to_app, color: Colors.red),
                    title: const Text(
                      'Sair da conta',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () async {
                      await UserController().logout(context);
                    },
                  ),
                ],
              ),
            ),
    );
  }
}

class AccountScreen extends StatefulWidget {
  final UserReturn user;

  const AccountScreen({super.key, required this.user});

  @override
  // ignore: library_private_types_in_public_api
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cepController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _complementController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  late String _addressId = '';

  String _nameErrorMessage = '';
  String _surnameErrorMessage = '';
  String _birthdateErrorMessage = '';

  String _cepErrorMessage = '';
  String _countryErrorMessage = '';
  String _stateErrorMessage = '';
  String _cityErrorMessage = '';
  String _districtErrorMessage = '';
  String _streetErrorMessage = '';
  String _numberErrorMessage = '';

  bool isLoading = true;
  bool _isProcessing = false;

  final cepMaskFormatter = MaskTextInputFormatter(
    mask: '#####-###',
    filter: {'#': RegExp(r'[0-9]')},
  );

  bool _isValidCep(String cep) {
    return RegExp(r'^\d{5}-\d{3}$').hasMatch(cep);
  }

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.user.firstName;
    _surnameController.text = widget.user.lastName;
    _birthdateController.text =
        formatDate(widget.user.birthDate); // Formatar data
    _emailController.text = widget.user.email;

    _loadAddress(widget.user.id);
  }

  String formatDate(String date) {
    try {
      DateTime parsedDate = DateTime.parse(date);
      return '${parsedDate.day.toString().padLeft(2, '0')}/${parsedDate.month.toString().padLeft(2, '0')}/${parsedDate.year}';
    } catch (e) {
      return date;
    }
  }

  Future<void> _loadAddress(String userId) async {
    try {
      setState(() {
        isLoading = true;
      });

      var address = await AddressController().getAddressByUserId(userId);
      setState(() {
        if (address?.id != null) {
          _addressId = address!.id!;
        }
        _cepController.text = address?.postalCode ?? '';
        _countryController.text = address?.country ?? '';
        _stateController.text = address?.state ?? '';
        _cityController.text = address?.city ?? '';
        _districtController.text = address?.neighborhood ?? '';
        _streetController.text = address?.street ?? '';
        _complementController.text = address?.complement ?? '';
        _numberController.text = address?.number.toString() ?? '';
      });
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Erro ao carregar endereço, tente novamente mais tarde.')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _userUpdate() async {
    try {
      setState(() {
        _isProcessing = true;
      });

      if (_validateFields()) {
        User userUpdate = User(
            firstName: _nameController.text,
            lastName: _surnameController.text,
            birthDate: _formatDateForSaving(_birthdateController.text),
            email: _emailController.text,
            id: widget.user.id,
            password: '');

        await UserController().updateUser(userUpdate);

        AddressUpdate addressUpdate = AddressUpdate(
            postalCode: _cepController.text,
            country: _countryController.text,
            state: _stateController.text,
            city: _cityController.text,
            neighborhood: _districtController.text,
            street: _streetController.text,
            complement: _complementController.text,
            number: int.parse(_numberController.text));

        await AddressController().updateAddress(_addressId, addressUpdate);

        showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return CustomAlertDialog(
              text: 'Perfil atualizado com sucesso!',
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MainNavigationScreen(index: 4),
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
            content: Text('Erro ao atualizar usuário, tente novamente.')),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  bool _validateFields() {
    final birthdateValidation = _validateBirthdate(_birthdateController.text);

    setState(() {
      _nameErrorMessage =
          _nameController.text.isEmpty ? 'Campo obrigatório.' : '';
      _surnameErrorMessage =
          _surnameController.text.isEmpty ? 'Campo obrigatório.' : '';
      _birthdateErrorMessage =
          birthdateValidation['format'] ?? birthdateValidation['age'] ?? '';
      _cepErrorMessage =
          _cepController.text.isEmpty ? 'Campo obrigatório.' : '';
      _countryErrorMessage =
          _countryController.text.isEmpty ? 'Campo obrigatório.' : '';
      _stateErrorMessage =
          _stateController.text.isEmpty ? 'Campo obrigatório.' : '';
      _cityErrorMessage =
          _cityController.text.isEmpty ? 'Campo obrigatório.' : '';
      _districtErrorMessage =
          _districtController.text.isEmpty ? 'Campo obrigatório.' : '';
      _streetErrorMessage =
          _streetController.text.isEmpty ? 'Campo obrigatório.' : '';
      _numberErrorMessage =
          _numberController.text.isEmpty ? 'Campo obrigatório.' : '';
    });

    if (_nameErrorMessage.isNotEmpty ||
        _surnameErrorMessage.isNotEmpty ||
        _birthdateErrorMessage.isNotEmpty ||
        _cepErrorMessage.isNotEmpty ||
        _countryErrorMessage.isNotEmpty ||
        _stateErrorMessage.isNotEmpty ||
        _cityErrorMessage.isNotEmpty ||
        _districtErrorMessage.isNotEmpty ||
        _streetErrorMessage.isNotEmpty ||
        _numberErrorMessage.isNotEmpty) {
      return false;
    }

    final birthdateErrors = _validateBirthdate(_birthdateController.text);
    if (birthdateErrors.isNotEmpty) {
      return false;
    }

    return true;
  }

  Map<String, String> _validateBirthdate(String birthdate) {
    final Map<String, String> errors = {};

    if (birthdate.isEmpty) {
      errors['empty'] = 'Data de nascimento é obrigatória.';
      return errors;
    }

    try {
      final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
      final DateTime parsedDate = dateFormat.parseStrict(birthdate);

      if (parsedDate.isAfter(DateTime.now())) {
        errors['future'] = 'Data de nascimento não pode ser no futuro.';
      }

      final DateTime tenYearsAgo =
          DateTime.now().subtract(const Duration(days: 365 * 10));
      if (parsedDate.isAfter(tenYearsAgo)) {
        errors['age'] = 'Usuário deve ter no mínimo 10 anos de idade.';
      }
    } catch (e) {
      errors['invalid'] =
          'Data de nascimento inválida. Use o formato dd/MM/yyyy.';
    }

    return errors;
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

  void _toGoBack() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => const MainNavigationScreen(index: 4)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: TopBar(
        haveReturn: true,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const MainNavigationScreen(index: 4)),
          );
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dados pessoais',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Color(0xFF263238),
              ),
            ),
            const SizedBox(height: 20),

            // Campo de nome
            CustomTextField(
              label: 'Nome',
              description: 'Digite seu nome',
              controller: _nameController,
              errorMessage: _nameErrorMessage,
              isRequired: true,
            ),
            const SizedBox(height: 20),

            // Campo de sobrenome
            CustomTextField(
              label: 'Sobrenome',
              description: 'Digite seu sobrenome',
              controller: _surnameController,
              errorMessage: _surnameErrorMessage,
              isRequired: true,
            ),
            const SizedBox(height: 20),

            // Campo de data de nascimento
            const Text(
              'Data de Nascimento',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color(0xFF263238),
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _birthdateController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                createDateMaskFormatter(),
                LengthLimitingTextInputFormatter(10),
              ],
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _birthdateErrorMessage.isNotEmpty
                        ? Colors.red
                        : Colors.grey,
                  ),
                ),
                hintText: 'dd/mm/aaaa',
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _birthdateErrorMessage.isNotEmpty
                        ? Colors.red
                        : Colors.grey,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _birthdateErrorMessage.isNotEmpty
                        ? Colors.red
                        : const Color(0xFF263238),
                  ),
                ),
              ),
            ),

            if (_birthdateErrorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Text(
                  _birthdateErrorMessage,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            const SizedBox(height: 20),

            // Campo de e-mail
            const Text(
              'Email',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color(0xFF263238),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey,
                  ),
                ),
                hintText: 'Email',
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
              enabled: false,
            ),

            const SizedBox(height: 20),
            const Text(
              'Endereço',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Color(0xFF263238),
              ),
            ),
            const SizedBox(height: 20),

            // Campo de CEP
            const Text(
              'CEP',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color(0xFF263238),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _cepController,
              inputFormatters: [
                cepMaskFormatter,
                LengthLimitingTextInputFormatter(9),
              ],
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color:
                        _cepErrorMessage.isNotEmpty ? Colors.red : Colors.grey,
                  ),
                ),
                hintText: '00000-000',
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color:
                        _cepErrorMessage.isNotEmpty ? Colors.red : Colors.grey,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _cepErrorMessage.isNotEmpty
                        ? Colors.red
                        : const Color(0xFF263238),
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
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            const SizedBox(height: 20),

            // Campo de País
            CustomTextField(
              label: 'País',
              controller: _countryController,
              description: 'Digite seu país',
              isRequired: true,
              errorMessage: _countryErrorMessage,
            ),
            const SizedBox(height: 20),

            // Campo de Estado
            CustomTextField(
              label: 'Estado',
              controller: _stateController,
              description: 'Digite seu estado',
              isRequired: true,
              errorMessage: _stateErrorMessage,
            ),
            const SizedBox(height: 20),

            // Campo de Cidade
            CustomTextField(
              label: 'Cidade',
              controller: _cityController,
              description: 'Digite sua cidade',
              isRequired: true,
              errorMessage: _cityErrorMessage,
            ),
            const SizedBox(height: 20),

            // Campo de Bairro
            CustomTextField(
              label: 'Bairro',
              controller: _districtController,
              description: 'Digite seu bairro',
              isRequired: true,
              errorMessage: _districtErrorMessage,
            ),
            const SizedBox(height: 20),

            // Campo de Rua
            CustomTextField(
              label: 'Rua',
              controller: _streetController,
              description: 'Digite seu endereço',
              isRequired: true,
              errorMessage: _streetErrorMessage,
            ),
            const SizedBox(height: 20),

            // Campo de Complemento
            CustomTextFieldOptional(
              label: 'Complemento',
              controller: _complementController,
              description: 'Apartamento, sala, conjunto, andar',
            ),
            const SizedBox(height: 20),

            // Campo de Número
            const Text(
              'Número',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color(0xFF263238),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _numberController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _numberErrorMessage.isNotEmpty
                        ? Colors.red
                        : Colors.grey,
                  ),
                ),
                hintText: 'Digite o número do endereço',
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _numberErrorMessage.isNotEmpty
                        ? Colors.red
                        : Colors.grey,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _numberErrorMessage.isNotEmpty
                        ? Colors.red
                        : const Color(0xFF263238),
                  ),
                ),
              ),
            ),
            if (_numberErrorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Text(
                  _numberErrorMessage,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: screenWidth * 0.4,
                  child: ElevatedButton(
                    onPressed: _toGoBack,
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
                    onPressed: _isProcessing ? null : _userUpdate,
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
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.blue),
                          )
                        : const Text(
                            'SALVAR',
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
    );
  }

  void _searchCep() async {
    if (_isValidCep(_cepController.text)) {
      final response = await http.get(
          Uri.parse('https://viacep.com.br/ws/${_cepController.text}/json/'));
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
}

class SecurityScreen extends StatefulWidget {
  final UserReturn user;

  const SecurityScreen({super.key, required this.user});

  @override
  // ignore: library_private_types_in_public_api
  _SecurityScreenState createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  String _oldPasswordError = '';
  String _newPasswordError = '';
  String _confirmPasswordError = '';
  bool _isProcessing = false;
  bool _isObscure1 = true;

  void _passwordUpdate() async {
    try {
      setState(() {
        _isProcessing = true;
        _oldPasswordError =
            _oldPasswordController.text.isEmpty ? 'Campo obrigatório.' : '';
        _newPasswordError =
            _newPasswordController.text.isEmpty ? 'Campo obrigatório.' : _newPasswordError;
        _confirmPasswordError =
            _confirmPasswordController.text.isEmpty ? 'Campo obrigatório.' : '';

        if (_newPasswordController.text != _confirmPasswordController.text) {
          _confirmPasswordError = 'Senhas não coincidem.';
        }
      });

      if (_oldPasswordError.isEmpty &&
          _newPasswordError.isEmpty &&
          _confirmPasswordError.isEmpty) {
        var responseBody = await UserController().updatePassword(
            _oldPasswordController.text, _newPasswordController.text);

        if (responseBody == "Senha atual incorreta") {
          _oldPasswordError = 'Senha Incorreta.';
        } else if (responseBody == "ok") {
          showDialog(
            // ignore: use_build_context_synchronously
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return CustomAlertDialog(
                text: 'Senha atualizada com sucesso!',
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const MainNavigationScreen(index: 4)),
                  );
                },
              );
            },
          );
        } else {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Erro ao atualizar senha, tente novamente.')),
          );
        }
      }
    } catch (error) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Erro ao atualizar senha, tente novamente.')),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _resetForm() {
    setState(() {
      _oldPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

      _oldPasswordError = '';
      _newPasswordError = '';
      _confirmPasswordError = '';
    });
  }

  void _deleteAccount() {
    TextEditingController passwordController = TextEditingController();
    String userEmail = widget.user.email;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${widget.user.firstName} ${widget.user.lastName}',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF263238),
                ),
              ),
              Text(
                userEmail,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: Color(0xFF263238),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Confirme que essa conta é sua!',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF263238),
                ),
              ),
              const Text(
                'Antes de excluir permanentemente a sua conta, insira sua senha.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: Color(0xFF263238),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                  hintText: 'Informe sua senha',
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
            ],
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
                Navigator.of(context).pop();
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
                bool isPasswordCorrect = await _verifyPassword(
                    widget.user.email, passwordController.text);

                if (isPasswordCorrect) {
                  await _deleteUserAccount();
                } else {
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Senha incorreta. Tente novamente.'),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> _verifyPassword(String email, String password) async {
    try {
      var response = await UserController().loginUser(context, email, password);

      if (response.statusCode == 200) {
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> _deleteUserAccount() async {
    try {
      await UserController().deleteUser(context);
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao deletar conta. Por favor, Tente novamente.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: TopBar(
        haveReturn: true,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const MainNavigationScreen(index: 4)),
          );
        },
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Alterar senha',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Color(0xFF263238),
                ),
              ),
              const SizedBox(height: 20),
              SenhaTextField(
                label: 'Senha Atual',
                controller: _oldPasswordController,
                description: 'Digite sua senha',
                errorMessage: _oldPasswordError,
              ),
              const SizedBox(height: 20),
              const Text(
                'Nova Senha',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF263238),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _newPasswordController,
                obscureText: _isObscure1,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _newPasswordError.isNotEmpty
                          ? Colors.red
                          : Colors.grey,
                    ),
                  ),
                  hintText: 'Informe sua nova senha',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _newPasswordError.isNotEmpty
                          ? Colors.red
                          : Colors.grey,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _newPasswordError.isNotEmpty
                          ? Colors.red
                          : const Color(0xFF263238),
                    ),
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _isObscure1 = !_isObscure1;
                      });
                    },
                    icon: Icon(
                      _isObscure1 ? Icons.visibility_off : Icons.visibility,
                    ),
                  ),
                ),
                onChanged: (value) {
                  String errorMessage = '';

                  if (value.length < 8) {
                    errorMessage += '\n• Mínimo 8 caracteres.';
                  }
                  if (!RegExp(r'[A-Z]').hasMatch(value)) {
                    errorMessage += '\n• Pelo menos 1 letra maiúscula.';
                  }
                  if (!RegExp(r'[0-9]').hasMatch(value)) {
                    errorMessage += '\n• Pelo menos 1 número.';
                  }

                  setState(() {
                    _newPasswordError = errorMessage.isEmpty
                        ? ''
                        : 'A senha deve conter:$errorMessage';
                  });
                },
              ),
              if (_newPasswordError.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: Text(
                    _newPasswordError,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              SenhaTextField(
                label: 'Confirmar Senha',
                controller: _confirmPasswordController,
                description: 'Repita a nova senha',
                errorMessage: _confirmPasswordError,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: screenWidth * 0.4,
                    child: ElevatedButton(
                      onPressed: _resetForm,
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
                      onPressed: _isProcessing ? null : _passwordUpdate,
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
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.blue),
                            )
                          : const Text(
                              'SALVAR',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Encerrar minha conta',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF263238),
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.center,
                child: FractionallySizedBox(
                  widthFactor: 0.8,
                  child: ElevatedButton.icon(
                    onPressed: _deleteAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade100,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    label: const Text(
                      'Deletar conta',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
