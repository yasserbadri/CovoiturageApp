import 'package:flutter/material.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/custom_button.dart';
import '../routes/app_routes.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text("Créer un compte")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CustomTextField(controller: nameController, label: "Nom complet"),
            const SizedBox(height: 20),
            CustomTextField(controller: emailController, label: "Email"),
            const SizedBox(height: 20),
            CustomTextField(controller: passwordController, label: "Mot de passe", obscure: true),
            const SizedBox(height: 30),
            CustomButton(
              text: "S'inscrire",
              onPressed: () {
                Navigator.pushReplacementNamed(context, AppRoutes.home);
              },
            ),
          ],
        ),
      ),
    );
  }
}
