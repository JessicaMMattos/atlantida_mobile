import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:atlantida_mobile/models/photo.dart';
import 'package:atlantida_mobile/models/comment.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:atlantida_mobile/models/comment_return.dart';
import 'package:atlantida_mobile/components/text_field.dart';
import 'package:atlantida_mobile/screens/details_dive_spot.dart';
import 'package:atlantida_mobile/models/diving_spot_return.dart';
import 'package:atlantida_mobile/components/custom_alert_dialog.dart';
import 'package:atlantida_mobile/controllers/comment_controller.dart';

class CommentRegistrationScreen extends StatefulWidget {
  final DivingSpotReturn divingSpot;
  final CommentReturn?
      comment; // Atualizado para receber um comentário existente ou null

  const CommentRegistrationScreen(
      {super.key, required this.divingSpot, this.comment});

  @override
  // ignore: library_private_types_in_public_api
  _CommentRegistrationScreenState createState() =>
      _CommentRegistrationScreenState();
}

class _CommentRegistrationScreenState extends State<CommentRegistrationScreen> {
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  List<Photo> _media = [];
  String _ratingErrorMessage = '';
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.comment != null) {
      _rating = widget.comment!.rating;
      _commentController.text = widget.comment!.comment ?? '';
      _media = widget.comment!.photos ?? [];
    }
  }

  Future<void> _pickMedia() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> files = await picker.pickMultiImage();
    List<Photo> tempMedia = [];

    if (files.isNotEmpty) {
      for (var file in files) {
        final Uint8List fileData = await file.readAsBytes();
        final String contentType = file.mimeType ?? 'image/jpeg';
        final String base64Data = base64Encode(fileData);
        tempMedia.add(Photo(data: base64Data, contentType: contentType));
      }
    }

    setState(() {
      _media.addAll(tempMedia);
    });
  }

  void _resetForm() {
    setState(() {
      _commentController.clear();
      _media = [];
      _rating = 0;
      _ratingErrorMessage = '';
    });
  }

  void _removeMedia(int index) {
    setState(() {
      _media.removeAt(index);
    });
  }

  void _cancel() {
    _resetForm();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            DiveSpotDetailsScreen(diveSpotId: widget.divingSpot.id),
      ),
    );
  }

  Future<void> _nextStep() async {
    try {
      setState(() {
        _isProcessing = true;

        if (_rating == 0) {
          _ratingErrorMessage = 'Campo obrigatório.';
        } else {
          _ratingErrorMessage = '';
        }
      });

      if (_ratingErrorMessage.isEmpty) {
        final comment =
            Comment(rating: _rating, divingSpotId: widget.divingSpot.id);

        if (_media != []) {
          comment.photos = _media;
        }

        if (_commentController.text.isNotEmpty) {
          comment.comment = _commentController.text;
        }

        if (widget.comment != null) {
          await CommentController().updateComment(widget.comment!.id, comment);

          showDialog(
            // ignore: use_build_context_synchronously
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return CustomAlertDialog(
                text: 'Comentário atualizado com sucesso!',
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DiveSpotDetailsScreen(
                          diveSpotId: widget.divingSpot.id, initialTabIndex: 1)
                    ),
                  );
                },
              );
            },
          );
        } else {
          await CommentController().createComment(comment);

          showDialog(
            // ignore: use_build_context_synchronously
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return CustomAlertDialog(
                text: 'Comentário adicionado com sucesso!',
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DiveSpotDetailsScreen(
                          diveSpotId: widget.divingSpot.id, initialTabIndex: 1)
                    ),
                  );
                },
              );
            },
          );
        }

        _resetForm();
      }
    } catch (error) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao registrar avaliação, tente novamente.'),
        ),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

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
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    DiveSpotDetailsScreen(diveSpotId: widget.divingSpot.id),
              ),
            );
          },
        ),
        title: Text(
          widget.comment != null ? 'Editar avaliação' : 'Avaliar ponto',
          style: const TextStyle(
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.divingSpot.name,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.blue,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.divingSpot.averageRating?.toStringAsFixed(1) ??
                            '0.0',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                widget.divingSpot.description ?? '',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Colors.black54,
                ),
              ),
              const Divider(height: 24),
              const Text(
                'Avaliar ponto',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Color(0xFF263238),
                ),
              ),
              const SizedBox(height: 20),
              const Row(
                children: [
                  Title1(title: 'Opinião'),
                  Text(
                    ' (Obrigatório)',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              const Title2(
                title: 'Dê uma nota para esse local',
              ),
              const SizedBox(height: 10),
              RatingBar.builder(
                initialRating: _rating.toDouble(),
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Color(0xFF007FFF),
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    _rating = rating.toInt();
                  });
                },
              ),
              if (_ratingErrorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: Text(
                    _ratingErrorMessage,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              const Title1(title: 'Comentário'),
              const SizedBox(height: 2),
              const Title2(
                title: 'Anote as memórias do seu mergulho',
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _commentController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                  hintText: 'Insira sua avaliação aqui',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFF263238),
                    ),
                  ),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 20),
              const Title1(title: 'Fotos'),
              const SizedBox(height: 2),
              const Title2(
                title: 'O que você viu durante seu mergulho?',
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickMedia,
                      icon: const Icon(Icons.camera_alt,
                          color: Color(0xFF007FFF)),
                      label: const Text(
                        'Selecionar Fotos',
                        style: TextStyle(color: Color(0xFF007FFF)),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF007FFF)),
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (_media.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mídia Adicionada:',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: List.generate(_media.length, (index) {
                        final mediaItem = _media[index];
                        return Stack(
                          children: [
                            if (mediaItem.contentType.startsWith('image'))
                              Image.memory(
                                base64Decode(mediaItem.data),
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () => _removeMedia(index),
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 18,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: screenWidth * 0.4,
                    child: ElevatedButton(
                      onPressed: _cancel,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFF007FFF)),
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
                        'CANCELAR',
                        style: TextStyle(
                          color: Color(0xFF007FFF),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: screenWidth * 0.4,
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _nextStep,
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
                      child: _isProcessing
                          ? const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.blue),
                            )
                          : Text(
                              widget.comment != null ? 'EDITAR' : 'AVALIAR',
                              style: const TextStyle(
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
}
