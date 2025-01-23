import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final supabaseClient = Supabase.instance.client;
  String? userEmail;
  bool isLoading = true;
  String? errorMessage;
  XFile? _image;

  @override
  void initState() {
    super.initState();
    _getUserEmail();
  }

  Future<void> _getUserEmail() async {
    try {
      final currentUser = supabaseClient.auth.currentUser;
      if (currentUser == null || currentUser.email == null) {
        setState(() {
          errorMessage = 'Aucun utilisateur connecté ou email manquant.';
          isLoading = false;
        });
        return;
      }

      setState(() {
        userEmail = currentUser.email!;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Erreur lors de la récupération de l\'email: $e';
        isLoading = false;
      });
    }
  }

  void _logout() async {
    try {
      await supabaseClient.auth.signOut();
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      setState(() {
        errorMessage = 'Erreur lors de la déconnexion : $e';
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = image;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtention des dimensions de l'écran
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mon Profil',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Color(0xFF293293), // Couleur #293293
        elevation: 5.0,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.grey[50], // Fond gris clair
        padding: EdgeInsets.all(20.0),
        child: Center(
          child: isLoading
              ? CircularProgressIndicator(color: Color(0xFF293293))
              : errorMessage != null
              ? Text(
            errorMessage!,
            style: TextStyle(color: Colors.red, fontSize: 16),
          )
              : SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar avec animation
                GestureDetector(
                  onTap: _pickImage,
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    width: screenWidth * 0.4,
                    height: screenWidth * 0.4,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[200],
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: _image != null
                          ? Image.file(
                        File(_image!.path),
                        fit: BoxFit.cover,
                      )
                          : Icon(
                        Icons.person,
                        size: screenWidth * 0.2,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.03), // Taille dynamique

                // Section Email
                _buildSection(
                  title: 'Email de l\'utilisateur',
                  content: userEmail ?? 'Chargement...',
                  icon: Icons.email,
                ),
                SizedBox(height: screenHeight * 0.03),

                // Section Informations supplémentaires
                _buildSectionTitle('Informations supplémentaires'),
                SizedBox(height: screenHeight * 0.02),
                _buildInfoCard('Nom: John Doe', Icons.person),
                SizedBox(height: screenHeight * 0.02),
                _buildInfoCard('Description: Développeur mobile', Icons.description),
                SizedBox(height: screenHeight * 0.05),

                // Boutons d'action
                _buildCustomButton(
                  label: 'Changer mot de passe',
                  onPressed: _navigateToChangePassword,
                  color: Color(0xFF293293),
                  icon: Icons.lock,
                ),
                SizedBox(height: screenHeight * 0.02),
                _buildCustomButton(
                  label: 'Déconnexion',
                  onPressed: _logout,
                  color: Colors.red[400]!,
                  icon: Icons.logout,
                ),
                SizedBox(height: screenHeight * 0.02),
                _buildCustomButton(
                  label: 'Supprimer le compte',
                  onPressed: _deleteAccount,
                  color: Colors.blueGrey[400]!,
                  icon: Icons.delete_forever,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Méthode pour construire une section
  Widget _buildSection({required String title, required String content, required IconData icon}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[300]!,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, size: 24, color: Color(0xFF293293)),
              SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(fontSize: 16, color: Colors.grey[700], fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            content,
            style: TextStyle(fontSize: 18, color: Color(0xFF293293), fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // Méthode pour construire un titre de section
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF293293)),
    );
  }

  // Méthode pour construire une carte d'information
  Widget _buildInfoCard(String text, IconData icon) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[300]!,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 30, color: Color(0xFF293293)),
          SizedBox(width: 15),
          Text(
            text,
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  // Méthode pour construire un bouton personnalisé
  Widget _buildCustomButton({
    required String label,
    required VoidCallback onPressed,
    required Color color,
    required IconData icon,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(
        label,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: Size(double.infinity, 55),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 6.0,
        padding: EdgeInsets.symmetric(vertical: 15),
        shadowColor: color.withOpacity(0.3),
      ),
    );
  }

  // Méthode pour naviguer vers la page de changement de mot de passe
  void _navigateToChangePassword() {
    Navigator.pushNamed(context, '/pass_page');
  }

  // Méthode pour supprimer le compte
  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Supprimer le compte',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text('Êtes-vous sûr de vouloir supprimer votre compte ? Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Annuler', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Confirmer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        errorMessage = 'La suppression de compte nécessite une API sécurisée.';
      });
    }
  }
}