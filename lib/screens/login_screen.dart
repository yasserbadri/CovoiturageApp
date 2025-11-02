import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/custom_button.dart';
import '../services/api_service.dart';
import '../models/user.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkBackendConnection();
  }

  void _checkBackendConnection() async {
    final isConnected = await ApiService.checkConnection();
    if (!isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Backend non accessible - Vérifiez que le serveur est démarré'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    setState(() => isLoading = true);

    final result = await ApiService.login(
      emailController.text.trim(),
      passwordController.text,
    );

    setState(() => isLoading = false);

    if (result != null) {
      final user = result['user'] as User;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connexion réussie! Bienvenue ${user.name}')),
      );
      
      // Redirection selon le rôle
      _redirectBasedOnRole(user);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Échec de la connexion')),
      );
    }
  }

  void _redirectBasedOnRole(User user) {
    if (user.userType == 'chauffeur') {
      // Rediriger vers l'écran chauffeur
      Navigator.pushReplacementNamed(context, AppRoutes.driverHome);
    } else {
      // Rediriger vers l'écran client (par défaut)
      Navigator.pushReplacementNamed(context, AppRoutes.clientHome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.directions_car, size: 80, color: Colors.blue),
                const SizedBox(height: 20),
                const Text(
                  "Connexion",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),
                CustomTextField(
                  controller: emailController,
                  label: "Email",
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: passwordController,
                  label: "Mot de passe",
                  obscureText: true,
                ),
                const SizedBox(height: 30),
                if (isLoading)
                  const CircularProgressIndicator()
                else
                  CustomButton(
                    text: "Se connecter",
                    onPressed: _login,
                  ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.register);
                  },
                  child: const Text("Créer un compte"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}