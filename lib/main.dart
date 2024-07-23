import 'package:atlantida_mobile/controllers/user_controller.dart';
import 'package:atlantida_mobile/screens/first_screen.dart';
import 'package:atlantida_mobile/screens/home_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR');
  await dotenv.load(fileName: "../.env");
  runApp(const AtlantidaApp());
}

class AtlantidaApp extends StatelessWidget {
  const AtlantidaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder<bool>(
        future: checkToken(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || !snapshot.hasData || !snapshot.data!) {
            return const FirstScreen();
          } else {
            return const HomeScreen();
          }
        },
      ),
    );
  }

  Future<bool> checkToken() async {
    try {
      var response = await UserController().findUserByToken();
      // ignore: unnecessary_null_comparison
      return response != null;
    } catch (e) {
      return false;
    }
  }
}
