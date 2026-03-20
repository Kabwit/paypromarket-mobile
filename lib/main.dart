import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'config/theme.dart';
import 'l10n/app_localizations.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/client/client_home_screen.dart';
import 'screens/vendeur/vendeur_home_screen.dart';

// Gestionnaire de messages en arrière-plan
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle messages when app is in background/terminated
  print('Message reçu en arrière-plan: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (optionnel pour notifications)
  // Désactivé par défaut pour économiser la batterie en RDC
  // Décommenter si nécessaire pour production
  // await Firebase.initializeApp();
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // _setupPushNotifications();
  
  runApp(const PayProMarketApp());
}

void _setupPushNotifications() {
  // À activer seulement si Firebase est initialisé
  // Handle messages while app is in foreground
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('📩 Message reçu au premier plan:');
    print('Titre: ${message.notification?.title}');
    print('Corps: ${message.notification?.body}');
    print('Données: ${message.data}');
  });
  
  // Handle notification taps
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('📱 Notification ouverte:');
    print('Données: ${message.data}');
  });
  
  // Request permission (iOS only, Android is automatic)
  FirebaseMessaging.instance.requestPermission();
}

class PayProMarketApp extends StatelessWidget {
  const PayProMarketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        title: 'PayPro Market RDC',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        locale: const Locale('fr'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const AppRoot(),
      ),
    );
  }
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final auth = context.read<AuthProvider>();
    await auth.init();
    if (mounted) {
      setState(() => _isInitialized = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const SplashScreen();
    }

    final auth = context.watch<AuthProvider>();

    if (!auth.isAuthenticated) {
      return const WelcomeScreen();
    }

    if (auth.isVendeur) {
      return const VendeurHomeScreen();
    }

    return const ClientHomeScreen();
  }
}
