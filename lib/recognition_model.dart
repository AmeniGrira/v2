import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:io';

class RecognitionModel extends ChangeNotifier {
  String _recognizedText = 'Aucun texte détecté';
  String get recognizedText => _recognizedText;

  void setRecognizedText(String text) {
    _recognizedText = text;
    notifyListeners();
  }

  final ImagePicker _picker = ImagePicker();

  // Méthode pour sélectionner une image depuis la galerie
  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        await _analyzeImage(File(image.path)); // Analyser l'image sélectionnée
      }
    } catch (e) {
      setRecognizedText('Erreur lors de la sélection de l\'image : $e');
    }
  }

  // Méthode pour analyser l'image et extraire le texte
  Future<void> _analyzeImage(File image) async {
    final textRecognizer = TextRecognizer();
    try {
      final inputImage = InputImage.fromFilePath(image.path);
      final recognizedText = await textRecognizer.processImage(inputImage);

      // Filtrer pour récupérer uniquement un numéro CIN
      final cinNumber = _extractCinNumber(recognizedText.text);

      setRecognizedText(cinNumber);
    } catch (e) {
      setRecognizedText('Erreur lors de l’analyse de l’image : $e');
    } finally {
      // Toujours fermer le textRecognizer après l'analyse
      textRecognizer.close();
    }
  }

  // Extraire un numéro CIN à partir du texte reconnu
  String _extractCinNumber(String text) {
    // Regex pour capturer une séquence de 8 chiffres (numéro CIN)
    final RegExp regex = RegExp(r'\b\d{8}\b');
    final match = regex.firstMatch(text);
    return match != null ? 'Numéro CIN détecté : ${match.group(0)!}' : 'Numéro CIN introuvable';
  }
}
