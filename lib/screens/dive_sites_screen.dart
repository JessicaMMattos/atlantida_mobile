import 'package:atlantida_mobile/controllers/diving_spot_controller.dart';
import 'package:atlantida_mobile/models/diving_spot_return.dart';
import 'package:atlantida_mobile/screens/dive_spot_details_screen.dart';
import 'package:atlantida_mobile/screens/home_screen.dart';
import 'package:atlantida_mobile/screens/register_diving_spots_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  LatLng _initialPosition = const LatLng(-23.5505, -46.6333);
  bool _loading = true;
  String filterCriterion = 'Nome';
  final TextEditingController _searchController = TextEditingController();
  List<DivingSpotReturn> diveSpots = [];
  List<DivingSpotReturn> filteredDiveSpots = [];
  final Set<Marker> _markers = {};
  bool isListVisible = true;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    _loadDivingSpots();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _getUserLocation() async {
    Position? position = await _determinePosition();
    if (position != null) {
      setState(() {
        _initialPosition = LatLng(position.latitude, position.longitude);
        _loading = false;
      });
    }
  }

  Future<Position?> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }

    if (permission == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  void _onSearchChanged() {
    _filterDiveLogs(_searchController.text);
  }

  Future<void> _loadDivingSpots() async {
    diveSpots = await DivingSpotController().getAllDivingSpots();
    setState(() {
      filteredDiveSpots = diveSpots;
      _addMarkers();
    });
  }

  void _addMarkers() {
    _markers.clear();
    for (var spot in filteredDiveSpots) {
      _markers.add(
        Marker(
          markerId: MarkerId(spot.id),
          position: LatLng(
              spot.location.coordinates[1], spot.location.coordinates[0]),
          infoWindow: InfoWindow(
            title: spot.name,
            snippet: 'Toque para mais detalhes...',
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => DiveSpotDetailsScreen(diveSpot: spot),
                ),
              );
            },
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueAzure), // Ícone padrão azul para os pontos
        ),
      );
    }
  }

  void _filterDiveLogs(String query) async {
    List<DivingSpotReturn> spots = [];

    if (filterCriterion == 'Nome') {
      spots = await DivingSpotController().getDivingSpotsByName(query);
    } else if (filterCriterion == 'Classificação') {
      double? rating = double.tryParse(query);
      if (rating != null) {
        spots = await DivingSpotController().getDivingSpotsByRating(rating);
      }
    } else if (filterCriterion == 'Dificuldade') {
      double? difficulty = double.tryParse(query);
      if (difficulty != null) {
        spots =
            await DivingSpotController().getDivingSpotsByDifficulty(difficulty);
      }
    } else if (filterCriterion == 'Na proximidade') {
      Position? position = await _determinePosition();
      if (position != null) {
        spots = await DivingSpotController()
            .getDivingSpotsByLocation(position.latitude, position.longitude);
      }
    }

    setState(() {
      filteredDiveSpots = spots;
      _addMarkers();
    });
  }

  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (context) {
        return FilterOptions(
          currentFilter: filterCriterion,
          onFilterSelected: (selectedFilter) {
            setState(() {
              filterCriterion = selectedFilter;
              _searchController.clear();
              _filterDiveLogs('');
            });
            Navigator.pop(context);
          },
        );
      },
    );
  }

  Widget _buildSearchField() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.04,
        vertical: MediaQuery.of(context).size.height * 0.01,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300, width: 1.0),
      ),
      child:
          filterCriterion == 'Classificação' || filterCriterion == 'Dificuldade'
              ? Row(
                  children: [
                    Expanded(
                        child: DropdownButtonFormField<String>(
                      value: _searchController.text.isEmpty
                          ? null
                          : _searchController.text,
                      hint: Text('Selecione $filterCriterion'),
                      elevation: 16,
                      style: const TextStyle(color: Colors.black),
                      onChanged: (value) {
                        if (value != null) {
                          _searchController.text = value;
                          _filterDiveLogs(value);
                        }
                      },
                      items: _getDropdownItems(),
                      dropdownColor: Colors.white,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
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
                    )),
                    IconButton(
                      icon: const Icon(Icons.filter_list, color: Colors.blue),
                      onPressed: () {
                        _showFilterOptions(context);
                      },
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Buscar $filterCriterion',
                          border: InputBorder.none,
                        ),
                        enabled: filterCriterion != 'Na proximidade',
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.filter_list, color: Colors.blue),
                      onPressed: () {
                        _showFilterOptions(context);
                      },
                    ),
                  ],
                ),
    );
  }

  List<DropdownMenuItem<String>> _getDropdownItems() {
    if (filterCriterion == 'Classificação') {
      return List.generate(
          5,
          (index) => DropdownMenuItem(
                value: (index + 1).toString(),
                child: Text('${index + 1} Estrela${index > 0 ? 's' : ''}'),
              ));
    } else if (filterCriterion == 'Dificuldade') {
      const difficultyLevels = [
        'Iniciante',
        'Leve',
        'Médio',
        'Médio Alto',
        'Alto'
      ];
      return List.generate(
          5,
          (index) => DropdownMenuItem(
                value: difficultyLevels[index],
                child: Text(difficultyLevels[index]),
              ));
    }
    return [];
  }

  Widget _buildDiveSpotList() {
    return Column(
      children: [
        GestureDetector(
          onVerticalDragUpdate: (details) {
            if (details.primaryDelta! < -10) {
              setState(() {
                isListVisible = true;
              });
            } else if (details.primaryDelta! > 10) {
              setState(() {
                isListVisible = false;
              });
            }
          },
          child: InkWell(
            onTap: () {
              setState(() {
                isListVisible = !isListVisible;
              });
            },
            child: Container(
              color: Colors.grey[200],
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Center(
                child: Text(
                  isListVisible ? 'Recolher Lista' : 'Expandir Lista',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: isListVisible ? MediaQuery.of(context).size.height * 0.6 : 0,
          color: Colors.white,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            child: _buildDiveSpotListView(),
          ),
        ),
      ],
    );
  }

  Widget _buildDiveSpotListView() {
    return SizedBox(
      width: double.infinity,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: filteredDiveSpots.length,
        itemBuilder: (context, index) {
          final spot = filteredDiveSpots[index];
          final rating = spot.averageRating ?? 0;
          final fullStars = rating.floor();
          final hasHalfStar = rating - fullStars >= 0.5;

          return ListTile(
            contentPadding: const EdgeInsets.all(8),
            leading: Container(
              width: MediaQuery.of(context).size.width * 0.2,
              height: MediaQuery.of(context).size.width * 0.2,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[100],
                image: spot.image != null
                    ? DecorationImage(
                        image: MemoryImage(spot.image!.decodedData),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: spot.image == null
                  ? const Icon(Icons.image_not_supported,
                      size: 30, color: Color(0xFF007FFF))
                  : null,
            ),
            title: Text(spot.name,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: List.generate(5, (i) {
                    if (i < fullStars) {
                      return const Icon(
                        Icons.star,
                        color: Color(0xFF007FFF),
                        size: 16,
                      );
                    } else if (i == fullStars && hasHalfStar) {
                      return Stack(
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.grey.withOpacity(0.7),
                            size: 16,
                          ),
                          const Positioned(
                            left: 0,
                            child: Icon(
                              Icons.star_half,
                              color: Color(0xFF007FFF),
                              size: 16,
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Icon(
                        Icons.star,
                        color: Colors.grey.withOpacity(0.7),
                        size: 16,
                      );
                    }
                  }),
                ),
                const SizedBox(height: 4),
                Text(
                    '${rating.toStringAsFixed(1)} (${spot.numberOfComments?.toInt() ?? 0} comentários)'),
                const SizedBox(height: 4),
                Text(spot.description ?? 'Sem descrição disponível'),
              ],
            ),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => DiveSpotDetailsScreen(diveSpot: spot),
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                builder: (context) => const HomeScreen(),
              ),
            );
          },
        ),
        title: const Text(
          'Locais de mergulho',
          style: TextStyle(
            color: Color(0xFF007FFF),
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add_location_alt,
              color: Color(0xFF007FFF),
            ),
            onPressed: () {
              final currentRoute = ModalRoute.of(context)?.settings.name;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      DivingSpotRegistrationScreen(previousRoute: currentRoute),
                ),
              );
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : Stack(
              children: [
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _initialPosition,
                    zoom: 10.0,
                  ),
                  markers: _markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                ),
                Positioned(
                  bottom: MediaQuery.of(context).size.height * 0.01,
                  left: MediaQuery.of(context).size.width * 0.02,
                  right: MediaQuery.of(context).size.width * 0.02,
                  child: filteredDiveSpots.isEmpty
                      ? Container()
                      : Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: _buildDiveSpotList(),
                        ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.01,
                  right: MediaQuery.of(context).size.width * 0.02,
                  left: MediaQuery.of(context).size.width * 0.02,
                  child: _buildSearchField(),
                ),
              ],
            ),
    );
  }
}

class FilterOptions extends StatelessWidget {
  final String currentFilter;
  final ValueChanged<String> onFilterSelected;

  const FilterOptions({
    super.key,
    required this.currentFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Escolha um critério de filtro',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 10),
          ...['Nome', 'Classificação', 'Dificuldade', 'Na proximidade']
              .map((filter) {
            return RadioListTile<String>(
              value: filter,
              groupValue: currentFilter,
              activeColor: Colors.blue,
              title: Text(filter),
              onChanged: (value) {
                if (value != null) {
                  onFilterSelected(value);
                }
              },
            );
          }),
        ],
      ),
    );
  }
}
