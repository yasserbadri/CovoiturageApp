import 'package:flutter/material.dart';
import '../routes/app_routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Accueil")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.map),
              child: const Text("Voir la carte"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
              child: const Text("Profil"),
            ),
          ],
        ),
      ),
    );
  }
}
