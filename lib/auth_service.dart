import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  String? _email;

  String? get email => _email; // Getter pour l'email

  // Méthode de connexion (simulée)
  Future<void> signIn(String email, String password) async {
    // Ici, tu peux ajouter la logique de connexion via Supabase ou Firebase
    _email = email;  // On enregistre l'email de l'utilisateur
    notifyListeners();  // Notifie tous les widgets qui écoutent ce Provider
  }

  // Méthode de déconnexion
  void signOut() {
    _email = null; // Réinitialise l'email de l'utilisateur
    notifyListeners();  // Notifie que l'utilisateur est déconnecté
  }
}
