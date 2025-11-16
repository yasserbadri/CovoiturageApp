/*import 'package:covoituragesite/providers/auth_provider.dart';
import 'package:covoituragesite/routes/app_routes.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.initialize();

    // Rediriger vers l'écran approprié
    if (authProvider.isLoggedIn) {
      if (authProvider.userType == 'chauffeur') {
        Navigator.pushReplacementNamed(context, AppRoutes().driverHome);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.clientHome);
      }
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_car, size: 80, color: Colors.blue),
            SizedBox(height: 20),
            Text(
              'Covoiturage',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}*/