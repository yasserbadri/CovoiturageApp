import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class MapSelectionScreen extends StatefulWidget {
  final String title;
  final LatLng? initialPosition;

  const MapSelectionScreen({
    super.key,
    required this.title,
    this.initialPosition,
  });

  @override
  State<MapSelectionScreen> createState() => _MapSelectionScreenState();
}

class _MapSelectionScreenState extends State<MapSelectionScreen> {
  final MapController _mapController = MapController();
  LatLng? _selectedPosition;
  String _selectedAddress = '';
  bool _mapReady = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  void _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      setState(() {
        _selectedPosition = LatLng(position.latitude, position.longitude);
      });
      
      // Attendre que la carte soit prête avant de bouger
      _mapController.mapEventStream.listen((event) {
        if (!_mapReady) {
          _mapReady = true;
          _moveToLocation(_selectedPosition!);
        }
      });
      
    } catch (e) {
      print('Erreur localisation: $e');
      // Position par défaut (Tunis)
      setState(() {
        _selectedPosition = const LatLng(36.8065, 10.1815);
      });
      
      _mapController.mapEventStream.listen((event) {
        if (!_mapReady) {
          _mapReady = true;
          _moveToLocation(_selectedPosition!);
        }
      });
    }
  }

  void _moveToLocation(LatLng position) {
    // Utiliser un délai pour s'assurer que la carte est prête
    Future.delayed(const Duration(milliseconds: 500), () {
      try {
        _mapController.move(position, 15.0);
      } catch (e) {
        print('Erreur déplacement carte: $e');
      }
    });
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      // Méthode simplifiée sans HttpClient
      setState(() {
        _selectedAddress = '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
      });
    } catch (e) {
      print('Erreur géocodage: $e');
      setState(() {
        _selectedAddress = '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (_selectedPosition != null)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                Navigator.pop(context, {
                  'position': _selectedPosition,
                  'address': _selectedAddress,
                });
              },
            ),
        ],
      ),
      body: _selectedPosition == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _selectedPosition!,
                    initialZoom: 15.0,
                    onTap: (tapPosition, latLng) {
                      _onMapTap(latLng);
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                      userAgentPackageName: 'com.example.covoiturage_app',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _selectedPosition!,
                          width: 60,
                          height: 60,
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Adresse sélectionnée
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Emplacement sélectionné:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(_selectedAddress.isEmpty ? 'Sélectionnez un emplacement sur la carte' : _selectedAddress),
                        ],
                      ),
                    ),
                  ),
                ),
                // Bouton position actuelle
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton(
                    onPressed: _getCurrentLocation,
                    child: const Icon(Icons.my_location),
                  ),
                ),
              ],
            ),
    );
  }

  void _onMapTap(LatLng latLng) async {
    setState(() {
      _selectedPosition = latLng;
    });
    await _getAddressFromLatLng(latLng);
  }
}