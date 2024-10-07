import 'dart:convert';
import 'package:atlantida_mobile/screens/control.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:atlantida_mobile/models/photo.dart';
import 'package:atlantida_mobile/models/dive_log_return.dart';
import 'package:atlantida_mobile/screens/full_image_gallery.dart';
import 'package:atlantida_mobile/screens/details_dive_spot.dart';
import 'package:atlantida_mobile/screens/register_dive_log.dart';
import 'package:atlantida_mobile/models/diving_spot_return.dart';
import 'package:atlantida_mobile/controllers/dive_log_controller.dart';
import 'package:atlantida_mobile/controllers/diving_spot_controller.dart';

class DiveLogDetailScreen extends StatefulWidget {
  final DiveLogReturn diveLog;

  const DiveLogDetailScreen({super.key, required this.diveLog});

  @override
  // ignore: library_private_types_in_public_api
  _DiveLogDetailScreenState createState() => _DiveLogDetailScreenState();
}

class _DiveLogDetailScreenState extends State<DiveLogDetailScreen> {
  DivingSpotReturn? divingSpot;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDivingSpotInfo();
  }

  Future<void> _fetchDivingSpotInfo() async {
    try {
      final spot = await DivingSpotController()
          .getDivingSpotById(widget.diveLog.divingSpotId);
      setState(() {
        divingSpot = spot;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Erro ao buscar informações do ponto de mergulho, tente novamente.')),
      );
    }
  }

  String _formatDate(String date) {
    final dateFormat = DateTime.parse(date);
    return DateFormat('dd/MM/yyyy').format(dateFormat);
  }

  Widget _buildImage(Photo photo) {
    final imageData = photo.data;

    if (imageData.isEmpty) {
      return Container(
        width: 200,
        height: 200,
        color: Colors.grey,
        child: const Icon(Icons.error, color: Colors.red),
      );
    }

    try {
      final decodedImage = base64Decode(imageData);
      return Image.memory(
        decodedImage,
        fit: BoxFit.cover,
        width: 200,
        height: 200,
      );
    } catch (e) {
      return Container(
        width: 200,
        height: 200,
        color: Colors.grey,
        child: const Icon(Icons.error, color: Colors.red),
      );
    }
  }

  void _navigateToDivingSpotDetails(
      BuildContext context, DivingSpotReturn divingSpot) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DiveSpotDetailsScreen(
          diveSpotId: divingSpot.id,
          onBack: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    DiveLogDetailScreen(diveLog: widget.diveLog),
              ),
            );
          },
        ),
      ),
    );
  }

  void _deleteDiveLog() async {
    try {
      bool? shouldUpdate = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            contentPadding: const EdgeInsets.all(20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            content: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8,
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Excluir registro de mergulho',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF263238),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tem certeza de que deseja excluir permanentemente este registro?',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: Color(0xFF263238),
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text(
                  'CANCELAR',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF007FFF),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              TextButton(
                child: const Text(
                  'EXCLUIR',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.red,
                  ),
                ),
                onPressed: () async {
                  try {
                    await DiveLogController().deleteDiveLog(widget.diveLog.id);
                    // ignore: duplicate_ignore
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Registro de mergulho excluído com sucesso.'),
                      ),
                    );
                    Navigator.pushAndRemoveUntil(
                      // ignore: use_build_context_synchronously
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MainNavigationScreen()),
                      (Route<dynamic> route) => false,
                    );
                  } catch (err) {
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Erro ao deletar registro de mergulho.'),
                      ),
                    );
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop(false);
                  }
                },
              ),
            ],
          );
        },
      );

      if (shouldUpdate == true) {
        setState(() {});
      }
    } catch (err) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao exibir diálogo de exclusão.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    if (isLoading) {
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
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
                (Route<dynamic> route) => false,
              );
            },
          ),
          title: Text(
            widget.diveLog.title,
            style: const TextStyle(
              color: Color(0xFF007FFF),
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Colors.blue),
        ),
      );
    }

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
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
              (Route<dynamic> route) => false,
            );
          },
        ),
        title: Text(
          widget.diveLog.title,
          style: const TextStyle(
            color: Color(0xFF007FFF),
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.diveLog.photos != null &&
                  widget.diveLog.photos!.isNotEmpty)
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.diveLog.photos!.length,
                    itemBuilder: (context, index) {
                      final photo = widget.diveLog.photos![index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FullScreenImageGallery(
                                photos: widget.diveLog.photos!,
                                initialIndex: index,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: _buildImage(photo),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16.0),
              if (divingSpot != null)
                GestureDetector(
                  onTap: () =>
                      _navigateToDivingSpotDetails(context, divingSpot!),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.blue),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: "Local de Mergulho: ",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                                TextSpan(
                                  text: divingSpot!.name,
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontSize: 16,
                                    fontFamily: 'Inter',
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              _buildDetailRowWithIcon(
                  icon: Icons.calendar_today,
                  label: "Data",
                  value: _formatDate(widget.diveLog.date)),
              _buildDetailRowWithIcon(
                  icon: Icons.info,
                  label: "Tipo de Mergulho",
                  value: _capitalize(widget.diveLog.type)),
              if (_buildDepthAndTimeSection().isNotEmpty)
                Theme(
                  data: ThemeData(
                    dividerColor: Colors.transparent,
                    dividerTheme: const DividerThemeData(thickness: 0),
                  ),
                  child: ExpansionTile(
                    title: const Text(
                      "Profundidade e Tempo",
                      style: TextStyle(
                        color: Color(0xFF007FFF),
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: EdgeInsets.zero,
                    children: _buildDepthAndTimeSection(),
                  ),
                ),
              if (_buildEnvironmentalConditionsSection().isNotEmpty)
                Theme(
                  data: ThemeData(
                    dividerColor: Colors.transparent,
                    dividerTheme: const DividerThemeData(thickness: 0),
                  ),
                  child: ExpansionTile(
                    title: const Text(
                      "Condições Ambientais",
                      style: TextStyle(
                        color: Color(0xFF007FFF),
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: EdgeInsets.zero,
                    children: _buildEnvironmentalConditionsSection(),
                  ),
                ),
              if (_buildEquipmentSection().isNotEmpty)
                Theme(
                  data: ThemeData(
                    dividerColor: Colors.transparent,
                    dividerTheme: const DividerThemeData(thickness: 0),
                  ),
                  child: ExpansionTile(
                    title: const Text(
                      "Equipamentos",
                      style: TextStyle(
                        color: Color(0xFF007FFF),
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: EdgeInsets.zero,
                    children: _buildEquipmentSection(),
                  ),
                ),
              if (widget.diveLog.cylinder != null)
                Theme(
                  data: ThemeData(
                    dividerColor: Colors.transparent,
                    dividerTheme: const DividerThemeData(thickness: 0),
                  ),
                  child: ExpansionTile(
                    title: const Text(
                      "Informações do Cilindro",
                      style: TextStyle(
                        color: Color(0xFF007FFF),
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: EdgeInsets.zero,
                    children: _buildCylinderSection(),
                  ),
                ),
              if (_buildExperienceAndObservationsSection().isNotEmpty)
                Theme(
                  data: ThemeData(
                    dividerColor: Colors.transparent,
                    dividerTheme: const DividerThemeData(thickness: 0),
                  ),
                  child: ExpansionTile(
                    title: const Text(
                      "Experiência e Observações",
                      style: TextStyle(
                        color: Color(0xFF007FFF),
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: EdgeInsets.zero,
                    children: _buildExperienceAndObservationsSection(),
                  ),
                ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: screenWidth * 0.4,
                    child: ElevatedButton(
                      onPressed: () {
                        _deleteDiveLog();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(
                            vertical: 22, horizontal: 30),
                        textStyle: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      child: const Text(
                        'DELETAR',
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: screenWidth * 0.4,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DiveRegistrationScreen(
                              diveLog: widget.diveLog,
                              divingSpot: divingSpot,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007FFF),
                        padding: const EdgeInsets.symmetric(
                            vertical: 22, horizontal: 30),
                        textStyle: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      child: const Text(
                        'EDITAR',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCylinderSection() {
    final cylinder = widget.diveLog.cylinder!;
    List<Widget> items = [];

    if (cylinder.type != null) {
      items.add(_buildDetailRowWithIcon(
          icon: Icons.info_outline,
          label: "Tipo de gás",
          value: _capitalize(cylinder.type!)));
    }
    if (cylinder.size != null) {
      items.add(_buildDetailRowWithIcon(
          icon: Icons.settings,
          label: "Tamanho do Cilindro",
          value: "${cylinder.size} Litros"));
    }
    if (cylinder.gasMixture != null) {
      items.add(_buildDetailRowWithIcon(
          icon: Icons.filter,
          label: "Mistura Gasosa",
          value: "${cylinder.gasMixture}"));
    }
    if (cylinder.initialPressure != null) {
      items.add(_buildDetailRowWithIcon(
          icon: Icons.compress,
          label: "Pressão Inicial",
          value: "${cylinder.initialPressure!} bar"));
    }
    if (cylinder.finalPressure != null) {
      items.add(_buildDetailRowWithIcon(
          icon: Icons.expand,
          label: "Pressão Final",
          value: "${cylinder.finalPressure!} bar"));
    }
    if (cylinder.usedAmount != null) {
      items.add(_buildDetailRowWithIcon(
          icon: Icons.thermostat,
          label: "Quantidade Usada",
          value: "${cylinder.usedAmount!} bar"));
    }
    return items;
  }

  List<Widget> _buildDepthAndTimeSection() {
    List<Widget> items = [];
    if (widget.diveLog.depth != null) {
      items.add(_buildDetailRowWithIcon(
          icon: Icons.vertical_align_bottom,
          label: "Profundidade",
          value: "${widget.diveLog.depth} m"));
    }
    if (widget.diveLog.bottomTimeInMinutes != null) {
      items.add(_buildDetailRowWithIcon(
          icon: Icons.timer,
          label: "Tempo de Fundo",
          value: "${widget.diveLog.bottomTimeInMinutes} min"));
    }
    return items;
  }

  List<Widget> _buildEnvironmentalConditionsSection() {
    List<Widget> items = [];

    if (widget.diveLog.waterType != null) {
      items.add(_buildDetailRowWithIcon(
          icon: Icons.water,
          label: "Tipo de Água",
          value: _capitalize(widget.diveLog.waterType!)));
    }

    if (widget.diveLog.waterBody != null) {
      items.add(_buildDetailRowWithIcon(
          icon: Icons.pool,
          label: "Corpo d'Água",
          value: _capitalize(widget.diveLog.waterBody!)));
    }

    if (widget.diveLog.weatherConditions != null) {
      items.add(_buildDetailRowWithIcon(
          icon: Icons.cloud,
          label: "Condições Climáticas",
          value: _capitalize(widget.diveLog.weatherConditions!)));
    }

    if (widget.diveLog.visibility != null) {
      items.add(_buildDetailRowWithIcon(
          icon: Icons.visibility,
          label: "Visibilidade",
          value: _capitalize(widget.diveLog.visibility!)));
    }

    if (widget.diveLog.waves != null) {
      items.add(_buildDetailRowWithIcon(
          icon: Icons.waves,
          label: "Ondas",
          value: _capitalize(widget.diveLog.waves!)));
    }

    if (widget.diveLog.current != null) {
      items.add(_buildDetailRowWithIcon(
          icon: Icons.swipe,
          label: "Correnteza",
          value: _capitalize(widget.diveLog.current!)));
    }

    if (widget.diveLog.surge != null) {
      items.add(_buildDetailRowWithIcon(
          icon: Icons.trending_up,
          label: "Surgimento",
          value: _capitalize(widget.diveLog.surge!)));
    }

    if (widget.diveLog.temperature != null) {
      final temperature = widget.diveLog.temperature!;

      if (temperature.air != null ||
          temperature.surface != null ||
          temperature.bottom != null) {
        String temperatures = '';

        if (temperature.air != null) {
          temperatures += '\nAr: ${temperature.air}°C';
        }

        if (temperature.surface != null) {
          temperatures += '\nSuperfície: ${temperature.surface}°C';
        }

        if (temperature.bottom != null) {
          temperatures += '\nFundo: ${temperature.bottom}°C';
        }

        items.add(_buildDetailRowWithIcon(
            icon: Icons.thermostat,
            label: "Temperatura",
            value: temperatures.trim()));
      }
    }

    return items;
  }

  List<Widget> _buildEquipmentSection() {
    List<Widget> items = [];
    if (widget.diveLog.suit != null) {
      items.add(_buildDetailRowWithIcon(
          icon: Icons.person,
          label: "Roupa",
          value: _capitalize(widget.diveLog.suit!)));
    }
    if (widget.diveLog.weight != null) {
      items.add(_buildDetailRowWithIcon(
          icon: Icons.fitness_center,
          label: "Peso",
          value: "${widget.diveLog.weight} kg"));
    }
    if (widget.diveLog.additionalEquipment != null &&
        widget.diveLog.additionalEquipment!.isNotEmpty) {
      items.add(_buildDetailRowWithIcon(
          icon: Icons.build,
          label: "Equipamentos Adicionais",
          value: _capitalize(widget.diveLog.additionalEquipment!.join(", "))));
    }
    return items;
  }

  List<Widget> _buildExperienceAndObservationsSection() {
    List<Widget> items = [];
    if (widget.diveLog.notes != null) {
      items.add(_buildDetailRowWithIcon(
          icon: Icons.notes, label: "Notas", value: widget.diveLog.notes!));
    }
    if (widget.diveLog.rating != null) {
      items.add(_buildDetailRowWithIcon(
          icon: Icons.star,
          label: "Classificação",
          value: widget.diveLog.rating.toString()));
    }
    if (widget.diveLog.difficulty != null) {
      items.add(_buildDetailRowWithIcon(
          icon: Icons.terrain,
          label: "Dificuldade",
          value: widget.diveLog.difficulty.toString()));
    }
    return items;
  }

  Widget _buildDetailRowWithIcon(
      {required IconData icon, required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blueAccent, size: 24),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "$label: ",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 16,
                      fontFamily: 'Inter',
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _capitalize(String text) {
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}
