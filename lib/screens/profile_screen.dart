import 'package:flutter/material.dart';
import '../routes/app_routes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Naviguer vers les paramètres
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // En-tête du profil
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.blue,
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 16),
          const Text(
            "John Doe", // À remplacer par les vraies données
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Text(
            "john.doe@email.com",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          
          const SizedBox(height: 30),
          
          // Options du profil
          _buildProfileOption(Icons.person, "Informations personnelles", () {}),
          _buildProfileOption(Icons.history, "Historique des trajets", () {}),
          _buildProfileOption(Icons.payment, "Méthodes de paiement", () {}),
          _buildProfileOption(Icons.star, "Avis et notations", () {}),
          _buildProfileOption(Icons.help, "Centre d'aide", () {}),
          _buildProfileOption(Icons.logout, "Déconnexion", () {
            Navigator.pushReplacementNamed(context, AppRoutes.login);
          }),
        ],
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String text, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(text),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}