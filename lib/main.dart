import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'routes/app_routes.dart';

void main() {
  runApp(const CovoiturageApp());
}

class CovoiturageApp extends StatelessWidget {
  const CovoiturageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Covoiturage App',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      initialRoute: AppRoutes.login,
      routes: AppRoutes.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}
