import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _role; // 'vendeur' ou 'client'
  Map<String, dynamic>? _userData;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get role => _role;
  Map<String, dynamic>? get userData => _userData;
  String? get errorMessage => _errorMessage;
  bool get isVendeur => _role == 'vendeur';
  bool get isClient => _role == 'client';

  // Initialiser - vérifier si déjà connecté
  Future<void> init() async {
    await ApiService.loadToken();
    final prefs = await SharedPreferences.getInstance();
    _role = prefs.getString('user_role');
    final userDataStr = prefs.getString('user_data');
    if (userDataStr != null) {
      _userData = jsonDecode(userDataStr);
    }

    if (ApiService.isAuthenticated && _role != null) {
      _isAuthenticated = true;
      // Vérifier la validité du token
      await refreshProfile();
    }
    notifyListeners();
  }

  // Inscription vendeur
  Future<bool> inscriptionVendeur({
    required String nomBoutique,
    required String telephone,
    required String motDePasse,
    String? email,
    String? ville,
    String? province,
    String? categoriePrincipale,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await ApiService.post(ApiConfig.vendeurInscription, {
      'nom_boutique': nomBoutique,
      'telephone': telephone,
      'mot_de_passe': motDePasse,
      if (email != null) 'email': email,
      if (ville != null) 'ville': ville,
      if (province != null) 'province': province,
      if (categoriePrincipale != null) 'categorie_boutique': categoriePrincipale,
    });

    _isLoading = false;

    if (result['success'] == true && result['token'] != null) {
      await _saveAuth(result['token'], 'vendeur', result['vendeur'] ?? {});
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['error'] ?? 'Erreur lors de l\'inscription';
      notifyListeners();
      return false;
    }
  }

  // Connexion vendeur
  Future<bool> connexionVendeur({
    required String telephone,
    required String motDePasse,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await ApiService.post(ApiConfig.vendeurConnexion, {
      'telephone': telephone,
      'mot_de_passe': motDePasse,
    });

    _isLoading = false;

    if (result['success'] == true && result['token'] != null) {
      await _saveAuth(result['token'], 'vendeur', result['vendeur'] ?? {});
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['error'] ?? 'Identifiants incorrects';
      notifyListeners();
      return false;
    }
  }

  // Inscription client
  Future<bool> inscriptionClient({
    required String nomComplet,
    required String telephone,
    required String motDePasse,
    String? email,
    String? ville,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await ApiService.post(ApiConfig.clientInscription, {
      'nom': nomComplet,
      'telephone': telephone,
      'mot_de_passe': motDePasse,
      if (email != null) 'email': email,
      if (ville != null) 'ville': ville,
    });

    _isLoading = false;

    if (result['success'] == true && result['token'] != null) {
      await _saveAuth(result['token'], 'client', result['client'] ?? {});
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['error'] ?? 'Erreur lors de l\'inscription';
      notifyListeners();
      return false;
    }
  }

  // Connexion client
  Future<bool> connexionClient({
    required String telephone,
    required String motDePasse,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await ApiService.post(ApiConfig.clientConnexion, {
      'telephone': telephone,
      'mot_de_passe': motDePasse,
    });

    _isLoading = false;

    if (result['success'] == true && result['token'] != null) {
      await _saveAuth(result['token'], 'client', result['client'] ?? {});
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['error'] ?? 'Identifiants incorrects';
      notifyListeners();
      return false;
    }
  }

  // Rafraîchir le profil
  Future<void> refreshProfile() async {
    final result = await ApiService.get(ApiConfig.profil);
    if (result['success'] != true) {
      // Token invalide
      await logout();
    }
  }

  // Sauvegarder l'authentification
  Future<void> _saveAuth(String token, String role, Map<String, dynamic> user) async {
    await ApiService.saveToken(token);
    _isAuthenticated = true;
    _role = role;
    _userData = user;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', role);
    await prefs.setString('user_data', jsonEncode(user));
  }

  // Déconnexion
  Future<void> logout() async {
    await ApiService.clearToken();
    _isAuthenticated = false;
    _role = null;
    _userData = null;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
