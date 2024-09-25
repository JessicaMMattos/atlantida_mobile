import 'package:atlantida_mobile/components/custom_alert_dialog.dart';
import 'package:atlantida_mobile/components/custom_error_message.dart';
import 'package:atlantida_mobile/controllers/user_controller.dart';
import 'package:atlantida_mobile/components/top_bar.dart';
import 'package:atlantida_mobile/components/button.dart';
import 'package:atlantida_mobile/screens/login.dart';
import 'package:flutter/material.dart';

class RedefinePasswordScreen extends StatefulWidget {
  const RedefinePasswordScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RedefinePasswordScreenState createState() => _RedefinePasswordScreenState();
}

class _RedefinePasswordScreenState extends State<RedefinePasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  String _message = '';
  bool _isLoading = false;
  OverlayEntry? _errorOverlay;

  void _showErrorMessage(String message) {
    _errorOverlay?.remove();
    _errorOverlay = OverlayEntry(
      builder: (context) => CustomErrorMessage(
        message: message,
        onDismiss: () {
          _errorOverlay?.remove();
          _errorOverlay = null;
        },
      ),
    );
    Overlay.of(context).insert(_errorOverlay!);

    Future.delayed(const Duration(seconds: 4), () {
      _errorOverlay?.remove();
      _errorOverlay = null;
    });
  }

  void _resetPassword() async {
    try {
      setState(() {
        _isLoading = true;
      });

      String email = _emailController.text;

      if (email.isEmpty) {
        setState(() {
          _message = "Campo obrigatório.";
        });
        return;
      }

      var response = await UserController().recoverPassword(context, email);

      setState(() {
        _message = response;
      });

      if (_message == 'Senha redefinida com sucesso') {
        _showSuccessDialog();
      }
    } catch (error) {
      _showErrorMessage('Ocorreu um erro inesperado. Tente novamente.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CustomAlertWithDescriptionDialog(
          title: 'Senha redefinida com sucesso',
          description:
              'Por favor, verifique sua caixa de entrada e spam para encontrar a nova senha.',
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final topSpaceHeight = screenHeight * 0.15;

    return MaterialApp(
      home: Scaffold(
        appBar: TopBar(
          haveReturn: true,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  SizedBox(height: topSpaceHeight),
                  Expanded(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFFCCCCCC),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25),
                          topRight: Radius.circular(25),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Redefinição de senha',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                color: Color(0xFF263238),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Digite seu e-mail para receber sua nova senha diretamente na sua caixa de entrada ou na pasta de spam.',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                                color: Color(0xFF263238),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Campo de e-mail
                            SizedBox(
                              width: MediaQuery.of(context).size.width - 40,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'E-mail',
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
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: _message == "Campo obrigatório." || _message == "Usuário não encontrado."
                                              ? Colors.red
                                              : Colors.grey,
                                        ),
                                      ),
                                      hintText: 'Digite seu e-mail',
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: _message == "Campo obrigatório." || _message == "Usuário não encontrado."
                                              ? Colors.red
                                              : Colors.grey,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: _message == "Campo obrigatório." || _message == "Usuário não encontrado."
                                              ? Colors.red
                                              : const Color(0xFF263238),
                                        ),
                                      ),
                                      errorText:
                                        _message == "Usuário não encontrado." ||
                                            _message == "Campo obrigatório."
                                        ? _message
                                        : null,
                                      errorBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(color: Colors.red),
                                        borderRadius: BorderRadius.circular(4.0),
                                      ),
                                      errorStyle: const TextStyle(color: Colors.red),
                                      errorMaxLines: 2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Botão de redefinir senha
                            SizedBox(
                              width: MediaQuery.of(context).size.width - 40,
                              child: Button(
                                titleButton:
                                    _isLoading ? 'CARREGANDO...' : 'REDEFINIR SENHA',
                                onPressed: _isLoading ? () {} : _resetPassword,
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
