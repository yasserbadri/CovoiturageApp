import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import '../widgets/custom_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Accueil Covoiturage"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Carte rapide
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.map, size: 50, color: Colors.blue),
                    const SizedBox(height: 10),
                    const Text(
                      "Trouver un trajet",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    CustomButton(
                      text: "Ouvrir la carte",
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.map),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Actions rapides
            const Text(
              "Actions rapides",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: [
                _buildActionCard(Icons.history, "Historique", () {}),
                _buildActionCard(Icons.star, "Notes", () {}),
                _buildActionCard(Icons.payment, "Paiements", () {}),
                _buildActionCard(Icons.help, "Aide", () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(IconData icon, String text, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: Colors.blue),
              const SizedBox(height: 8),
              Text(text, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}