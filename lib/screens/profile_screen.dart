import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../routes/app_routes.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  String? _selectedImagePath;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      try {
        // Charger l'utilisateur si pas déjà fait
        if (authProvider.user == null) {
          await authProvider.loadCurrentUser();
        }
        
        setState(() {
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
          _error = 'Erreur lors du chargement du profil';
        });
      }
    });
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImagePath = image.path;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo de profil mise à jour')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la sélection de l\'image')),
      );
    }
  }

  void _showEditProfileDialog() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    
    if (user == null) return;

    TextEditingController nameController = TextEditingController(text: user.name);
    TextEditingController emailController = TextEditingController(text: user.email);
    TextEditingController phoneController = TextEditingController(text: user.phone ?? '');
    TextEditingController vehicleTypeController = TextEditingController(text: user.vehicleType ?? '');
    TextEditingController licensePlateController = TextEditingController(text: user.licensePlate ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier le profil'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Photo de profil
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.blue,
                      backgroundImage: _selectedImagePath != null
                          ? FileImage(File(_selectedImagePath!))
                          : null,
                      child: _selectedImagePath == null
                          ? const Icon(Icons.person, size: 40, color: Colors.white)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Champs d'édition
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom complet',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Téléphone',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),

              // Champs spécifiques chauffeur
              if (user.userType == 'chauffeur') ...[
                const SizedBox(height: 16),
                const Text(
                  'Informations véhicule',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                
                TextField(
                  controller: vehicleTypeController,
                  decoration: const InputDecoration(
                    labelText: 'Type de véhicule',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                
                TextField(
                  controller: licensePlateController,
                  decoration: const InputDecoration(
                    labelText: 'Plaque d\'immatriculation',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profil mis à jour (simulation)')),
              );
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
  }

  void _logout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    
    Navigator.pushReplacementNamed(context, AppRoutes.login);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Déconnexion réussie')),
    );
  }

  void _retryLoading() {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    // État de chargement
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text("Profil")),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Chargement du profil...'),
            ],
          ),
        ),
      );
    }

    // État d'erreur
    if (_error != null || user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Profil")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _error ?? 'Utilisateur non connecté',
                style: const TextStyle(fontSize: 16, color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _retryLoading,
                child: const Text('Réessayer'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: _logout,
                child: const Text('Se connecter'),
              ),
            ],
          ),
        ),
      );
    }

    // État normal - utilisateur connecté
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _showEditProfileDialog,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Paramètres - Fonctionnalité à venir 🚧')),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // En-tête du profil
          Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.blue,
                      backgroundImage: _selectedImagePath != null
                          ? FileImage(File(_selectedImagePath!))
                          : null,
                      child: _selectedImagePath == null
                          ? const Icon(Icons.person, size: 50, color: Colors.white)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                user.name,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                user.email,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Chip(
                label: Text(
                  user.userType == 'chauffeur' ? 'Chauffeur' : 'Passager',
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: user.userType == 'chauffeur' ? Colors.orange : Colors.blue,
              ),
            ],
          ),
          
          const SizedBox(height: 30),

          // Informations utilisateur
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informations personnelles',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoItem('Nom', user.name),
                  _buildInfoItem('Email', user.email),
                  if (user.phone != null && user.phone!.isNotEmpty)
                    _buildInfoItem('Téléphone', user.phone!),
                  if (user.userType == 'chauffeur') ...[
                    if (user.vehicleType != null && user.vehicleType!.isNotEmpty)
                      _buildInfoItem('Véhicule', user.vehicleType!),
                    if (user.licensePlate != null && user.licensePlate!.isNotEmpty)
                      _buildInfoItem('Plaque', user.licensePlate!),
                  ],
                  if (user.rating != null)
                    _buildInfoItem('Note moyenne', '${user.rating!.toStringAsFixed(1)}/5'),
                  if (user.totalRides != null)
                    _buildInfoItem('Trajets effectués', '${user.totalRides}'),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),

          // Options du profil
          _buildProfileOption(Icons.person, "Modifier le profil", _showEditProfileDialog),
          _buildProfileOption(Icons.history, "Historique des trajets", () {
            Navigator.pushNamed(context, AppRoutes.rideHistory);
          }),
          if (user.userType == 'chauffeur')
            _buildProfileOption(Icons.star, "Mes avis et notations", () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Avis - Fonctionnalité à venir 🚧')),
              );
            }),
          _buildProfileOption(Icons.payment, "Méthodes de paiement", () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Paiements - Fonctionnalité à venir 🚧')),
            );
          }),
          _buildProfileOption(Icons.help, "Centre d'aide", () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Aide - Fonctionnalité à venir 🚧')),
            );
          }),
          _buildProfileOption(Icons.security, "Confidentialité", () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Confidentialité - Fonctionnalité à venir 🚧')),
            );
          }),
          _buildProfileOption(Icons.logout, "Déconnexion", _showLogoutDialog,
            isDestructive: true),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String text, VoidCallback onTap, {bool isDestructive = false}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: isDestructive ? Colors.red : null),
        title: Text(
          text,
          style: TextStyle(color: isDestructive ? Colors.red : null),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}