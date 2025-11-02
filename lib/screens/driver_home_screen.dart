import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ride_provider.dart';
import '../providers/auth_provider.dart';
import '../routes/app_routes.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final rideProvider = Provider.of<RideProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Covoiturage - Chauffeur'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.profile);
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.rideHistory);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Statistiques du chauffeur
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(Icons.star, '4.8', 'Note'),
                  _buildStatItem(Icons.directions_car, '24', 'Trajets'),
                  _buildStatItem(Icons.attach_money, '580€', 'Revenus'),
                ],
              ),
            ),
          ),

          // Actions rapides
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: [
                _buildActionCard(
                  Icons.add_circle,
                  'Proposer un trajet',
                  Colors.blue,
                  () {
                    Navigator.pushNamed(context, AppRoutes.createRide);
                  },
                ),
                _buildActionCard(
                  Icons.schedule,
                  'Trajets planifiés',
                  Colors.orange,
                  () {
                    Navigator.pushNamed(context, AppRoutes.scheduledRides);
                  },
                ),
                _buildActionCard(
                  Icons.history,
                  'Historique',
                  Colors.green,
                  () {
                    Navigator.pushNamed(context, AppRoutes.rideHistory);
                  },
                ),
                _buildActionCard(
                  Icons.bar_chart,
                  'Statistiques',
                  Colors.purple,
                  () {
                    Navigator.pushNamed(context, AppRoutes.stats);
                  },
                ),
              ],
            ),
          ),

          // Trajet en cours
          if (rideProvider.currentRide != null) ...[
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Trajet en cours',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Card(
              margin: const EdgeInsets.all(16),
              child: ListTile(
                leading: const Icon(Icons.directions_car, color: Colors.green),
                title: Text('Vers ${rideProvider.currentRide!.endAddress}'),
                subtitle: Text('Statut: ${rideProvider.currentRide!.status}'),
                trailing: Chip(
                  label: Text('${rideProvider.currentRide!.price}€'),
                  backgroundColor: Colors.green[100],
                ),
              ),
            ),
          ],

          // Derniers trajets
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Dernières demandes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: rideProvider.availableRides.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.car_rental, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Aucune demande de trajet',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: rideProvider.availableRides.length,
                    itemBuilder: (context, index) {
                      final ride = rideProvider.availableRides[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          leading: const Icon(Icons.person, color: Colors.blue),
                          title: Text('Trajet vers ${ride.endAddress}'),
                          subtitle: Text('${ride.distance} km - ${ride.price}€'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check, color: Colors.green),
                                onPressed: () {
                                  // Accepter le trajet
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.red),
                                onPressed: () {
                                  // Refuser le trajet
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 30, color: Colors.blue),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildActionCard(IconData icon, String text, Color color, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 8),
              Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}