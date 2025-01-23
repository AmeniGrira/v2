import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'login_page.dart';
import 'settings_page.dart';
import 'profile_page.dart';
import 'pass_page.dart';
import 'delete_account_page.dart'; // Importer la page de suppression du compte
import 'recognition_model.dart';
import 'nvmdp_page.dart';  // Importer la page de réinitialisation de mot de passe
import 'package:flutter_localizations/flutter_localizations.dart';
import 'localization.dart'; // Importer votre fichier de localisation
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://vkvywnlosqfvezxlzyci.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZrdnl3bmxvc3FmdmV6eGx6eWNpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzY0Mjk3MjcsImV4cCI6MjA1MjAwNTcyN30.jf3rjzwtrEYobMHkfB6Ha9EAf1w18OLjU5MqV1Pstyo',
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = false;
  String selectedLanguage = 'English'; // Langue par défaut
  late Future<bool> isUserLoggedInFuture;
  String _recognizedText = ''; // Stockage du texte reconnu

  @override
  void initState() {
    super.initState();
    _loadSettings();
    isUserLoggedInFuture = _checkUserLoginStatus();
  }

  // Charger les paramètres sauvegardés
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
      selectedLanguage = prefs.getString('selectedLanguage') ?? 'English';
    });
  }

  // Vérifier si l'utilisateur est connecté
  Future<bool> _checkUserLoginStatus() async {
    final user = Supabase.instance.client.auth.currentUser;
    return user != null;
  }

  // Sauvegarder les paramètres
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);
    await prefs.setString('selectedLanguage', selectedLanguage);
  }

  // Changer le mode sombre
  void _toggleDarkMode(bool value) {
    setState(() {
      isDarkMode = value;
    });
    _saveSettings();
  }

  // Changer la langue
  void _changeLanguage(String? language) {
    setState(() {
      selectedLanguage = language ?? 'English'; // Défaut à 'English' si nul
    });
    _saveSettings();
  }

  // Fonction pour sélectionner une image et reconnaître le texte
  Future<String> pickImageAndRecognizeText() async {
    final ImagePicker _picker = ImagePicker();
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      return await recognizeTextFromImage(pickedFile.path);
    } else {
      return 'Aucune image sélectionnée';
    }
  }

  // Fonction pour effectuer la reconnaissance de texte sur l'image
  Future<String> recognizeTextFromImage(String imagePath) async {
    final textRecognizer = GoogleMlKit.vision.textRecognizer();
    final inputImage = InputImage.fromFilePath(imagePath);

    try {
      final recognizedText = await textRecognizer.processImage(inputImage);
      textRecognizer.close();  // Libère les ressources après utilisation
      return recognizedText.text;
    } catch (e) {
      textRecognizer.close();
      return 'Erreur: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => RecognitionModel()),
      ],
      child: MaterialApp(
        title: 'Reconnaissance de CIN',
        themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
        darkTheme: ThemeData.dark(),
        theme: ThemeData.light(),
        locale: _getLocaleFromLanguage(selectedLanguage), // Définit la locale selon la langue
        supportedLocales: [
          Locale('en', 'US'),
          Locale('fr', 'FR'),
          Locale('ar', 'SA'), // Ajout de la langue arabe
        ],
        localizationsDelegates: [
          AppLocalizations.delegate, // Le délégué de localisation généré
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        home: FutureBuilder<bool>(
          future: isUserLoggedInFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator()); // Attente de la réponse de Supabase
            }
            if (snapshot.hasData && snapshot.data == true) {
              return ProfilePage(); // Si connecté, afficher la page profil
            } else {
              return LoginPage(
                onThemeChanged: _toggleDarkMode,
                onLanguageChanged: _changeLanguage,
              ); // Si non connecté, afficher la page de login
            }
          },
        ),
        routes: {
          '/profile': (context) => ProfilePage(),
          '/settings': (context) => SettingsPage(
            onModeChanged: _toggleDarkMode,
            onLanguageChanged: _changeLanguage,
          ),
          '/pass_page': (context) => PassPage(),
          '/login': (context) => LoginPage(
            onThemeChanged: _toggleDarkMode,
            onLanguageChanged: _changeLanguage,
          ),
          '/delete_account': (context) => DeleteAccountPage(),
          '/nvmdp': (context) => NvmdpPage(),
        },
      ),
    );
  }

  // Méthode pour obtenir la locale basée sur la langue sélectionnée
  Locale _getLocaleFromLanguage(String language) {
    switch (language) {
      case 'French':
        return Locale('fr', 'FR');
      case 'Arabic':
        return Locale('ar', 'SA'); // Locale arabe
      default:
        return Locale('en', 'US'); // Par défaut, anglais
    }
  }

  // Méthode pour afficher la page de reconnaissance de texte
  void _showRecognitionDialog() async {
    String recognizedText = await pickImageAndRecognizeText();
    setState(() {
      _recognizedText = recognizedText;
    });
  }
}
