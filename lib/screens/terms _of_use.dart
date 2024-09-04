import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class TermsOfUseScreen extends StatelessWidget {
  const TermsOfUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF007FFF),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Termos de Uso',
          style: TextStyle(
            color: Color(0xFF007FFF),
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: const [
          SizedBox(width: 48),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double horizontalPadding;
          double fontSize;
          double titleFontSize;

          if (constraints.maxWidth < 600) {
            horizontalPadding = 16.0;
            fontSize = 16.0;
            titleFontSize = 24.0;
          } else if (constraints.maxWidth < 1200) {
            horizontalPadding = 32.0;
            fontSize = 18.0;
            titleFontSize = 28.0;
          } else {
            horizontalPadding = 64.0;
            fontSize = 20.0;
            titleFontSize = 32.0;
          }

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: SvgPicture.asset(
                    'assets/icons/logo.svg',
                    height: 35,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 16.0),
                Center(
                  child: Text(
                    'Em vigor a partir de 30 de agosto de 2024',
                    style: TextStyle(
                      fontSize: fontSize - 2,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                Text(
                  'Termos de Uso',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                    fontSize: titleFontSize,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16.0),
                Text(
                  'Bem-vindo aos Termos de Uso do Sistema de Gerenciamento de Mergulho. Este documento estabelece os termos e condições que regem o uso da plataforma web e móvel desenvolvida para o planejamento e gerenciamento de experiências subaquáticas para mergulhadores. Ao utilizar nosso sistema, você concorda com estes termos e compromete-se a segui-los.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.normal,
                    fontSize: fontSize,
                    color: Colors.black,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16.0),
                Text(
                  '1. Introdução',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                    fontSize: titleFontSize - 6,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  '1.1 Tema de Pesquisa',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'O Sistema de Gerenciamento de Mergulho foi projetado para fornecer aos mergulhadores uma solução multiplataforma para organizar suas experiências subaquáticas. Nossa plataforma permite o armazenamento de informações fundamentais, análise de estatísticas de mergulhos e visualização de novos locais para mergulho.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.normal,
                    fontSize: fontSize,
                    color: Colors.black,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16.0),
                Text(
                  '1.2 Motivações e Justificativas',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Reconhecemos a necessidade de uma solução customizada para o gerenciamento eficiente de informações relacionadas ao mergulho. A falta de uma plataforma adequada resulta em perda de dados, dificuldades na identificação de padrões e tendências, e limitações na avaliação pessoal e comparação de experiências entre mergulhadores. Nosso sistema busca aprimorar a experiência dos mergulhadores, promovendo a conservação marinha e incentivando a prática responsável do mergulho.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.normal,
                    fontSize: fontSize,
                    color: Colors.black,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16.0),
                Text(
                  '1.3 Objetivos',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  '1.3.1 Objetivo Geral',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Desenvolver um sistema web e móvel destinado ao planejamento e gerenciamento de experiências subaquáticas para mergulhadores.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.normal,
                    fontSize: fontSize,
                    color: Colors.black,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16.0),
                Text(
                  '2. Cadastro de Usuário',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                    fontSize: titleFontSize - 6,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Ao utilizar nosso sistema, você concorda em fornecer informações precisas e atualizadas durante o processo de cadastro. As informações solicitadas incluem nome, sobrenome, data de nascimento, email, senha, CEP, país, estado, cidade, bairro, logradouro, número e complemento. Esses dados são essenciais para a criação e acesso à sua conta no sistema.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.normal,
                    fontSize: fontSize,
                    color: Colors.black,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16.0),
                Text(
                  '3. Privacidade e Segurança',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                    fontSize: titleFontSize - 6,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Nosso sistema respeita a privacidade dos usuários e adota medidas de segurança para proteger suas informações pessoais. Consulte nossa Política de Privacidade para obter mais detalhes sobre como coletamos, usamos e protegemos seus dados.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.normal,
                    fontSize: fontSize,
                    color: Colors.black,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16.0),
                Text(
                  '4. Uso Adequado do Sistema',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                    fontSize: titleFontSize - 6,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Ao utilizar nosso sistema, você concorda em respeitar as leis e regulamentos aplicáveis e em não usar a plataforma para atividades ilegais, fraudulentas, abusivas ou prejudiciais. Você também concorda em não interferir ou danificar o funcionamento do sistema.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.normal,
                    fontSize: fontSize,
                    color: Colors.black,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16.0),
                Text(
                  '5. Alterações nos Termos de Uso',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                    fontSize: titleFontSize - 6,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Reservamo-nos o direito de fazer alterações nestes Termos de Uso a qualquer momento. As alterações entrarão em vigor imediatamente após a publicação. Recomendamos que você revise periodicamente estes termos para estar ciente de quaisquer atualizações.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.normal,
                    fontSize: fontSize,
                    color: Colors.black,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16.0),
                Text(
                  '6. Encerramento da Conta',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                    fontSize: titleFontSize - 6,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Você pode encerrar sua conta a qualquer momento. O encerramento de sua conta não isenta você de cumprir todas as suas obrigações sob estes Termos de Uso até a data de encerramento. Reservamo-nos o direito de encerrar ou suspender sua conta a nosso critério, em caso de violação destes termos.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.normal,
                    fontSize: fontSize,
                    color: Colors.black,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16.0),
                Text(
                  '7. Contato',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                    fontSize: titleFontSize - 6,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8.0),
                RichText(
                  text: TextSpan(
                    text:
                        'Se você tiver dúvidas, preocupações ou comentários sobre estes Termos de Uso, entre em contato conosco através do nosso e-mail: ',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.normal,
                      fontSize: fontSize,
                      color: Colors.black,
                      height: 1.5,
                    ),
                    children: const [
                      TextSpan(
                        text: 'atlantidamergulhos@gmail.com',
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),
                Text(
                  'Ao utilizar nosso sistema, você concorda com estes Termos de Uso e compromete-se a segui-los.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.normal,
                    fontSize: fontSize,
                    color: Colors.black,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16.0),
                Center(
                  child: Text(
                    'Obrigado, Equipe Atlântida Mergulhos.',
                    style: TextStyle(
                      fontSize: fontSize,
                      color: Colors.black,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                Center(
                  child: Text(
                    'Data de efetivação: 05/08/2024',
                    style: TextStyle(
                      fontSize: fontSize,
                      color: const Color(0xFF666666),
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
