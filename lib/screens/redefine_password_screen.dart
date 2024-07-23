import 'package:atlantida_mobile/controllers/user_controller.dart';
import 'package:atlantida_mobile/components/top_bar.dart';
import 'package:atlantida_mobile/components/button.dart';
import 'package:atlantida_mobile/screens/login_screen.dart';
import 'package:flutter/material.dart';

class RedefinePasswordScreen extends StatefulWidget {
  @override
  _RedefinePasswordScreenState createState() => _RedefinePasswordScreenState();
}

class _RedefinePasswordScreenState extends State<RedefinePasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  String _message = '';

  void _resetPassword() async {
    try {
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

      if (_message == 'Senha redefinida com sucesso.') {
        _showSuccessDialog();
      }

    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar email de recuperação.')),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('Senha redefinida com sucesso'),
          content: Text('Por favor, verifique sua caixa de entrada e spam para encontrar a nova senha.'),
          actions: <Widget>[
            TextButton(
              child: Text(
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

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return MaterialApp(
      home: Scaffold(
        appBar: TopBar(
          haveReturn: true,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          },
        ),
        body: Stack(
          children: [
            Container(
              color: Colors.white,
            ),
            Positioned(
              top: screenHeight * 0.15,
              child: Container(
                width: screenWidth,
                height: screenHeight * 0.75,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFE4E4E4),
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
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: screenHeight * 0.02),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Redefinição de senha',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.bold,
                          fontSize: screenHeight * 0.03,
                          color: Color(0xFF263238),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Text(
                        'Digite seu e-mail para receber sua nova senha diretamente na sua caixa de entrada ou na pasta de spam.',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: Color(0xFF263238),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Container(
                        width: screenWidth - 2 * (screenWidth * 0.05),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'E-mail',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Color(0xFF263238),
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            TextField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Digite seu e-mail',
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.black,
                                  ),
                                ),
                                errorText: _message == 'Usuário não encontrado.' || _message == "Campo obrigatório." ? _message : null,
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red),
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                errorStyle: TextStyle(color: Colors.red),
                                errorMaxLines: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Container(
                        width: screenWidth - 2 * (screenWidth * 0.05),
                        child: Button(
                          titleButton: 'REDEFINIR SENHA',
                          onPressed: _resetPassword,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
