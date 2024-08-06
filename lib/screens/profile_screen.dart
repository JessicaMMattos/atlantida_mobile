import 'package:atlantida_mobile/components/lateral_menu.dart';
import 'package:atlantida_mobile/components/navigation_bar.dart';
import 'package:atlantida_mobile/controllers/address_controller.dart';
import 'package:atlantida_mobile/controllers/user_controller.dart';
import 'package:atlantida_mobile/models/address.dart';
import 'package:atlantida_mobile/models/address_update.dart';
import 'package:atlantida_mobile/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? user;

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao acessar página de perfil, tente novamente mais tarde.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      drawer: LateralMenuDrawer(),
      bottomNavigationBar: const NavBar(index: 4),
      backgroundColor: Colors.white,
      body: user == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${user?.firstName} ${user?.lastName}',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Gerencie suas informações pessoais, preferências e configurações da conta.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 24),
                  ListTile(
                    leading: Icon(Icons.person_outline, color: Colors.black),
                    title: Text('Minha conta'),
                    trailing: Icon(Icons.arrow_forward_ios, color: Colors.black),
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
                    leading: Icon(Icons.lock_outline, color: Colors.black),
                    title: Text('Segurança'),
                    trailing: Icon(Icons.arrow_forward_ios, color: Colors.black),
                    onTap: () {
                      // Navegar para a página de Segurança
                    },
                  ),
                  Spacer(),
                  ListTile(
                    leading: Icon(Icons.exit_to_app, color: Colors.red),
                    title: Text(
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
  final User user;

  const AccountScreen({super.key, required this.user});

  @override
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

  final cepMaskFormatter = MaskTextInputFormatter(
    mask: '#####-###',
    filter: {'#': RegExp(r'[0-9]')},
  );

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.user.firstName;
    _surnameController.text = widget.user.lastName;
    _birthdateController.text = formatDate(widget.user.birthDate); // Formatar data
    _emailController.text = widget.user.email;
    if (widget.user.id != null) {
      _loadAddress(widget.user.id!);
    }
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
        _numberController.text = address?.number?.toString() ?? '';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar endereço, tente novamente mais tarde.')),
      );
    }
  }

  void _userUpdate() async {
    try {
      if (_validateFields()) {
        User userUpdate = User(
          firstName: _nameController.text,
          lastName: _surnameController.text,
          birthDate: _formatDateForSaving(_birthdateController.text),
          email: _emailController.text,
          id: widget.user.id,
          password: ''
        );

        await UserController().updateUser(userUpdate);

        AddressUpdate addressUpdate = AddressUpdate(
          postalCode: _cepController.text,
          country: _countryController.text,
          state: _stateController.text,
          city: _cityController.text,
          neighborhood: _districtController.text,
          street: _streetController.text,
          complement: _complementController.text,
          number: int.parse(_numberController.text)
        );

        await AddressController().updateAddress(_addressId, addressUpdate);

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Row(
                children: [
                  Icon(Icons.check_circle, color: Color(0xFF007FFF)),
                  SizedBox(width: 10),
                  Text('Perfil atualizado com sucesso!'),
                ],
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
                      MaterialPageRoute(builder: (context) => ProfileScreen()),
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
        SnackBar(content: Text('Erro ao atualizar usuário, tente novamente.')),
      );
    }
  }

  bool _validateFields() {
    if (_nameController.text.isEmpty ||
        _surnameController.text.isEmpty ||
        _birthdateController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _cepController.text.isEmpty ||
        _countryController.text.isEmpty ||
        _stateController.text.isEmpty ||
        _cityController.text.isEmpty ||
        _districtController.text.isEmpty ||
        _streetController.text.isEmpty ||
        _numberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Preencha todos os campos obrigatórios.')),
      );
      return false;
    }

    final birthdateErrors = _validateBirthdate(_birthdateController.text);
    if (birthdateErrors.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(birthdateErrors.values.join(' '))),
      );
      return false;
    }

    return true;
  }

  Map<String, String> _validateBirthdate(String birthdate) {
    final Map<String, String> errors = {};

    try {
      if (birthdate.isEmpty) {
        errors['format'] = 'Campo obrigatório.';
        return errors;
      }

      final date = DateFormat('dd/MM/yyyy').parseStrict(birthdate);
      if (date.isAfter(DateTime.now())) {
        errors['future'] = 'Data de nascimento não pode ser no futuro.';
      }
    } catch (e) {
      errors['format'] = 'Formato de data inválido. Use dd/MM/yyyy.';
    }

    return errors;
  }

  String _formatDateForSaving(String date) {
    try {
      DateTime parsedDate = DateFormat('dd/MM/yyyy').parse(date);
      return DateFormat('yyyy-MM-dd').format(parsedDate);
    } catch (e) {
      return date;
    }
  }

  Future<void> _fetchAddress(String cep) async {
    try {
      final response = await http.get(Uri.parse('https://viacep.com.br/ws/$cep/json/'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          _countryController.text = 'Brasil';
          _stateController.text = data['uf'] ?? '';
          _cityController.text = data['localidade'] ?? '';
          _districtController.text = data['bairro'] ?? '';
          _streetController.text = data['logradouro'] ?? '';
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('CEP não encontrado.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao buscar CEP.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Minha Conta', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildTextField('Nome', _nameController),
            _buildTextField('Sobrenome', _surnameController),
            _buildDateField('Data de Nascimento', _birthdateController),
            _buildTextField('E-mail', _emailController, enabled: false),
            _buildCepField('CEP', _cepController),
            _buildTextField('País', _countryController),
            _buildTextField('Estado', _stateController),
            _buildTextField('Cidade', _cityController),
            _buildTextField('Bairro', _districtController),
            _buildTextField('Rua', _streetController),
            _buildTextField('Complemento', _complementController),
            _buildTextField('Número', _numberController, inputType: TextInputType.number),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('CANCELAR'),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _userUpdate,
                    child: Text('SALVAR'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType inputType = TextInputType.text,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: inputType,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.datetime,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(8),
          MaskTextInputFormatter(mask: '##/##/####'),
        ],
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildCepField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [cepMaskFormatter],
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        onChanged: (value) {
          if (value.length == 9) {
            _fetchAddress(value.replaceAll('-', ''));
          }
        },
      ),
    );
  }
}
