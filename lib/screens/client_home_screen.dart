import 'package:covoituragesite/models/ride.dart';
import 'package:covoituragesite/providers/rating_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ride_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import '../widgets/ride_card.dart';
import '../routes/app_routes.dart';
import '../services/api_service.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  final TextEditingController _departController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRides();
  }

  void _loadRides() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final rideProvider = Provider.of<RideProvider>(context, listen: false);
      final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
      
      print('🔄 Chargement des trajets disponibles...');
      rideProvider.loadAvailableRides().then((_) {
        print('✅ Trajets chargés: ${rideProvider.availableRides.length}');
        rideProvider.availableRides.forEach((ride) {
          print('   - ${ride.startAddress} → ${ride.endAddress} (${ride.price}€)');
        });
      });

      // Charger les trajets de l'utilisateur
      notificationProvider.loadUserRides();
    });
  }

  void _searchRides() {
    final rideProvider = Provider.of<RideProvider>(context, listen: false);
    
    if (_departController.text.isEmpty && _destinationController.text.isEmpty) {
      // Si les champs sont vides, charger tous les trajets
      rideProvider.loadAvailableRides();
    } else {
      // Filtrer les trajets localement (pour l'instant)
      // Plus tard, vous pourrez implémenter une recherche backend
      _filterRidesLocally();
    }
  }

  void _filterRidesLocally() {
    final rideProvider = Provider.of<RideProvider>(context, listen: false);
    final filteredRides = rideProvider.availableRides.where((ride) {
      final matchesDepart = _departController.text.isEmpty || 
          ride.startAddress.toLowerCase().contains(_departController.text.toLowerCase());
      final matchesDestination = _destinationController.text.isEmpty || 
          ride.endAddress.toLowerCase().contains(_destinationController.text.toLowerCase());
      return matchesDepart && matchesDestination;
    }).toList();

    // Pour l'instant, on filtre juste localement
    // Vous verrez les résultats en temps réel grâce au Provider
  }

  // Dans ClientHomeScreen, ajoutez cette méthode :
