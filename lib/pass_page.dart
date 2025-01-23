import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PassPage extends StatefulWidget {
  const PassPage({Key? key}) : super(key: key);

  @override
  _PassPageState createState() => _PassPageState();
}

class _PassPageState extends State<PassPage> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String errorMessage = '';
  String successMessage = '';
  bool isLoading = false;

  late final SupabaseClient supabaseClient;

  @override
  void initState() {
    super.initState();
    supabaseClient = Supabase.instance.client;
  }

  Future<void> _changePassword() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
      successMessage = '';
    });

    final oldPassword = _oldPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword != confirmPassword) {
      setState(() {
        errorMessage = 'Les nouveaux mots de passe ne correspondent pas.';
        isLoading = false;
      });
      return;
    }

    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        setState(() {
          errorMessage = 'Vous devez être connecté pour changer votre mot de passe.';
          isLoading = false;
        });
        return;
      }

      // Demande de changement de mot de passe
      final response = await supabaseClient.auth.update(
        UserAttributes(password: newPassword),
      );

      if (response.error != null) {
        setState(() {
          errorMessage = 'Erreur lors de la mise à jour du mot de passe.';
          isLoading = false;
        });
      } else {
        setState(() {
          successMessage = 'Mot de passe changé avec succès!';
          errorMessage = '';
          isLoading = false;
        });
        // Optionnel : redirection après succès
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pop(context); // Retourner à la page précédente (par exemple, la page de profil)
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Erreur lors du changement de mot de passe: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Récupérer la taille de l'écran
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('Changer le mot de passe'),
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05), // Padding adaptable en fonction de la largeur de l'écran
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _oldPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Ancien mot de passe',
                  errorText: errorMessage.isEmpty ? null : errorMessage,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.02, // Ajustement vertical
                    horizontal: screenWidth * 0.05, // Ajustement horizontal
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02), // Espacement adaptable
              TextField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Nouveau mot de passe',
                  contentPadding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.02,
                    horizontal: screenWidth * 0.05,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirmer le mot de passe',
                  contentPadding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.02,
                    horizontal: screenWidth * 0.05,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.03), // Espacement adaptable
              isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _changePassword,
                child: Text('Changer le mot de passe'),
              ),
              if (successMessage.isNotEmpty) ...[
                SizedBox(height: screenHeight * 0.03),
                Text(
                  successMessage,
                  style: TextStyle(color: Colors.green, fontSize: 16),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
