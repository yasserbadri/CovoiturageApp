import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ride_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/ride_card.dart';
import '../routes/app_routes.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadRides();
  }

  void _loadRides() {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final rideProvider = Provider.of<RideProvider>(context, listen: false);
    print('🔄 Chargement des trajets disponibles...');
    rideProvider.loadAvailableRides().then((_) {
      print('✅ Trajets chargés: ${rideProvider.availableRides.length}');
      rideProvider.availableRides.forEach((ride) {
        print('   - ${ride.startAddress} → ${ride.endAddress} (${ride.price}€)');
      });
    });
  });
}

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final rideProvider = Provider.of<RideProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Covoiturage - Passager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.profile);
            },
          ),
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.map);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // En-tête avec recherche
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Trouver un trajet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: 'Départ',
                              prefixIcon: const Icon(Icons.location_on, color: Colors.red),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: 'Destination',
                              prefixIcon: const Icon(Icons.location_on, color: Colors.green),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.map);
                      },
                      child: const Text('Rechercher sur la carte'),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Liste des trajets disponibles
          Expanded(
            child: rideProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : rideProvider.availableRides.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.car_rental, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'Aucun trajet disponible',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          await rideProvider.loadAvailableRides();
                        },
                        child: ListView.builder(
                          itemCount: rideProvider.availableRides.length,
                          itemBuilder: (context, index) {
                            final ride = rideProvider.availableRides[index];
                            return RideCard(
                              ride: ride,
                              onAccept: () {
                                _acceptRide(ride.id);
                              },
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: Column(
  mainAxisAlignment: MainAxisAlignment.end,
  children: [
    FloatingActionButton(
      onPressed: _loadRides,
      child: const Icon(Icons.refresh),
    ),
    const SizedBox(height: 16),
    FloatingActionButton(
      onPressed: () {
        // Forcer le rechargement depuis l'API
        final rideProvider = Provider.of<RideProvider>(context, listen: false);
        rideProvider.loadAvailableRides();
      },
      child: const Icon(Icons.wifi),
      heroTag: "refresh_api",
    ),
  ],
),
    );
  }

  void _acceptRide(String rideId) async {
    final rideProvider = Provider.of<RideProvider>(context, listen: false);
    final success = await rideProvider.acceptRide(rideId);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trajet accepté avec succès!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de l\'acceptation du trajet')),
      );
    }
  }
}