void _showRatingDialog(Ride ride) {
  int selectedRating = 5;
  TextEditingController commentController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: const Text('Noter le trajet'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Comment s\'est passé votre trajet avec ${ride.driverName ?? 'le chauffeur'} ?',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                
                // Étoiles de notation
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      onPressed: () {
                        setState(() {
                          selectedRating = index + 1;
                        });
                      },
                      icon: Icon(
                        index < selectedRating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 40,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 10),
                Text(
                  '$selectedRating / 5 étoiles',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                
                const SizedBox(height: 20),
                TextField(
                  controller: commentController,
                  decoration: const InputDecoration(
                    labelText: 'Commentaire (optionnel)',
                    border: OutlineInputBorder(),
                    hintText: 'Partagez votre expérience...',
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                final ratingProvider = Provider.of<RatingProvider>(context, listen: false);
                final success = await ratingProvider.createRating(
                  ride.id, 
                  selectedRating, 
                  commentController.text.isNotEmpty ? commentController.text : null
                );
                
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Merci pour votre notation ! 🌟')),
                  );
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Erreur lors de l\'envoi de la notation')),
                  );
                }
              },
              child: const Text('Envoyer la notation'),
            ),
          ],
        );
      },
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final rideProvider = Provider.of<RideProvider>(context);
    final notificationProvider = Provider.of<NotificationProvider>(context);

    // Filtrer les trajets selon la recherche
    final filteredRides = _getFilteredRides(rideProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Covoiturage - Passager'),
        actions: [
          // Badge de notification pour les trajets acceptés
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.history),
                onPressed: () {
                  _showMyRidesDialog(notificationProvider);
                },
              ),
              if (notificationProvider.userRides.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                    child: Text(
                      '${notificationProvider.userRides.length}',
                      style: const TextStyle(
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
          _buildSearchHeader(),

          // Mes trajets en cours
          if (notificationProvider.inProgressRides.isNotEmpty) ...[
            _buildMyCurrentRides(notificationProvider),
          ],

          // Liste des trajets disponibles
          Expanded(
            child: rideProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredRides.isEmpty
                    ? _buildEmptyState(rideProvider)
                    : _buildRidesList(rideProvider, filteredRides),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActions(rideProvider, notificationProvider),
    );
  }

  Widget _buildSearchHeader() {
    return Padding(
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
                      controller: _departController,
                      decoration: InputDecoration(
                        labelText: 'Départ',
                        prefixIcon: const Icon(Icons.location_on, color: Colors.red),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) => _searchRides(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _destinationController,
                      decoration: InputDecoration(
                        labelText: 'Destination',
                        prefixIcon: const Icon(Icons.location_on, color: Colors.green),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) => _searchRides(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.map);
                      },
                      child: const Text('Rechercher sur la carte'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      _departController.clear();
                      _destinationController.clear();
                      _searchRides();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Effacer'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyCurrentRides(NotificationProvider notificationProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.directions_car, color: Colors.green),
              SizedBox(width: 8),
              Text(
                'Mes trajets en cours',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...notificationProvider.inProgressRides.map((ride) => 
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              color: Colors.green[50],
              child: ListTile(
                leading: const Icon(Icons.directions_car, color: Colors.green),
                title: Text('Vers ${ride.endAddress}'),
                subtitle: Text('Chauffeur: ${ride.driverName ?? 'Inconnu'} - ${ride.price}€'),
                trailing: const Chip(
                  label: Text('En cours', style: TextStyle(color: Colors.white)),
                  backgroundColor: Colors.green,
                ),
              ),
            )
          ).toList(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildEmptyState(RideProvider rideProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.car_rental, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Aucun trajet disponible',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          if (_departController.text.isNotEmpty || _destinationController.text.isNotEmpty)
            Text(
              'Aucun résultat pour votre recherche',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _departController.clear();
              _destinationController.clear();
              rideProvider.loadAvailableRides();
            },
            child: const Text('Voir tous les trajets'),
          ),
        ],
      ),
    );
  }

  Widget _buildRidesList(RideProvider rideProvider, List<Ride> rides) {
    return RefreshIndicator(
      onRefresh: () async {
        await rideProvider.loadAvailableRides();
      },
      child: ListView.builder(
        itemCount: rides.length,
        itemBuilder: (context, index) {
          final ride = rides[index];
          return RideCard(
            ride: ride,
            onAccept: () {
              _acceptRide(ride.id);
            },
          );
        },
      ),
    );
  }

  Widget _buildFloatingActions(RideProvider rideProvider, NotificationProvider notificationProvider) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          onPressed: () {
            rideProvider.loadAvailableRides();
            notificationProvider.loadUserRides();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Actualisation des données')),
            );
          },
          heroTag: "refresh_all",
          mini: true,
          child: const Icon(Icons.refresh),
        ),
        const SizedBox(height: 8),
        FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.map);
          },
          heroTag: "open_map",
          child: const Icon(Icons.map),
        ),
      ],
    );
  }

  List<Ride> _getFilteredRides(RideProvider rideProvider) {
    if (_departController.text.isEmpty && _destinationController.text.isEmpty) {
      return rideProvider.availableRides;
    }

    return rideProvider.availableRides.where((ride) {
      final matchesDepart = _departController.text.isEmpty || 
          ride.startAddress.toLowerCase().contains(_departController.text.toLowerCase());
      final matchesDestination = _destinationController.text.isEmpty || 
          ride.endAddress.toLowerCase().contains(_destinationController.text.toLowerCase());
      return matchesDepart && matchesDestination;
    }).toList();
  }

  void _acceptRide(String rideId) async {
    final rideProvider = Provider.of<RideProvider>(context, listen: false);
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    
    final success = await rideProvider.acceptRide(rideId);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trajet accepté avec succès! 🎉')),
      );
      
      // Recharger les données
      await rideProvider.loadAvailableRides();
      await notificationProvider.loadUserRides();
      
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de l\'acceptation du trajet')),
      );
    }
  }

  void _showMyRidesDialog(NotificationProvider notificationProvider) {
    final myRides = notificationProvider.userRides;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mes trajets'),
        content: SizedBox(
          width: double.maxFinite,
          child: myRides.isEmpty
              ? const Center(child: Text('Aucun trajet', style: TextStyle(color: Colors.grey)))
              : ListView(
                  shrinkWrap: true,
                  children: [
                    if (notificationProvider.inProgressRides.isNotEmpty) ...[
                      const Text('En cours:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                      ...notificationProvider.inProgressRides.map(_buildRideListTile).toList(),
                      const SizedBox(height: 16),
                    ],
                    if (notificationProvider.acceptedRides.isNotEmpty) ...[
                      const Text('Acceptés:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                      ...notificationProvider.acceptedRides.map(_buildRideListTile).toList(),
                      const SizedBox(height: 16),
                    ],
                    if (notificationProvider.completedRides.isNotEmpty) ...[
                      const Text('Terminés:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                      ...notificationProvider.completedRides.map(_buildRideListTile).toList(),
                    ],
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

  // Dans _buildMyRidesDialog, ajoutez cette option pour les trajets terminés non notés
Widget _buildRideListTile(Ride ride) {
  final canRate = ride.status == 'completed' && !_hasRatedRide(ride.id);
  
  return Card(
    margin: const EdgeInsets.only(bottom: 8),
    child: ListTile(
      leading: _getStatusIcon(ride.status),
      title: Text('${ride.startAddress} → ${ride.endAddress}'),
      subtitle: Text('${ride.price}€ - ${_getStatusText(ride.status)}'),
      trailing: canRate
          ? ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showRatingDialog(ride);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.white,
              ),
              child: const Text('Noter'),
            )
          : Text(
              _getStatusText(ride.status),
              style: TextStyle(
                color: _getStatusColor(ride.status),
                fontWeight: FontWeight.bold,
              ),
            ),
    ),
  );
}

bool _hasRatedRide(String rideId) {
  // Vérifier si l'utilisateur a déjà noté ce trajet
  final ratingProvider = Provider.of<RatingProvider>(context, listen: false);
  return ratingProvider.userRatings.any((rating) => rating.rideId == rideId);
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

  @override
  void dispose() {
    _departController.dispose();
    _destinationController.dispose();
    super.dispose();
  }
}