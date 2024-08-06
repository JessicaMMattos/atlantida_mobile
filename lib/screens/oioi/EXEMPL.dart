import 'dart:convert';
import 'dart:typed_data';
import 'package:atlantida_mobile/components/lateral_menu.dart';
import 'package:atlantida_mobile/components/text_field.dart';
import 'package:atlantida_mobile/controllers/dive_log_controller.dart';
import 'package:atlantida_mobile/models/dive_log.dart';
import 'package:atlantida_mobile/models/midia_data.dart';
import 'package:atlantida_mobile/screens/register_dive_log_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';

class DiveRegistrationScreen5 extends StatefulWidget {
  @override
  _DiveRegistrationScreen5State createState() => _DiveRegistrationScreen5State();
}

class _DiveRegistrationScreen5State extends State<DiveRegistrationScreen5> {
  final TextEditingController _notesController = TextEditingController();
  double? _rating;
  int? _difficulty;
  List<ImageData> _media = [];

  void _toGoBack() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => DiveRegistrationScreen4()),
    );
  }

  Future<void> _nextStep() async {
    try {
      if (_notesController.text.isNotEmpty) {
        newDiveLog.notes = _notesController.text;
      }

      if (_rating != null) {
        newDiveLog.rating = _rating;
      }

      if (_difficulty != null) {
        newDiveLog.difficulty = _difficulty;
      }

      if (_media.isNotEmpty) {
        newDiveLog.media = _media;
      }

      var response = await DiveLogController().createDiveLog(context, newDiveLog);
      print(response.body);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro na última etapa do registro, tente novamente.'),
        ),
      );
    }
  }

  Future<void> _pickMedia() async {
    final ImagePicker _picker = ImagePicker();
    
    final List<XFile>? files = await _picker.pickMultiImage();
    
    List<ImageData> tempMedia = [];

    if (files != null && files.isNotEmpty) {
      for (var file in files) {
        final Uint8List fileData = await file.readAsBytes();
        final String contentType = file.mimeType ?? 'image/jpeg';
        final String base64Data = base64Encode(fileData);
        tempMedia.add(ImageData(data: base64Data, contentType: contentType));
      }
    }

    setState(() {
      _media.addAll(tempMedia);
    });
  }

  Future<void> _pickVideo() async {
    final ImagePicker _picker = ImagePicker();
    
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);

    List<ImageData> tempMedia = [];

    if (video != null) {
      final Uint8List videoData = await video.readAsBytes();
      final String contentType = video.mimeType ?? 'video/mp4';
      final String base64Data = base64Encode(videoData);
      tempMedia.add(ImageData(data: base64Data, contentType: contentType));
    }

    setState(() {
      _media.addAll(tempMedia);
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: const LateralMenu(),
      drawer: const LateralMenuDrawer(),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              Text(
                'Registro de Mergulho',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Color(0xFF263238),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Complete as informações abaixo para registrar seu mergulho.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                  color: Color(0xFF263238),
                ),
              ),
              SizedBox(height: 25),
              Row(
                children: [
                  Container(
                    width: 25,
                    height: 25,
                    decoration: BoxDecoration(
                      color: Color(0xFF007FFF),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Center(
                      child: Text(
                        '5',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Experiência e Observações',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF263238),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: List.generate(
                  5,
                  (index) => Expanded(
                    child: Container(
                      height: screenHeight * 0.007,
                      decoration: BoxDecoration(
                        color: Color(0xFF007FFF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: EdgeInsets.symmetric(horizontal: 5),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Etapa 5 de 5',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  color: Color(0xFF777777),
                ),
              ),
              SizedBox(height: 30),
              const Title1(title: 'Opinião'),
              SizedBox(height: 2),
              const Title2(title: 'Dê uma nota para este local'),
              SizedBox(height: 10),
              RatingBar.builder(
                initialRating: 0,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
                itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Color(0xFF007FFF),
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    _rating = rating;
                  });
                },
              ),
              SizedBox(height: 20),
              const Title1(title: 'Dificuldade'),
              SizedBox(height: 2),
              const Title2(title: 'Qual foi o nível de dificuldade neste local?'),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pequena',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Color(0xFF263238),
                      ),
                    ),
                    Text(
                      'Grande',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Color(0xFF263238),
                      ),
                    ),
                  ],
                ),
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Color(0xFF007FFF),
                  inactiveTrackColor: Colors.lightBlue[100],
                  thumbColor: Color(0xFF007FFF),
                  overlayColor: Color(0xFF007FFF).withOpacity(0.2),
                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.0),
                  overlayShape: RoundSliderOverlayShape(overlayRadius: 28.0),
                  valueIndicatorTextStyle: TextStyle(
                    color: Colors.white,
                  ),
                  valueIndicatorColor: Color(0xFF007FFF),
                ),
                child: Slider(
                  min: 1,
                  max: 10,
                  divisions: 9,
                  value: (_difficulty ?? 1).toDouble(),
                  onChanged: (double value) {
                    setState(() {
                      _difficulty = value.toInt();
                    });
                  },
                  label: '$_difficulty',
                ),
              ),
              const Title1(title: 'Notas Adicionais'),
              SizedBox(height: 2),
              const Title2(title: 'Escreva sobre suas experiências e observações'),
              SizedBox(height: 20),
              TextField(
                controller: _notesController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Notas Adicionais',
                ),
                maxLines: 3,
              ),
              SizedBox(height: 20),
              const Title1(title: 'Adicionar Fotos/Vídeos'),
              SizedBox(height: 2),
              const Title2(title: 'Anexe fotos e vídeos da sua experiência'),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _pickMedia,
                child: Text('Escolher Fotos'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _pickVideo,
                child: Text('Vídeos'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              SizedBox(height: 20),
              _media.isNotEmpty
                  ? GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: _media.length,
                      itemBuilder: (context, index) {
                        final media = _media[index];
                        final isImage = media.contentType.startsWith('image');
                        final imageData = base64Decode(media.data);

                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[200],
                          ),
                          child: isImage
                              ? Image.memory(imageData, fit: BoxFit.cover)
                              : Center(
                                  child: Icon(
                                    Icons.video_library,
                                    color: Colors.grey,
                                    size: 50,
                                  ),
                                ),
                        );
                      },
                    )
                  : Center(
                      child: Text('Nenhuma mídia selecionada'),
                    ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _toGoBack,
                    style: ElevatedButton.styleFrom(
                      side: BorderSide(color: Color(0xFF007FFF)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: _nextStep,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: Text('Finalizar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
