import 'package:atlantida_mobile/controllers/user_controller.dart';
import 'package:atlantida_mobile/screens/control.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:atlantida_mobile/screens/first.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR');
  await dotenv.load(fileName: ".env");

  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const AtlantidaApp());
  });
}

class AtlantidaApp extends StatelessWidget {
  const AtlantidaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt'),
      ],
      home: FutureBuilder<bool>(
        future: checkToken(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              )
            );
          } else if (snapshot.hasError ||
              !snapshot.hasData ||
              !snapshot.data!) {
            return const FirstScreen();
          } else {
            return const MainNavigationScreen();
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
