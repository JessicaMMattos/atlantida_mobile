import 'package:atlantida_mobile/components/lateral_menu.dart';
import 'package:atlantida_mobile/components/navigation_bar.dart';
import 'package:atlantida_mobile/components/text_field.dart';
import 'package:atlantida_mobile/controllers/dive_log_controller.dart';
import 'package:atlantida_mobile/controllers/diving_statistics_controller.dart';
import 'package:atlantida_mobile/models/dive_log.dart';
import 'package:atlantida_mobile/models/dive_statistics.dart';
import 'package:atlantida_mobile/components/custom_column_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  late Future<DiveStatistics?> _diveStatistics;
  late DateTime _startDate;
  late DateTime _endDate;
  String? _errorMessage;
  String _selectedFilter = 'Tempo total de fundo';
  late Future<List<DiveLog>> _diveLogs;

  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _startDate = DateTime.now().subtract(const Duration(days: 90));
    _endDate = DateTime.now();
    _diveStatistics = Future.value(null);
    _diveLogs = _fetchDiveLogs();
    _fetchStatistics();
  }

  Future<void> _fetchStatistics() async {
    final String startDateStr = DateFormat('yyyy-MM-dd').format(_startDate);
    final String endDateStr = DateFormat('yyyy-MM-dd').format(_endDate);

    try {
      Object responseBody = await DiveStatisticsController()
          .getDiveStatistics(context, startDateStr, endDateStr);

      if (responseBody ==
          'Nenhum mergulho encontrado para o período selecionado') {
        setState(() {
          _errorMessage =
              'Nenhum mergulho encontrado para o período selecionado.';
          _diveStatistics = Future.value(null);
        });
      } else {
        setState(() {
          _errorMessage = null;
          _diveStatistics = Future.value(responseBody as DiveStatistics);
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage =
            'Erro ao carregar estatísticas. Por favor, tente novamente mais tarde.';
        _diveStatistics = Future.value(null);
      });
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Erro ao carregar estatísticas. Por favor, tente novamente mais tarde.')),
      );
    }
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _startDate) {
      if (picked.isAfter(_endDate)) {
        setState(() {
          _endDate = picked;
        });
      }
      setState(() {
        _startDate = picked;
      });
      _updateData();
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
      _updateData();
    }
  }

  Future<List<DiveLog>> _fetchDiveLogs() async {
    final String startDateStr = DateFormat('yyyy-MM-dd').format(_startDate);
    final String endDateStr = DateFormat('yyyy-MM-dd').format(_endDate);

    try {
      List<DiveLog> responseDive = await DiveLogController()
          .getDiveLogsByDateRange(startDateStr, endDateStr);

      if (responseDive.isEmpty) {
        setState(() {
          _errorMessage =
              'Nenhum mergulho registrado para o período selecionado.';
        });
      } else {
        setState(() {
          _errorMessage = null;
          _diveLogs = Future.value(responseDive);
        });
      }
      return responseDive;
    } catch (error) {
      setState(() {
        _errorMessage =
            'Erro ao carregar registros de mergulho. Por favor, tente novamente mais tarde.';
        _diveLogs = Future.value([]);
      });
      return [];
    }
  }

  void _updateData() {
    setState(() {
      _fetchStatistics();
      _diveLogs = _fetchDiveLogs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: const LateralMenu(),
      drawer: const LateralMenuDrawer(),
      bottomNavigationBar: const NavBar(
        index: 0,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text(
                'Estatísticas',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Color(0xFF263238),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Suas estatísticas de mergulho, desde a profundidade até as condições submarinas, tudo em um só lugar.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                  color: Color(0xFF263238),
                ),
              ),
              const SizedBox(height: 25),
              const Title1(
                title: 'Filtre por período',
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectStartDate(context),
                      child: AbsorbPointer(
                        child: TextField(
                          controller: TextEditingController(
                              text:
                                  DateFormat('dd/MM/yyyy').format(_startDate)),
                          decoration: const InputDecoration(
                            labelText: 'Data Inicial',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectEndDate(context),
                      child: AbsorbPointer(
                        child: TextField(
                          controller: TextEditingController(
                              text: DateFormat('dd/MM/yyyy').format(_endDate)),
                          decoration: const InputDecoration(
                            labelText: 'Data Final',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              _buildStatistics(),
              const SizedBox(height: 25),
              _dropdownButtonFormField(),
              const SizedBox(height: 25),
              _grafico(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatistics() {
    return FutureBuilder<DiveStatistics?>(
      future: _diveStatistics,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.blue));
        } else if (snapshot.hasError || _errorMessage != null) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/mergulho.png',
                width: 200,
                height: 200,
              ),
              const SizedBox(height: 10),
              Text(
                _errorMessage ??
                    'Erro ao carregar estatísticas. Por favor, tente novamente mais tarde.',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF263238),
                ),
              ),
            ],
          );
        } else if (!snapshot.hasData || snapshot.data == null) {
          return Column(
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
          );
        } else {
          var stats = snapshot.data!;
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                buildStatisticCard(
                  context,
                  title: 'Total de mergulhos',
                  value: '${stats.totalDives}',
                  icon: Icons.format_list_numbered,
                ),
                buildStatisticCard(
                  context,
                  title: 'Profundidade Média',
                  value: '${stats.averageDepth} metros',
                  icon: Icons.height,
                ),
                buildStatisticCard(
                  context,
                  title: 'Tempo Total de Fundo',
                  value: '${stats.totalBottomTime} minutos',
                  icon: Icons.timer,
                ),
                if (stats.mostCommonWaterBody != null &&
                    stats.mostCommonWaterBody!.isNotEmpty)
                  buildStatisticCard(
                    context,
                    title: 'Corpo de Água Mais Comum',
                    value: stats.mostCommonWaterBody!,
                    icon: Icons.water,
                  ),
                if (stats.mostCommonWeatherCondition != null &&
                    stats.mostCommonWeatherCondition!.isNotEmpty)
                  buildStatisticCard(
                    context,
                    title: 'Clima Mais Comum',
                    value: stats.mostCommonWeatherCondition!,
                    icon: Icons.cloud,
                  ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget buildStatisticCard(BuildContext context,
      {required String title, required String value, required IconData icon}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 4,
              height: 60,
              color: const Color(0xFF007FFF),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                      color: Color(0xFF263238),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    value,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Color(0xFF263238),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(icon, color: const Color(0xFF007FFF), size: 30),
          ],
        ),
      ),
    );
  }

  Widget _dropdownButtonFormField() {
    return DropdownButtonFormField<String>(
      value: _selectedFilter,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: 'Filtrar por',
        border: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.grey,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.grey,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Color(0xFF263238),
          ),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      icon: const Icon(
        Icons.arrow_drop_down,
        color: Colors.grey,
      ),
      elevation: 16,
      style: const TextStyle(color: Colors.black),
      onChanged: (String? newValue) {
        setState(() {
          _selectedFilter = newValue!;
        });
        _updateData();
      },
      items: <String>[
        'Tempo total de fundo',
        'Profundidade Atingida',
        'Quantidade de Gás Utilizada'
      ].map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      dropdownColor: Colors.white,
    );
  }

  Widget _grafico() {
    return FutureBuilder<List<DiveLog>>(
      future: _diveLogs,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.blue));
        }
        if (snapshot.hasError ||
            snapshot.data == null ||
            snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final diveLogs = snapshot.data!;
        final values = <double>[];
        final labels = <String>[];

        for (var log in diveLogs) {
          switch (_selectedFilter) {
            case 'Tempo total de fundo':
              values.add((log.bottomTimeInMinutes?.toDouble() ?? 0).toDouble());
              break;
            case 'Profundidade Atingida':
              values.add((log.depth ?? 0).toDouble());
              break;
            case 'Quantidade de Gás Utilizada':
              values.add((log.cylinder?.usedAmount ?? 0).toDouble());
              break;
          }
          labels.add(DateFormat('dd/MM/yyyy').format(DateTime.parse(log.date)));
        }

        final maxValue =
            values.isNotEmpty ? values.reduce((a, b) => a > b ? a : b) : 1.0;

        return CustomColumnChart(
          values: values,
          labels: labels,
          unit: _selectedFilter == 'Tempo total de fundo'
              ? 'minutos'
              : _selectedFilter == 'Profundidade Atingida'
                  ? 'metros'
                  : 'bar',
          maxValue: maxValue,
        );
      },
    );
  }
}
