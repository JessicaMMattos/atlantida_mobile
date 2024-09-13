import 'package:atlantida_mobile/screens/register_dive_log.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:atlantida_mobile/controllers/dive_log_controller.dart';
import 'package:atlantida_mobile/controllers/user_controller.dart';
import 'package:atlantida_mobile/services/dive_log_service.dart';
import 'package:atlantida_mobile/services/weather_service.dart';
import 'package:atlantida_mobile/screens/details_dive_log.dart';
import 'package:atlantida_mobile/components/lateral_menu.dart';
import 'package:atlantida_mobile/models/dive_log_return.dart';
import 'package:atlantida_mobile/services/maps_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:atlantida_mobile/models/user_return.dart';
import 'package:atlantida_mobile/screens/login.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = true;
  UserReturn? user;
  Map<String, dynamic> weatherForecast = {};
  Map<String, dynamic> locationData = {};
  List<DiveLogReturn> diveLogs = [];
  List<DiveLogReturn> filteredDiveLogs = [];
  String searchQuery = '';
  DateTime? _lastCacheDate;
  int currentPage = 0;
  int itemsPerPage = 5;
  String filterCriterion = 'Título';

  @override
  void initState() {
    super.initState();
    _loadUserAndWeather();
  }

  Future<void> _loadUserAndWeather() async {
    try {
      var response = await UserController().findUserByToken();

      Position position = await _determinePosition();
      Map<String, dynamic> forecast;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? cachedForecast = prefs.getString('weatherForecast');
      _lastCacheDate = DateTime.parse(
          prefs.getString('lastCacheDate') ?? DateTime.now().toIso8601String());

      if (cachedForecast != null &&
          DateTime.now().difference(_lastCacheDate!).inDays < 1) {
        forecast = Map<String, dynamic>.from(json.decode(cachedForecast));
      } else {
        forecast = await WeatherService()
            .getWeatherForecast(position.latitude, position.longitude);

        prefs.setString('weatherForecast', json.encode(forecast));
        prefs.setString('lastCacheDate', DateTime.now().toIso8601String());
      }
      var location = await GoogleMapsService()
          .getCityAndState(position.latitude, position.longitude);

      // ignore: use_build_context_synchronously
      var logs = await DiveLogController().getDiveLogsByToken(context);

      setState(() {
        user = response;
        weatherForecast = forecast;
        locationData = location;
        diveLogs = logs;
        filteredDiveLogs = logs;
        isLoading = false;
      });
    } catch (e) {
      if (e.toString().contains('O serviço de localização está desativado') ||
          e.toString().contains('As permissões de localização foram negadas') ||
          e.toString().contains(
              'As permissões de localização foram permanentemente negadas')) {
      } else {
        Navigator.push(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('O serviço de localização está desativado.');
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('As permissões de localização foram negadas.');
        }
      }

      while (permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('As permissões de localização foram negadas.');
        }
        if (permission == LocationPermission.deniedForever) {
          _showGpsInactiveAlert(
              'As permissões de localização foram permanentemente negadas. Por favor, conceda a permissão nas configurações do aplicativo.');
          return Future.error(
              'As permissões de localização foram permanentemente negadas.');
        }
      }

      return await Geolocator.getCurrentPosition();
    } catch (e) {
      _showGpsInactiveAlert(
          'A localização é necessária. Por favor, ative a localização e reinicie o aplicativo.');
      return Future.error(e);
    }
  }

  void _showGpsInactiveAlert(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          titlePadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          title: const Row(
            children: [
              Icon(Icons.location_off, color: Color(0xFF007FFF), size: 24),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'ATENÇÃO!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF007FFF),
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          actionsPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'OK',
                style: TextStyle(color: Color(0xFF007FFF)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _filterDiveLogs(String query) async {
    if (filterCriterion == 'Data' && query.length == 10) {
      DateTime? date = DateFormat('dd/MM/yyyy').parseStrict(query);
      if (date != null) {
        String formattedDate = DateFormat('yyyy-MM-dd').format(date);
        List<DiveLogReturn> results =
            await DiveLogService().getDiveLogsByDate(formattedDate);
        setState(() {
          filteredDiveLogs = results;
        });
      }
    } else if (filterCriterion == 'Título') {
      List<DiveLogReturn> results =
          await DiveLogService().getDiveLogsByTitle(query);
      setState(() {
        filteredDiveLogs = results;
      });
    } else if (filterCriterion == 'Localização') {
      List<DiveLogReturn> results =
          await DiveLogController().getDiveLogsByLocation(query);
      setState(() {
        filteredDiveLogs = results;
      });
    }
  }

  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Título'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    filterCriterion = 'Título';
                  });
                },
              ),
              ListTile(
                title: const Text('Data'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    filterCriterion = 'Data';
                  });
                },
              ),
              ListTile(
                title: const Text('Local'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    filterCriterion = 'Localização';
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _getDayOfWeek(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final daysOfWeek = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sab', 'Dom'];
    return daysOfWeek[date.weekday - 1];
  }

  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  List<DiveLogReturn> _getCurrentPageDiveLogs() {
    int startIndex = currentPage * itemsPerPage;
    int endIndex = (startIndex + itemsPerPage) < filteredDiveLogs.length
        ? startIndex + itemsPerPage
        : filteredDiveLogs.length;
    return filteredDiveLogs.sublist(startIndex, endIndex);
  }

  void _previousPage() {
    setState(() {
      if (currentPage > 0) {
        currentPage--;
      }
    });
  }

  void _nextPage() {
    setState(() {
      if ((currentPage + 1) * itemsPerPage < filteredDiveLogs.length) {
        currentPage++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: const LateralMenu(),
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : SingleChildScrollView(
              child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: screenSize.width * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      'Olá, ${user?.firstName} ${user?.lastName}!',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Color(0xFF263238),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Seja bem-vindo(a)!',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        color: Color(0xFF263238),
                      ),
                    ),

                    // Previsão do tempo da semana
                    const SizedBox(height: 25),
                    const SizedBox(
                      width: double.infinity,
                      child: Text(
                        'Previsão do tempo da semana',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color(0xFF263238),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.all(15.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${weatherForecast['current']['temp'].toInt()}°C',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 32,
                                  color: Colors.black,
                                ),
                              ),
                              Image.network(
                                'http://openweathermap.org/img/wn/${weatherForecast['current']['weather'][0]['icon']}@2x.png',
                                width: 40,
                                height: 40,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on,
                                          size: 20, color: Colors.blue),
                                      const SizedBox(width: 5),
                                      Text(
                                        '${locationData['name']}, ${locationData['state']}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_month,
                                          size: 20, color: Colors.blue),
                                      const SizedBox(width: 5),
                                      Text(
                                        '${DateFormat('EEEE', 'pt_BR').format(DateTime.now()).capitalize()}, ${_capitalizeFirstLetter(weatherForecast['current']['weather'][0]['description'])}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )),
                          const SizedBox(height: 20),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: List.generate(7, (index) {
                                final dayData = weatherForecast['daily'][index];
                                return Container(
                                  width:
                                      80, // Ajuste a largura conforme necessário
                                  margin: const EdgeInsets.only(
                                      right: 10), // Espaço entre os itens
                                  child: Column(
                                    children: [
                                      Text(
                                        _getDayOfWeek(dayData['dt']),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Image.network(
                                        'http://openweathermap.org/img/wn/${dayData['weather'][0]['icon']}@2x.png',
                                        width: 30,
                                        height: 30,
                                      ),
                                      const SizedBox(height: 5),
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text:
                                                  '${dayData['temp']['max'].toInt()}° ',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.black,
                                              ),
                                            ),
                                            TextSpan(
                                              text:
                                                  '${dayData['temp']['min'].toInt()}°',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey.shade400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),
                    SizedBox(
                      width: double
                          .infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF002B5B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 20,
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const DiveRegistrationScreen()),
                          );
                        },
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/diver-icon.svg',
                              height: 30,
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Registrar mergulho agora',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Últimos mergulhos
                    const SizedBox(height: 25),
                    const SizedBox(
                      width: double.infinity,
                      child: Text(
                        'Seus últimos mergulhos',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color(0xFF263238),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.all(15.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15.0, vertical: 10.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    onChanged: (value) =>
                                        _filterDiveLogs(value),
                                    decoration: InputDecoration(
                                      hintText: 'Pesquise por $filterCriterion',
                                      border: InputBorder.none,
                                    ),
                                    keyboardType: filterCriterion == 'Data'
                                        ? TextInputType.number
                                        : TextInputType.text,
                                    inputFormatters: filterCriterion == 'Data'
                                        ? [
                                            MaskTextInputFormatter(
                                              mask: '##/##/####',
                                              filter: {'#': RegExp(r'[0-9]')},
                                            ),
                                            LengthLimitingTextInputFormatter(
                                                10),
                                          ]
                                        : [],
                                  ),
                                ),
                                const SizedBox(height: 15),
                                IconButton(
                                  icon: const Icon(Icons.filter_list,
                                      color: Colors.blue),
                                  onPressed: () {
                                    _showFilterOptions(context);
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 15),
                          filteredDiveLogs.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.asset(
                                        'assets/images/mergulho.png',
                                        width: 200,
                                        height: 200,
                                      ),
                                      const SizedBox(height: 10),
                                      const Text(
                                        'Nenhum mergulho registrado.',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Color(0xFF263238),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Column(
                                  children: [
                                    ListView.separated(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount:
                                          _getCurrentPageDiveLogs().length,
                                      separatorBuilder: (context, index) =>
                                          Divider(color: Colors.grey.shade300),
                                      itemBuilder: (context, index) {
                                        final diveLog =
                                            _getCurrentPageDiveLogs()[index];
                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    DiveLogDetailScreen(
                                                        diveLog: diveLog),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(10),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        diveLog.title,
                                                        style: const TextStyle(
                                                          fontFamily: 'Inter',
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          fontSize: 16,
                                                          color:
                                                              Color(0xFF263238),
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      DateFormat('dd/MM/yyyy')
                                                          .format(
                                                              DateTime.parse(
                                                                  diveLog
                                                                      .date)),
                                                      style: const TextStyle(
                                                        fontFamily: 'Inter',
                                                        fontSize: 16,
                                                        color:
                                                            Color(0xFF263238),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${currentPage + 1} de ${(filteredDiveLogs.length / itemsPerPage).ceil()}',
                                          style: const TextStyle(
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Color(0xFF263238),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                  Icons.chevron_left),
                                              onPressed: _previousPage,
                                              color: currentPage > 0
                                                  ? Colors.blue
                                                  : Colors.grey,
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                  Icons.chevron_right),
                                              onPressed: _nextPage,
                                              color: (currentPage + 1) *
                                                          itemsPerPage <
                                                      filteredDiveLogs.length
                                                  ? Colors.blue
                                                  : Colors.grey,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                        ],
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

extension StringCapitalization on String {
  String capitalize() {
    if (this == null || this.isEmpty) {
      return '';
    }
    return this[0].toUpperCase() + this.substring(1).toLowerCase();
  }
}
