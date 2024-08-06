import 'package:atlantida_mobile/controllers/dive_log_controller.dart';
import 'package:atlantida_mobile/models/dive_log.dart';
import 'package:flutter/material.dart';

class DiveLogDetailsScreen extends StatefulWidget {
  final DiveLog diveLog;

  const DiveLogDetailsScreen({super.key, required this.diveLog});

  @override
  _DiveLogDetailsState createState() => _DiveLogDetailsState();
}

class _DiveLogDetailsState extends State<DiveLogDetailsScreen> {
  late DiveLog diveLogDetails;
  bool isLoading = true;
  bool isEditing = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    fetchDiveLogDetails();
  }

  Future<void> fetchDiveLogDetails() async {
    setState(() {
      diveLogDetails = widget.diveLog;
      isLoading = false;
    });
  }

  void updateDiveLog() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Lógica para atualizar o mergulho
      print('Dive Log atualizado: ${diveLogDetails.toJson()}');
      setState(() {
        isEditing = false;
      });
    }
  }

  void deleteDiveLog() async {
    // Lógica para deletar o mergulho
    print('Dive Log deletado:');
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Detalhes do Mergulho'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes do Mergulho'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isEditing)
                  ...[
                    _buildTextField('Título', diveLogDetails.title, (value) => diveLogDetails.title = value),
                    _buildTextField('ID do Ponto de Mergulho', diveLogDetails.divingSpotId, (value) => diveLogDetails.divingSpotId = value),
                    _buildTextField('Data', diveLogDetails.date, (value) => diveLogDetails.date = value),
                    _buildTextField('Tipo', diveLogDetails.type, (value) => diveLogDetails.type = value),
                    _buildTextField('Profundidade', diveLogDetails.depth?.toString() ?? '', (value) => diveLogDetails.depth = double.parse(value)),
                    _buildTextField('Tempo de Fundo (min)', diveLogDetails.bottomTimeInMinutes?.toString() ?? '', (value) => diveLogDetails.bottomTimeInMinutes = int.parse(value)),
                    _buildTextField('Tipo de Água', diveLogDetails.waterType ?? '', (value) => diveLogDetails.waterType = value),
                    _buildTextField('Corpo de Água', diveLogDetails.waterBody ?? '', (value) => diveLogDetails.waterBody = value),
                    _buildTextField('Condições Climáticas', diveLogDetails.weatherConditions ?? '', (value) => diveLogDetails.weatherConditions = value),
                    _buildTextField('Dificuldade', diveLogDetails.difficulty?.toString() ?? '', (value) => diveLogDetails.difficulty = int.parse(value)),
                  ]
                else
                  ...[
                    _buildDetailRow('Título', diveLogDetails.title),
                    _buildDetailRow('ID do Ponto de Mergulho', diveLogDetails.divingSpotId),
                    _buildDetailRow('Data', diveLogDetails.date),
                    _buildDetailRow('Tipo', diveLogDetails.type),
                    _buildDetailRow('Profundidade', diveLogDetails.depth?.toString() ?? 'N/A'),
                    _buildDetailRow('Tempo de Fundo (min)', diveLogDetails.bottomTimeInMinutes?.toString() ?? 'N/A'),
                    _buildDetailRow('Tipo de Água', diveLogDetails.waterType ?? 'N/A'),
                    _buildDetailRow('Corpo de Água', diveLogDetails.waterBody ?? 'N/A'),
                    _buildDetailRow('Condições Climáticas', diveLogDetails.weatherConditions ?? 'N/A'),
                    _buildDetailRow('Dificuldade', diveLogDetails.difficulty?.toString() ?? 'N/A'),
                  ],
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: isEditing ? updateDiveLog : () {
                        setState(() {
                          isEditing = true;
                        });
                      },
                      child: Text(isEditing ? 'Salvar' : 'Atualizar Mergulho'),
                    ),
                    ElevatedButton(
                      onPressed: deleteDiveLog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: Text('Deletar Mergulho'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String initialValue, Function(String) onSaved) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        onSaved: (newValue) {
          onSaved(newValue!);
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Campo obrigatório.';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
