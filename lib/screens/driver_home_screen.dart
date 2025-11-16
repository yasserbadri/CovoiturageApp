import 'package:covoituragesite/models/ride.dart';
import 'package:covoituragesite/providers/rating_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ride_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import '../routes/app_routes.dart';
import '../services/api_service.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final rideProvider = Provider.of<RideProvider>(context, listen: false);
      final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
      final ratingProvider = Provider.of<RatingProvider>(context, listen: false);

      rideProvider.loadUserRides();
      notificationProvider.loadUserRides();
      ratingProvider.loadUserRatings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final rideProvider = Provider.of<RideProvider>(context);
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final ratingProvider = Provider.of<RatingProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Covoiturage - Chauffeur'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  _showAllRidesDialog(notificationProvider);
                },
              ),
              if (notificationProvider.hasNewNotification)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                    child: const Text(
                      '!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
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
      body: RefreshIndicator(
        onRefresh: () async {
          final rideProvider = Provider.of<RideProvider>(context, listen: false);
          final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
          final ratingProvider = Provider.of<RatingProvider>(context, listen: false);
          await rideProvider.loadUserRides();
          await notificationProvider.loadUserRides();
          await ratingProvider.loadUserRatings();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Bannière de notification
              if (notificationProvider.hasNewNotification)
                _buildNotificationBanner(notificationProvider),

              // Statistiques du chauffeur
              _buildDriverStats(notificationProvider, ratingProvider),
              
              // Section des notes
              _buildRatingSection(ratingProvider),

              // Actions rapides
              _buildQuickActions(),

              // Trajets en cours
              if (notificationProvider.inProgressRides.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildSectionTitle('Trajets en Cours', Icons.directions_car, Colors.green),
                _buildRidesList(notificationProvider.inProgressRides, 'in_progress'),
              ],

              // Trajets acceptés
              if (notificationProvider.acceptedRides.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildSectionTitle('Trajets Acceptés', Icons.person, Colors.orange),
                _buildRidesList(notificationProvider.acceptedRides, 'accepted'),
              ],

              // Trajets terminés (limité à 3 derniers)
              if (notificationProvider.completedRides.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildSectionTitle('Derniers Trajets Terminés', Icons.check_circle, Colors.blue),
                _buildRidesList(
                  notificationProvider.completedRides.take(3).toList(), 
                  'completed'
                ),
              ],

              // Demandes de trajets disponibles
              const SizedBox(height: 16),
              _buildSectionTitle('Demandes de Trajets', Icons.request_quote, Colors.purple),
              _buildRideRequestsSection(rideProvider),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final rideProvider = Provider.of<RideProvider>(context, listen: false);
          final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
          final ratingProvider = Provider.of<RatingProvider>(context, listen: false);

          rideProvider.loadUserRides();
          notificationProvider.loadUserRides();
          ratingProvider.loadUserRatings();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Actualisation des données')),
          );
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildNotificationBanner(NotificationProvider notificationProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: Colors.green.withOpacity(0.1),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${notificationProvider.acceptedRides.length} nouveau(x) trajet(s) accepté(s) !',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              _showAllRidesDialog(notificationProvider);
            },
            child: const Text('Voir'),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverStats(NotificationProvider notificationProvider, RatingProvider ratingProvider) {
    final totalRides = notificationProvider.userRides.length;
    final completedRides = notificationProvider.completedRides.length;
    final totalEarnings = notificationProvider.completedRides
        .fold(0.0, (sum, ride) => sum + (ride.price));

    // Utiliser la vraie note moyenne
    final averageRating = ratingProvider.userRatings.isNotEmpty 
        ? ratingProvider.averageRating.toStringAsFixed(1)
        : '0.0';

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(Icons.star, averageRating, 'Note'),
            _buildStatItem(Icons.directions_car, '$totalRides', 'Trajets'),
            _buildStatItem(Icons.attach_money, '${totalEarnings.toStringAsFixed(0)}€', 'Revenus'),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSection(RatingProvider ratingProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.star, color: Colors.amber),
                  SizedBox(width: 8),
                  Text(
                    'Mes Notes',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              if (ratingProvider.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (ratingProvider.userRatings.isEmpty)
                const Text(
                  'Aucune note pour le moment',
                  style: TextStyle(color: Colors.grey),
                )
              else ...[
                // Note moyenne
                Row(
                  children: [
                    Text(
                      ratingProvider.averageRating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.star, color: Colors.amber, size: 24),
                    const SizedBox(width: 16),
                    Text(
                      '(${ratingProvider.userRatings.length} avis)',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Derniers avis
                ...ratingProvider.recentRatings.map((rating) => 
                  Column(
                    children: [
                      Row(
                        children: [
                          // Étoiles
                          Row(
                            children: List.generate(5, (index) => 
                              Icon(
                                Icons.star,
                                size: 16,
                                color: index < rating.rating ? Colors.amber : Colors.grey[300],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Par ${rating.fromUserName ?? 'Utilisateur'}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      if (rating.comment != null && rating.comment!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          rating.comment!,
                          style: const TextStyle(fontSize: 14),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 8),
                    ],
                  )
                ).toList(),
                
                // Voir tous les avis
                if (ratingProvider.userRatings.length > 5)
                  TextButton(
                    onPressed: () {
                      _showAllRatingsDialog(ratingProvider);
                    },
                    child: const Text('Voir tous les avis'),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
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
            Icons.history,
            'Historique complet',
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
              _showComingSoonSnackbar();
            },
          ),
          _buildActionCard(
            Icons.settings,
            'Paramètres',
            Colors.orange,
            () {
              _showComingSoonSnackbar();
            },
          ),
        ],
      ),
    );
  }

  // ... Les autres méthodes restent inchangées
  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRidesList(List<Ride> rides, String status) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: rides.map((ride) => _buildRideCard(ride, status)).toList(),
      ),
    );
  }

  Widget _buildRideCard(Ride ride, String status) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: _getStatusIcon(ride.status),
        title: Text(
          '${ride.startAddress} → ${ride.endAddress}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (ride.passengerId != null)
              Text('Passager ID: ${ride.passengerId}'),
            Text('${ride.distance?.toStringAsFixed(1) ?? '0'} km - ${ride.price}€'),
            Text(
              'Statut: ${_getStatusText(ride.status)}',
              style: TextStyle(
                color: _getStatusColor(ride.status),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: _buildRideActions(ride),
      ),
    );
  }

  Widget _buildRideRequestsSection(RideProvider rideProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: rideProvider.availableRides.isEmpty
          ? _buildEmptyState()
          : Column(
              children: rideProvider.availableRides.map((ride) => 
                Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.person, color: Colors.blue),
                    title: Text('${ride.startAddress} → ${ride.endAddress}'),
                    subtitle: Text('${ride.distance?.toStringAsFixed(1) ?? '0'} km - ${ride.price}€'),
                    trailing: IconButton(
                      icon: const Icon(Icons.info, color: Colors.blue),
                      onPressed: () {
                        _showRideDetails(ride);
                      },
                    ),
                  ),
                )
              ).toList(),
            ),
    );
  }

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(Icons.car_rental, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Aucune demande de trajet',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _getStatusIcon(String status) {
    switch (status) {
      case 'accepted':
        return const Icon(Icons.person, color: Colors.orange);
      case 'in_progress':
        return const Icon(Icons.directions_car, color: Colors.green);
      case 'completed':
        return const Icon(Icons.check_circle, color: Colors.blue);
      case 'cancelled':
        return const Icon(Icons.cancel, color: Colors.red);
      default:
        return const Icon(Icons.pending, color: Colors.grey);
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'accepted':
        return 'Accepté';
      case 'in_progress':
        return 'En cours';
      case 'completed':
        return 'Terminé';
      case 'cancelled':
        return 'Annulé';
      default:
        return 'En attente';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'accepted':
        return Colors.orange;
      case 'in_progress':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildRideActions(Ride ride) {
    switch (ride.status) {
      case 'accepted':
        return ElevatedButton(
          onPressed: () => _startRide(ride.id),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: const Text('Démarrer'),
        );
      case 'in_progress':
        return ElevatedButton(
          onPressed: () => _completeRide(ride.id),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: const Text('Terminer'),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _startRide(String rideId) async {
    try {
      final success = await ApiService.updateRideStatus(rideId, 'in_progress');
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trajet démarré ! Bon voyage 🚗')),
        );
        
        final rideProvider = Provider.of<RideProvider>(context, listen: false);
        final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
        final ratingProvider = Provider.of<RatingProvider>(context, listen: false);
        
        await rideProvider.loadUserRides();
        await notificationProvider.loadUserRides();
        await ratingProvider.loadUserRatings();
        
        setState(() {});
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors du démarrage')),
      );
    }
  }

  void _completeRide(String rideId) async {
    try {
      final success = await ApiService.updateRideStatus(rideId, 'completed');
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trajet terminé avec succès ! ✅')),
        );
        
        final rideProvider = Provider.of<RideProvider>(context, listen: false);
        final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
        final ratingProvider = Provider.of<RatingProvider>(context, listen: false);
        
        await rideProvider.loadUserRides();
        await notificationProvider.loadUserRides();
        await ratingProvider.loadUserRatings();
        
        setState(() {});
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la fin du trajet')),
      );
    }
  }

  void _showAllRidesDialog(NotificationProvider notificationProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tous mes trajets'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              if (notificationProvider.inProgressRides.isNotEmpty) ...[
                _buildDialogSection('En cours (${notificationProvider.inProgressRides.length})', notificationProvider.inProgressRides),
              ],
              if (notificationProvider.acceptedRides.isNotEmpty) ...[
                _buildDialogSection('Acceptés (${notificationProvider.acceptedRides.length})', notificationProvider.acceptedRides),
              ],
              if (notificationProvider.completedRides.isNotEmpty) ...[
                _buildDialogSection('Terminés (${notificationProvider.completedRides.length})', notificationProvider.completedRides),
              ],
              if (notificationProvider.userRides.isEmpty) 
                const Center(child: Text('Aucun trajet', style: TextStyle(color: Colors.grey))),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogSection(String title, List<Ride> rides) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ...rides.map((ride) => _buildRideListTile(ride)).toList(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildRideListTile(Ride ride) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: _getStatusIcon(ride.status),
        title: Text('${ride.startAddress} → ${ride.endAddress}'),
        subtitle: Text('${ride.price}€ - ${_getStatusText(ride.status)}'),
        trailing: _buildDialogRideActions(ride),
      ),
    );
  }

  Widget _buildDialogRideActions(Ride ride) {
    switch (ride.status) {
      case 'accepted':
        return ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            _startRide(ride.id);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          child: const Text('Démarrer'),
        );
      case 'in_progress':
        return ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            _completeRide(ride.id);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          child: const Text('Terminer'),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _showRideDetails(Ride ride) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Détails du trajet'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailItem('Départ', ride.startAddress),
              _buildDetailItem('Destination', ride.endAddress),
              _buildDetailItem('Distance', '${ride.distance?.toStringAsFixed(1)} km'),
              _buildDetailItem('Durée', '${ride.duration} min'),
              _buildDetailItem('Prix', '${ride.price}€'),
              _buildDetailItem('Statut', _getStatusText(ride.status)),
              if (ride.passengerId != null)
                _buildDetailItem('Passager ID', ride.passengerId!),
              _buildDetailItem('Date création', _formatDate(ride.createdAt)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 30, color: Colors.blue),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  void _showAllRatingsDialog(RatingProvider ratingProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tous mes avis'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              if (ratingProvider.userRatings.isEmpty)
                const Center(child: Text('Aucun avis', style: TextStyle(color: Colors.grey)))
              else
                ...ratingProvider.userRatings.map((rating) => 
                  Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // Étoiles
                              Row(
                                children: List.generate(5, (index) => 
                                  Icon(
                                    Icons.star,
                                    size: 20,
                                    color: index < rating.rating ? Colors.amber : Colors.grey[300],
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                _formatDate(rating.createdAt),
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Par ${rating.fromUserName ?? 'Utilisateur'}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if (rating.comment != null && rating.comment!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              rating.comment!,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ],
                      ),
                    ),
                  )
                ).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(IconData icon, String text, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
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
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoonSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fonctionnalité à venir 🚧')),
    );
  }
}