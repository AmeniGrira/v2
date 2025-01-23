import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
// Import nécessaire pour SynchronousFuture
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multilingual App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: MyHomePage(),
    );
  }
}

class AppLocalizations {
  static const List<Locale> supportedLocales = [
    Locale('en', 'US'),
    Locale('ar', 'SA'),
    Locale('fr', 'FR'),
  ];

  static String? of(BuildContext context, String key) {
    // Récupère la langue actuelle de l'application
    String languageCode = Localizations.localeOf(context).languageCode;

    switch (key) {
      case 'login':
        if (languageCode == 'ar') {
          return 'تسجيل الدخول'; // Arabe
        } else if (languageCode == 'fr') {
          return 'Connexion'; // Français
        } else {
          return 'Login'; // Anglais
        }
      case 'welcome_back':
        if (languageCode == 'ar') {
          return 'مرحبا بعودتك'; // Arabe
        } else if (languageCode == 'fr') {
          return 'Bienvenue'; // Français
        } else {
          return 'Welcome Back'; // Anglais
        }
      case 'email':
        if (languageCode == 'ar') {
          return 'البريد الإلكتروني'; // Arabe
        } else if (languageCode == 'fr') {
          return 'Email ou numéro de téléphone'; // Français
        } else {
          return 'Email or Phone number'; // Anglais
        }
      case 'password':
        if (languageCode == 'ar') {
          return 'كلمة المرور'; // Arabe
        } else if (languageCode == 'fr') {
          return 'Mot de passe'; // Français
        } else {
          return 'Password'; // Anglais
        }
      case 'create_account':
        if (languageCode == 'ar') {
          return 'إنشاء حساب'; // Arabe
        } else if (languageCode == 'fr') {
          return 'Créer un compte'; // Français
        } else {
          return 'Create an account'; // Anglais
        }
      default:
        return key;
    }
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
  _AppLocalizationsDelegate();
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.contains(locale);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations());
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) => false;
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context, 'welcome_back') ?? 'Welcome'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              AppLocalizations.of(context, 'login') ?? 'Login',
            ),
            Text(
              AppLocalizations.of(context, 'email') ?? 'Email',
            ),
            Text(
              AppLocalizations.of(context, 'password') ?? 'Password',
            ),
            Text(
              AppLocalizations.of(context, 'create_account') ?? 'Create an Account',
            ),
          ],
        ),
      ),
    );
  }
}
