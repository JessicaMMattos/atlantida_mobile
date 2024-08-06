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
  StatisticsScreen();

  @override
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
    _startDate = DateTime.now().subtract(Duration(days: 90));
    _endDate = DateTime.now();
    _diveStatistics = Future.value(null);
    _diveLogs = _fetchDiveLogs();
    _fetchStatistics();
  }

  void _nextPage() {
    if (_pageController.hasClients) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_pageController.hasClients) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
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
      appBar: LateralMenu(),
      drawer: LateralMenuDrawer(),
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
              SizedBox(height: 10),
              const Text(
                'Estatísticas',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Color(0xFF263238),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Suas estatísticas de mergulho, desde a profundidade até as condições submarinas, tudo em um só lugar.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                  color: Color(0xFF263238),
                ),
              ),
              SizedBox(height: 25),
              const Title1(
                title: 'Filtre por período',
              ),
              SizedBox(height: 20),
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
                          decoration: InputDecoration(
                            labelText: 'Data Inicial',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectEndDate(context),
                      child: AbsorbPointer(
                        child: TextField(
                          controller: TextEditingController(
                              text: DateFormat('dd/MM/yyyy').format(_endDate)),
                          decoration: InputDecoration(
                            labelText: 'Data Final',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 25),
              _buildStatistics(),
              SizedBox(height: 25),
              _dropdownButtonFormField(),
              SizedBox(height: 25),
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
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || _errorMessage != null) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/mergulho.png',
                width: 200,
                height: 200,
              ),
              SizedBox(height: 10),
              Text(
                _errorMessage ??
                    'Erro ao carregar estatísticas. Por favor, tente novamente mais tarde.',
                style: TextStyle(
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
              SizedBox(height: 10),
              Text(
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
                  title: 'Profundidade Total',
                  value: '${stats.totalDepth} metros',
                  icon: Icons.straighten,
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
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Container(
        width: MediaQuery.of(context).size.width *
            0.8, // Ajuste a largura conforme necessário
        color: Colors.white,
        padding: EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.center, // Alinhamento centralizado
          children: [
            Container(
              width: 4,
              height: 60, // Ajuste a altura se necessário
              color: Color(0xFF007FFF),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                      color: Color(0xFF263238),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    value,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Color(0xFF263238),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12),
            Icon(icon, color: Color(0xFF007FFF), size: 30),
          ],
        ),
      ),
    );
  }

  Widget _dropdownButtonFormField() {
    return DropdownButtonFormField<String>(
      value: _selectedFilter,
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
      decoration: InputDecoration(
        labelText: 'Filtrar por',
        border: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.grey,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.grey,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.grey,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _grafico() {
    return FutureBuilder<List<DiveLog>>(
      future: _diveLogs,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError ||
            snapshot.data == null ||
            snapshot.data!.isEmpty) {
          return SizedBox.shrink();
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
