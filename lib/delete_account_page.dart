import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DeleteAccountPage extends StatelessWidget {
  final SupabaseClient supabaseClient = Supabase.instance.client;

  // Fonction pour supprimer le compte de l'utilisateur actuel
  Future<void> deleteAccount(BuildContext context) async {
    final user = supabaseClient.auth.currentUser;
    if (user != null) {
      try {
        // Déconnexion de l'utilisateur
        await supabaseClient.auth.signOut();

        // Après la déconnexion, redirige vers la page de connexion
        Navigator.pushReplacementNamed(context, '/login');
      } catch (e) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Erreur'),
            content: Text('Une erreur est survenue lors de la suppression du compte.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Fermer'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;  // Récupérer la taille de l'écran

    return Scaffold(
      appBar: AppBar(
        title: Text('Supprimer le compte'),
      ),
      body: Padding(
        padding: EdgeInsets.all(screenSize.width * 0.05),  // Utiliser 5% de la largeur de l'écran pour le padding
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Êtes-vous sûr de vouloir supprimer votre compte ? Cette action est irréversible.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: screenSize.width * 0.05),  // Ajuster la taille du texte selon la taille de l'écran
            ),
            SizedBox(height: screenSize.height * 0.05),  // Utiliser 5% de la hauteur de l'écran pour l'espacement
            ElevatedButton(
              onPressed: () => deleteAccount(context),
              child: Text('Supprimer le compte'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,  // Utilisation de 'backgroundColor' au lieu de 'primary'
                padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.2, vertical: 16),  // Ajuster la largeur du bouton
              ),
            ),
          ],
        ),
      ),
    );
  }
}
