import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NvmdpPage extends StatefulWidget {
  final String? token;  // Le token de réinitialisation du mot de passe passé dans l'URL

  NvmdpPage({Key? key, this.token}) : super(key: key);

  @override
  _NvmdpPageState createState() => _NvmdpPageState();
}

class _NvmdpPageState extends State<NvmdpPage> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  // Fonction pour réinitialiser le mot de passe
  Future<void> _resetPassword() async {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        _errorMessage = "Les champs de mot de passe ne peuvent pas être vides.";
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _errorMessage = "Les mots de passe ne correspondent pas.";
      });
      return;
    }

    if (password.length < 6) {  // Exemple de validation de sécurité
      setState(() {
        _errorMessage = "Le mot de passe doit contenir au moins 6 caractères.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Vérification du token
      if (widget.token == null || widget.token!.isEmpty) {
        setState(() {
          _errorMessage = "Token invalide. Essayez de nouveau.";
          _isLoading = false;
        });
        return;
      }

      // Utiliser la méthode de réinitialisation du mot de passe pour un email lié à un utilisateur
      final response = await Supabase.instance.client.auth.api
          .resetPasswordForEmail(widget.token!); // Utiliser un email ici, pas de 'newPassword'

      if (response.error != null) {
        setState(() {
          _errorMessage = response.error!.message;
          _isLoading = false;
        });
      } else {
        // Mot de passe réinitialisé avec succès
        setState(() {
          _isLoading = false;
        });
        // Rediriger vers la page de connexion ou afficher un message de succès
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Une erreur est survenue. Essayez encore.";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;  // Récupérer la taille de l'écran

    return Scaffold(
      appBar: AppBar(
        title: const Text("Réinitialiser le mot de passe"),
      ),
      body: Padding(
        padding: EdgeInsets.all(screenSize.width * 0.05),  // Utiliser 5% de la largeur de l'écran pour le padding
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Nouveau mot de passe",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Confirmer le mot de passe",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _resetPassword,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.1, vertical: 15),
                textStyle: TextStyle(fontSize: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Réinitialiser le mot de passe"),
            ),
          ],
        ),
      ),
    );
  }
}