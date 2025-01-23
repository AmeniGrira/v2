import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

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
