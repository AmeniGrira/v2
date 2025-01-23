import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'settings_page.dart';
import 'contact_service_page.dart';
import 'profile_page.dart';
import 'button_page.dart';

class MyHomePage extends StatefulWidget {
  final Function(bool) onModeChanged;
  final Function(String?) onLanguageChanged;

  MyHomePage({required this.onModeChanged, required this.onLanguageChanged});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Uint8List? _rectoImage;
  Uint8List? _versoImage;
  bool _isRectoSelected = true;
  int _selectedIndex = 1;
  String _result = 'No text detected';
  bool _isProcessing = false;

  final SupabaseClient supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'CIN Recognition',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade900,
        elevation: 4,
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildTitle(),
              SizedBox(height: screenHeight * 0.03),
              _buildImageSelectors(),
              SizedBox(height: screenHeight * 0.03),
              ButtonPage(
                label: 'Insert Image',
                onPressed: _chooseImage,
                color: Colors.blue.shade400,
              ),
              SizedBox(height: screenHeight * 0.02),
              ButtonPage(
                label: 'Validate Images',
                onPressed: _validateImages,
                color: Colors.blue.shade800,
              ),
              SizedBox(height: screenHeight * 0.03),
              _isProcessing
                  ? CircularProgressIndicator(color: Colors.blue.shade800)
                  : _buildResult(),
              SizedBox(height: screenHeight * 0.02),
              _buildImagesAfterValidation(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // Méthode pour afficher le titre
  Widget _buildTitle() {
    return Text(
      'Recognize text on a CIN card (Recto and Verso)',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  // Méthode pour afficher les sélecteurs d'images
  Widget _buildImageSelectors() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildImageSelector(_rectoImage, 'Recto'),
        SizedBox(width: 20),
        _buildImageSelector(_versoImage, 'Verso'),
      ],
    );
  }

  // Méthode pour construire un sélecteur d'image
  Widget _buildImageSelector(Uint8List? imageBytes, String label) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: imageBytes != null
                    ? Image.memory(
                  imageBytes,
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                )
                    : Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 5,
                right: 5,
                child: IconButton(
                  icon: Icon(Icons.cancel, color: Colors.grey),
                  onPressed: () {
                    setState(() {
                      if (label == 'Recto') {
                        _rectoImage = null;
                      } else {
                        _versoImage = null;
                      }
                    });
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // Méthode pour afficher le résultat de la reconnaissance
  Widget _buildResult() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          _result,
          style: TextStyle(fontSize: 16, color: Colors.black87),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // Méthode pour afficher les images après validation
  Widget _buildImagesAfterValidation() {
    return Column(
      children: [
        if (_rectoImage != null) ...[
          Text(
            "Validated recto image:",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          _buildValidatedImage(_rectoImage!, () {
            setState(() {
              _rectoImage = null;
            });
          }),
        ],
        if (_versoImage != null) ...[
          SizedBox(height: 20),
          Text(
            "Validated verso image:",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          _buildValidatedImage(_versoImage!, () {
            setState(() {
              _versoImage = null;
            });
          }),
        ],
      ],
    );
  }

  // Méthode pour construire une image validée
  Widget _buildValidatedImage(Uint8List imageBytes, VoidCallback onRemove) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.memory(
              imageBytes,
              width: 150,
              height: 150,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 5,
            right: 5,
            child: IconButton(
              icon: Icon(Icons.cancel, color: Colors.grey),
              onPressed: onRemove,
            ),
          ),
        ],
      ),
    );
  }

