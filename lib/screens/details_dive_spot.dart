import 'dart:convert';
import 'package:atlantida_mobile/controllers/diving_spot_controller.dart';
import 'package:atlantida_mobile/screens/control.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:atlantida_mobile/models/user.dart';
import 'package:atlantida_mobile/services/maps_service.dart';
import 'package:atlantida_mobile/models/comment_return.dart';
import 'package:atlantida_mobile/screens/register_comment.dart';
import 'package:atlantida_mobile/models/diving_spot_return.dart';
import 'package:atlantida_mobile/screens/full_image_gallery.dart';
import 'package:atlantida_mobile/controllers/user_controller.dart';
import 'package:atlantida_mobile/controllers/comment_controller.dart';

import '../models/midia_data.dart';

class DiveSpotDetailsScreen extends StatefulWidget {
  final String diveSpotId;
  final VoidCallback? onBack;
  final int initialTabIndex;

  const DiveSpotDetailsScreen(
      {super.key, required this.diveSpotId, this.onBack, this.initialTabIndex = 0});

  @override
  // ignore: library_private_types_in_public_api
  _DiveSpotDetailsState createState() => _DiveSpotDetailsState();
}

class _DiveSpotDetailsState extends State<DiveSpotDetailsScreen> {
  late Future<String> locationFuture;
  late DivingSpotReturn diveSpot;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _filterDiveLog();
    locationFuture = _fetchLocation();
  }

  void _filterDiveLog() async {
    try {
      setState(() {
        isLoading = true;
      });

      DivingSpotReturn spot =
          await DivingSpotController().getDivingSpotById(widget.diveSpotId);

      setState(() {
        diveSpot = spot;
      });
    } catch (error) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao carregar Ponto de Mergulho, tente novamente.'),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<String> _fetchLocation() async {
    final result = await GoogleMapsService().getCityAndState(
      diveSpot.location.coordinates[0],
      diveSpot.location.coordinates[1],
    );
    return '${result['name'] ?? 'Desconhecido'}, ${result['state'] ?? 'Desconhecido'}';
  }

  @override
  Widget build(BuildContext context) {
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
              if (widget.onBack != null) {
                widget.onBack!();
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MainNavigationScreen(index: 1),
                  ),
                );
              }
            },
          ),
          title: const Text(
            'Resultados',
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
            if (widget.onBack != null) {
              widget.onBack!();
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MainNavigationScreen(index: 1),
                ),
              );
            }
          },
        ),
        title: const Text(
          'Resultados',
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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImage(diveSpot.image),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            diveSpot.name,
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
                              diveSpot.averageRating?.toStringAsFixed(1) ??
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
                    DescriptionsWidget(comment: diveSpot.description),
                    const SizedBox(height: 16),
                    _buildTabs(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CommentRegistrationScreen(divingSpot: diveSpot),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007FFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'AVALIAR PONTO',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(ImageData? image) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.25,
        decoration: BoxDecoration(
          color: Colors.grey[200],
        ),
        child: image != null && image.data.isNotEmpty
            ? Image.memory(
                base64Decode(image.data),
                fit: BoxFit.cover,
              )
            : const Icon(
                Icons.photo_library_outlined,
                size: 50,
                color: Colors.grey,
              ),
      ),
    );
  }

  Widget _buildTabs() {
    return DefaultTabController(
      length: 2,
      initialIndex: widget.initialTabIndex,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TabBar(
            labelColor: Color(0xFF007FFF),
            unselectedLabelColor: Colors.grey,
            labelStyle: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            indicatorColor: Color(0xFF007FFF),
            tabs: [
              Tab(text: 'Informações'),
              Tab(text: 'Avaliações'),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.3,
            child: TabBarView(
              children: [
                _buildInformation(diveSpot),
                _buildReviews(diveSpot),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviews(DivingSpotReturn divingSpot) {
    final commentController = CommentController();

    return FutureBuilder<List<CommentReturn>>(
      future: commentController.getCommentsByDivingSpotId(divingSpot.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          );
        } else if (snapshot.hasError) {
          return const Center(child: Text('Erro ao carregar avaliações.'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Nenhuma avaliação encontrada.'));
        }

        final comments = snapshot.data!;
        return FutureBuilder<String>(
          future: UserController().findUserByToken().then((user) => user.id),
          builder: (context, userIdSnapshot) {
            if (userIdSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              );
            } else if (userIdSnapshot.hasError) {
              return const Center(child: Text('Erro ao carregar usuário.'));
            }

            final userId = userIdSnapshot.data;

            return ListView.builder(
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final comment = comments[index];

                return FutureBuilder<User>(
                  future: UserController().getUserById(comment.userId),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      );
                    } else if (userSnapshot.hasError) {
                      return const ListTile(
                        title: Text('Erro ao carregar usuário.'),
                      );
                    }

                    final user = userSnapshot.data!;
                    final isCurrentUser = userId == comment.userId;

                    final String formattedDate = comment.createdDate != null
                        ? DateFormat('dd/MM/yyyy').format(
                            DateTime.parse(comment.createdDate!)
                                .toUtc()
                                .add(const Duration(hours: -3))
                                .toLocal(),
                          )
                        : '';

                    return Card(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final isSmallScreen =
                                    constraints.maxWidth < 250;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '${user.firstName} ${user.lastName}',
                                            style: const TextStyle(
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        if (!isSmallScreen)
                                          Text(
                                            formattedDate,
                                            style: const TextStyle(
                                              fontFamily: 'Inter',
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                          ),
                                      ],
                                    ),
                                    if (isSmallScreen)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 4.0),
                                        child: Text(
                                          formattedDate,
                                          style: const TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const SizedBox(width: 4),
                                Row(
                                  children: List.generate(5, (i) {
                                    return Icon(
                                      i < comment.rating
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: Colors.blue,
                                      size: 16,
                                    );
                                  }),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            DescriptionsWidget(comment: comment.comment),
                            if (comment.photos != null &&
                                comment.photos!.isNotEmpty)
                              const SizedBox(height: 8),
                            if (comment.photos != null &&
                                comment.photos!.isNotEmpty)
                              SizedBox(
                                height: 100,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: comment.photos!.length,
                                  itemBuilder: (context, imgIndex) {
                                    final photo = comment.photos![imgIndex];
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  FullScreenImageGallery(
                                                photos: comment.photos!,
                                                initialIndex: imgIndex,
                                              ),
                                            ),
                                          );
                                        },
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Image.memory(
                                            base64Decode(photo.data),
                                            fit: BoxFit.cover,
                                            width: 100,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            if (isCurrentUser)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      _editComment(comment);
                                    },
                                    child: const Text(
                                      'Editar',
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      _deleteComment(comment.id);
                                    },
                                    child: const Text(
                                      'Excluir',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildInformation(DivingSpotReturn divingSpot) {
    return FutureBuilder<String>(
      future: locationFuture,
      builder: (context, snapshot) {
        String locationText =
            snapshot.connectionState == ConnectionState.waiting
                ? 'Carregando...'
                : snapshot.data ?? 'N/A';

        String coordinatesText = divingSpot.location.coordinates.isNotEmpty
            ? '${divingSpot.location.coordinates[0]}, ${divingSpot.location.coordinates[1]}'
            : 'N/A';

        String levelText;
        if (divingSpot.averageDifficulty != null) {
          double difficulty = divingSpot.averageDifficulty!;

          if (difficulty >= 1.0 && difficulty < 2.0) {
            levelText = 'Iniciante';
          } else if (difficulty >= 2.0 && difficulty < 3.0) {
            levelText = 'Iniciante Médio';
          } else if (difficulty >= 3.0 && difficulty < 4.0) {
            levelText = 'Médio';
          } else if (difficulty >= 4.0 && difficulty < 5.0) {
            levelText = 'Médio Avançado';
          } else if (difficulty == 5.0) {
            levelText = 'Avançado';
          } else {
            levelText = 'N/A';
          }
        } else {
          levelText = 'N/A';
        }

        String visibilityText =
            (divingSpot.visibility == null || divingSpot.visibility!.isEmpty)
                ? 'N/A'
                : divingSpot.visibility!;

        String waterBodyText =
            (divingSpot.waterBody.isEmpty) ? 'N/A' : divingSpot.waterBody;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRowMapa(
                Icons.location_on_outlined, coordinatesText, locationText),
            _buildInfoRow(Icons.scuba_diving, 'Nível de mergulho', levelText),
            _buildInfoRow(
                Icons.waves, 'Visibilidade', _capitalize(visibilityText)),
            _buildInfoRow(
                Icons.water_drop, 'Corpo de água', _capitalize(waterBodyText)),
          ],
        );
      },
    );
  }

  Widget _buildInfoRowMapa(IconData icon, String label, String value) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                MainNavigationScreen(index: 1, diveSpot: diveSpot),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 200;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: const Color(0xFF007FFF), size: 28),
                const SizedBox(width: 16),
                Expanded(
                  flex: isSmallScreen ? 2 : 1,
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
                if (!isSmallScreen) const SizedBox(width: 16),
                Expanded(
                  flex: isSmallScreen ? 3 : 1,
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: isSmallScreen ? TextAlign.left : TextAlign.right,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 200;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: const Color(0xFF007FFF), size: 28),
              const SizedBox(width: 16),
              Expanded(
                flex: isSmallScreen ? 2 : 1,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
              if (!isSmallScreen) const SizedBox(width: 16),
              Expanded(
                flex: isSmallScreen ? 3 : 1,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: isSmallScreen ? TextAlign.left : TextAlign.right,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _editComment(CommentReturn comment) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CommentRegistrationScreen(divingSpot: diveSpot, comment: comment),
      ),
    );
  }

  void _deleteComment(String commentId) async {
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
                    'Excluir comentário',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF263238),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tem certeza de que deseja excluir permanentemente seu comentário?',
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
                    await CommentController().deleteComment(commentId);
                    // ignore: duplicate_ignore
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Comentário excluído com sucesso.'),
                      ),
                    );
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (BuildContext context) =>
                            DiveSpotDetailsScreen(
                                diveSpotId: widget.diveSpotId, initialTabIndex: 1)
                      ),
                    );
                  } catch (err) {
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erro ao deletar comentário: $err'),
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
        SnackBar(
          content: Text('Erro ao exibir diálogo de exclusão: $err'),
        ),
      );
    }
  }

  String _capitalize(String text) {
    if (text != "N/A") {
      return text[0].toUpperCase() + text.substring(1).toLowerCase();
    }
    return text;
  }
}

class DescriptionsWidget extends StatefulWidget {
  final String? comment;

  const DescriptionsWidget({super.key, this.comment});

  @override
  // ignore: library_private_types_in_public_api
  _DescriptionsWidgetState createState() => _DescriptionsWidgetState();
}

class _DescriptionsWidgetState extends State<DescriptionsWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Text(
            widget.comment ?? '',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: Colors.black,
            ),
            maxLines: _isExpanded ? null : 3,
            overflow:
                _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
          ),
        ),
        if (!_isExpanded && (widget.comment?.length ?? 0) > 100)
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = true;
              });
            },
            child: const Text(
              'Ver mais...',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Colors.blue,
              ),
            ),
          ),
      ],
    );
  }
}
