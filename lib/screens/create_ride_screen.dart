import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'package:latlong2/latlong.dart' as latlong2; // Alias pour latlong2
import '../models/ride.dart';
import '../providers/ride_provider.dart';
import 'map_selection_screen.dart';

class CreateRideScreen extends StatefulWidget {
  const CreateRideScreen({super.key});

  @override
  State<CreateRideScreen> createState() => _CreateRideScreenState();
}

class _CreateRideScreenState extends State<CreateRideScreen> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _seatsController = TextEditingController(text: '4');

  Map<String, dynamic>? _startLocation;
  Map<String, dynamic>? _endLocation;
  double _distance = 0.0;
  int _duration = 0;
  bool _isCalculating = false;

  @override
  Widget build(BuildContext context) {
    final rideProvider = Provider.of<RideProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Proposer un trajet'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Sélection du départ
              Card(
                child: ListTile(
                  leading: const Icon(Icons.location_on, color: Colors.red),
                  title: const Text('Lieu de départ'),
                  subtitle: Text(
                    _startLocation?['address'] ?? 'Sélectionner sur la carte',
                    style: TextStyle(
                      color: _startLocation == null ? Colors.grey : Colors.black,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _selectLocation(true),
                ),
              ),
              const SizedBox(height: 16),

              // Sélection de la destination
              Card(
                child: ListTile(
                  leading: const Icon(Icons.location_on, color: Colors.green),
                  title: const Text('Destination'),
                  subtitle: Text(
                    _endLocation?['address'] ?? 'Sélectionner sur la carte',
                    style: TextStyle(
                      color: _endLocation == null ? Colors.grey : Colors.black,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _selectLocation(false),
                ),
              ),
              const SizedBox(height: 16),

              // Calculer l'itinéraire
              if (_startLocation != null && _endLocation != null)
                ElevatedButton(
                  onPressed: _isCalculating ? null : _calculateRoute,
                  child: _isCalculating
                      ? const CircularProgressIndicator()
                      : const Text('Calculer l\'itinéraire'),
                ),

              const SizedBox(height: 16),

              // Informations du trajet calculé
              if (_distance > 0) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Détails du trajet',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildRouteInfo(),
                        const SizedBox(height: 16),
                        
                        // Prix
                        TextFormField(
                          controller: _priceController,
                          decoration: const InputDecoration(
                            labelText: 'Prix (€)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.euro),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez saisir le prix';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Prix invalide';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Places disponibles
                        TextFormField(
                          controller: _seatsController,
                          decoration: const InputDecoration(
                            labelText: 'Places disponibles',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.people),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez saisir le nombre de places';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Nombre de places invalide';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Bouton de soumission
              if (_distance > 0)
                ElevatedButton(
                  onPressed: _isCalculating ? null : () => _submitRide(rideProvider),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Proposer le trajet',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectLocation(bool isStart) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapSelectionScreen(
          title: isStart ? 'Sélectionnez le départ' : 'Sélectionnez la destination',
        ),
      ),
    );

    if (result != null) {
      setState(() {
        if (isStart) {
          _startLocation = result;
        } else {
          _endLocation = result;
        }
      });
    }
  }

  void _calculateRoute() async {
    if (_startLocation == null || _endLocation == null) return;

    setState(() {
      _isCalculating = true;
    });

    try {
      // Récupérer les positions avec le bon type
      final startPosition = _startLocation!['position'] as latlong2.LatLng;
      final endPosition = _endLocation!['position'] as latlong2.LatLng;
      
      // Calcul de distance simplifié
      _distance = _calculateHaversineDistance(
        startPosition.latitude,
        startPosition.longitude,
        endPosition.latitude,
        endPosition.longitude,
      );
      
      // Estimation du temps (vitesse moyenne 40 km/h en ville)
      _duration = (_distance / 40 * 60).round();
      
      // Prix suggéré
      final suggestedPrice = _distance * 0.5; // 0.5€ par km
      _priceController.text = suggestedPrice.toStringAsFixed(2);
      
    } catch (e) {
      print('Erreur calcul itinéraire: $e');
      // Valeurs par défaut en cas d'erreur
      _distance = 10.0;
      _duration = 20;
      _priceController.text = '5.00';
    } finally {
      setState(() {
        _isCalculating = false;
      });
    }
  }

  double _calculateHaversineDistance(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371; // Rayon de la Terre en km
    
    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);
    
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
    
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _toRadians(double degrees) {
    return degrees * pi / 180;
  }

  Widget _buildRouteInfo() {
    return Column(
      children: [
        Row(
          children: [
            _buildInfoItem(Icons.av_timer, '${_duration} min'),
            _buildInfoItem(Icons.directions_car, '${_distance.toStringAsFixed(1)} km'),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '${_startLocation?['address'] ?? ''} → ${_endLocation?['address'] ?? ''}',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  void _submitRide(RideProvider rideProvider) async {
    if (_formKey.currentState!.validate()) {
      final startPosition = _startLocation!['position'] as latlong2.LatLng;
      final endPosition = _endLocation!['position'] as latlong2.LatLng;

      // Créer le trajet avec le bon type LatLng
      final ride = Ride(
        id: '',
        driverId: '',
        startLocation: LatLng(startPosition.latitude, startPosition.longitude),
        endLocation: LatLng(endPosition.latitude, endPosition.longitude),
        startAddress: _startLocation!['address'] ?? '',
        endAddress: _endLocation!['address'] ?? '',
        price: double.parse(_priceController.text),
        status: 'pending',
        createdAt: DateTime.now(),
        distance: _distance,
        duration: _duration,
      );

      // Sauvegarder le trajet via l'API
      final success = await rideProvider.createRide(ride);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trajet créé avec succès!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la création du trajet')),
        );
      }
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    _seatsController.dispose();
    super.dispose();
  }
}