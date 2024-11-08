import 'package:atlantida_mobile/components/custom_error_message.dart';
import 'package:atlantida_mobile/controllers/user_controller.dart';
import 'package:atlantida_mobile/screens/control.dart';
import 'package:atlantida_mobile/screens/redefine_password.dart';
import 'package:atlantida_mobile/screens/signup_step_one.dart';
import 'package:atlantida_mobile/components/button.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _emailErrorMessage = '';
  String _passwordErrorMessage = '';
  String _loginErrorMessage = '';
  bool _isObscure = true;
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

  void _login() async {
    try {
      setState(() {
        _emailErrorMessage = '';
        _passwordErrorMessage = '';
        _loginErrorMessage = '';
        _isLoading = true;
      });

      String email = _emailController.text;
      String password = _passwordController.text;

      if (email.isEmpty) {
        setState(() {
          _emailErrorMessage = "Campo obrigatório.";
        });
      }
      if (password.isEmpty) {
        setState(() {
          _passwordErrorMessage = "Campo obrigatório.";
        });
      }
      if (_emailErrorMessage.isEmpty && _passwordErrorMessage.isEmpty) {
        var response =
            await UserController().loginUser(context, email, password);

        if (response.statusCode == 200) {
          Navigator.pushAndRemoveUntil(
            // ignore: use_build_context_synchronously
            context,
            MaterialPageRoute(
                builder: (context) => const MainNavigationScreen()),
            (Route<dynamic> route) => false,
          );
        } else {
          setState(() {
            _loginErrorMessage = 'E-mail e/ou senha incorretos.';
          });
        }
      }
    } catch (error) {
      // ignore: use_build_context_synchronously
      _showErrorMessage('Ocorreu um erro inesperado. Tente novamente.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final topSpaceHeight = screenHeight * 0.20;
    final topSpaceHeight1 = screenHeight * 0.05;

    return MaterialApp(
      home: Scaffold(
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
                  SvgPicture.asset(
                    'assets/icons/logo.svg',
                    height: 40,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: topSpaceHeight1),
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
                              'Faça seu login',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
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
                                          color: _emailErrorMessage
                                                      .isNotEmpty ||
                                                  _loginErrorMessage.isNotEmpty
                                              ? Colors.red
                                              : Colors.grey,
                                        ),
                                      ),
                                      hintText: 'Digite seu e-mail',
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: _emailErrorMessage
                                                      .isNotEmpty ||
                                                  _loginErrorMessage.isNotEmpty
                                              ? Colors.red
                                              : Colors.grey,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: _emailErrorMessage
                                                      .isNotEmpty ||
                                                  _loginErrorMessage.isNotEmpty
                                              ? Colors.red
                                              : const Color(0xFF263238),
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (_emailErrorMessage.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 5),
                                      child: Text(
                                        _emailErrorMessage,
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Campo de senha
                            SizedBox(
                              width: MediaQuery.of(context).size.width - 40,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Senha',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Color(0xFF263238),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const RedefinePasswordScreen()),
                                          );
                                        },
                                        child: const Text(
                                          'esqueceu a senha?',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14,
                                            color: Color(0xFF007FFF),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Stack(
                                    alignment: Alignment.centerRight,
                                    children: [
                                      TextField(
                                        controller: _passwordController,
                                        obscureText: _isObscure,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: _passwordErrorMessage
                                                          .isNotEmpty ||
                                                      _loginErrorMessage
                                                          .isNotEmpty
                                                  ? Colors.red
                                                  : Colors.grey,
                                            ),
                                          ),
                                          hintText: 'Digite sua senha',
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: _passwordErrorMessage
                                                          .isNotEmpty ||
                                                      _loginErrorMessage
                                                          .isNotEmpty
                                                  ? Colors.red
                                                  : Colors.grey,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: _passwordErrorMessage
                                                          .isNotEmpty ||
                                                      _loginErrorMessage
                                                          .isNotEmpty
                                                  ? Colors.red
                                                  : const Color(0xFF263238),
                                            ),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _isObscure = !_isObscure;
                                          });
                                        },
                                        icon: Icon(
                                          _isObscure
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (_passwordErrorMessage.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 5),
                                      child: Text(
                                        _passwordErrorMessage,
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (_loginErrorMessage.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Text(
                                  _loginErrorMessage,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 10),
                            
                            // Botão de login
                            SizedBox(
                              width: MediaQuery.of(context).size.width - 40,
                              child: Button(
                                titleButton:
                                    _isLoading ? 'CARREGANDO...' : 'LOGIN',
                                onPressed: _isLoading ? () {} : _login,
                              ),
                            ),
                            const SizedBox(height: 20),
                            
                            // Link para criar conta
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Não tem uma conta?',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const SignupScreenStepOne()),
                                    );
                                  },
                                  child: const Text(
                                    'Criar conta',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                      color: Color(0xFF007FFF),
                                      decoration: TextDecoration.underline,
                                      decorationColor: Color(0xFF007FFF),
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