  // Méthode pour construire la barre de navigation inférieure
  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      selectedItemColor: Colors.blue.shade800,
      unselectedItemColor: Colors.grey,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.contact_mail),
          label: 'Contact',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }

  // Méthode pour naviguer vers une autre page
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      _navigateToPage(SettingsPage(
        onModeChanged: widget.onModeChanged,
        onLanguageChanged: widget.onLanguageChanged,
      ));
    } else if (index == 1) {
      _navigateToPage(ContactServicePage());
    } else if (index == 2) {
      _navigateToPage(ProfilePage());
    }
  }

  void _navigateToPage(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  // Méthodes pour la gestion des images et de la reconnaissance OCR
  Future<void> _chooseImage() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choose an image'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera),
                title: Text('Take a photo'),
                onTap: () async {
                  Navigator.pop(context);
                  _takePhoto();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_album),
                title: Text('Choose from gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  _chooseFromGallery();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final imageBytes = await pickedFile.readAsBytes();
      setState(() {
        if (_isRectoSelected) {
          _rectoImage = imageBytes;
        } else {
          _versoImage = imageBytes;
        }
        _isRectoSelected = !_isRectoSelected;
      });
    }
  }

  Future<void> _chooseFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final imageBytes = await pickedFile.readAsBytes();
      setState(() {
        if (_isRectoSelected) {
          _rectoImage = imageBytes;
        } else {
          _versoImage = imageBytes;
        }
        _isRectoSelected = !_isRectoSelected;
      });
    }
  }

  // Fonction pour valider les images et effectuer la reconnaissance OCR
  Future<void> _validateImages() async {
    if (_rectoImage == null || _versoImage == null) {
      _showErrorDialog('Please insert both recto and verso images.');
    } else {
      setState(() {
        _isProcessing = true;
        _result = 'Processing images...'; // Affiche un message pendant le traitement
      });

      // Effectue la reconnaissance OCR sur les images recto et verso
      String rectoText = await _performOCR(_rectoImage!);
      String versoText = await _performOCR(_versoImage!);

      setState(() {
        _result = 'Recognition performed:\nRecto Text: $rectoText\nVerso Text: $versoText'; // Affiche le texte reconnu
        _isProcessing = false;
      });

      // Validation de la CIN
      await _verifyCinDetails(rectoText, versoText);
    }
  }

  // Fonction pour effectuer la reconnaissance OCR sur une image donnée
  Future<String> _performOCR(Uint8List imageBytes) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/temp_image.png');
    await file.writeAsBytes(imageBytes);

    try {
      // Utilise le package Tesseract pour extraire le texte de l'image
      String text = await FlutterTesseractOcr.extractText(
        file.path,
        language: 'fra', // Utilise la langue française pour la reconnaissance
      );
      return text;
    } catch (e) {
      return 'OCR failed: $e'; // En cas d'échec, retourne un message d'erreur
    } finally {
      file.delete(); // Supprime le fichier temporaire
    }
  }

  // Fonction pour valider le numéro de CIN et la date de naissance
  Future<void> _verifyCinDetails(String rectoText, String versoText) async {
    // Recherche du numéro de la CIN et de la date de naissance dans le texte extrait
    String? cinNumber = _extractCinNumber(rectoText);
    String? dateOfBirth = _extractDateOfBirth(rectoText);

    if (cinNumber != null && dateOfBirth != null) {
      // Validation du format du numéro de CIN et de la date de naissance
      if (_isValidCinNumber(cinNumber) && _isValidDateOfBirth(dateOfBirth)) {
        _showSuccessDialog('CIN is valid.\nCIN: $cinNumber\nDate of Birth: $dateOfBirth');
      } else {
        _showErrorDialog('Invalid CIN or Date of Birth format.');
      }
    } else {
      _showErrorDialog('Could not extract valid CIN or Date of Birth.');
    }
  }

  // Fonction pour extraire le numéro de CIN
  String? _extractCinNumber(String text) {
    final regex = RegExp(r'\b\d{8}\b');
    final match = regex.firstMatch(text);
    return match?.group(0); // Renvoie le numéro de CIN s'il est trouvé
  }

  // Fonction pour extraire la date de naissance
  String? _extractDateOfBirth(String text) {
    final regex = RegExp(r'\b\d{2}/\d{2}/\d{4}\b');
    final match = regex.firstMatch(text);
    return match?.group(0); // Renvoie la date de naissance s'il est trouvé
  }

  // Fonction pour afficher un message de succès
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success', style: TextStyle(fontWeight: FontWeight.w600)),
          content: Text(message, style: TextStyle(color: Colors.black54)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Ferme la boîte de dialogue
              child: Text('OK', style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  // Fonction pour afficher un message d'erreur
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error', style: TextStyle(fontWeight: FontWeight.w600)),
          content: Text(message, style: TextStyle(color: Colors.black54)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Ferme la boîte de dialogue
              child: Text('OK', style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  // Méthodes pour vérifier la validité du numéro de CIN et de la date de naissance
  bool _isValidCinNumber(String cinNumber) {
    final regex = RegExp(r'^\d{8}$');
    return regex.hasMatch(cinNumber);
  }

  bool _isValidDateOfBirth(String dateOfBirth) {
    final regex = RegExp(r'^\d{2}/\d{2}/\d{4}$');
    return regex.hasMatch(dateOfBirth);
  }
}
