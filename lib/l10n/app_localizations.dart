import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('fr'),
    Locale('ln'), // Lingala
    Locale('sw'), // Swahili
    Locale('en'),
  ];

  static final Map<String, Map<String, String>> _localizedValues = {
    'fr': _fr,
    'ln': _ln,
    'sw': _sw,
    'en': _en,
  };

  String get(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['fr']?[key] ??
        key;
  }

  // Raccourcis courants
  String get appName => get('app_name');
  String get home => get('home');
  String get products => get('products');
  String get orders => get('orders');
  String get profile => get('profile');
  String get cart => get('cart');
  String get search => get('search');
  String get login => get('login');
  String get register => get('register');
  String get logout => get('logout');
  String get settings => get('settings');
  String get notifications => get('notifications');
  String get messages => get('messages');
  String get dashboard => get('dashboard');
  String get addProduct => get('add_product');
  String get myOrders => get('my_orders');
  String get myShop => get('my_shop');
  String get delivery => get('delivery');
  String get tracking => get('tracking');
  String get payment => get('payment');
  String get total => get('total');
  String get confirm => get('confirm');
  String get cancel => get('cancel');
  String get save => get('save');
  String get delete => get('delete');
  String get edit => get('edit');
  String get loading => get('loading');
  String get error => get('error');
  String get success => get('success');
  String get noData => get('no_data');
  String get retry => get('retry');
  String get about => get('about');
  String get terms => get('terms');
  String get privacy => get('privacy');
  String get language => get('language');
  String get welcome => get('welcome');
  String get addToCart => get('add_to_cart');
  String get contactSeller => get('contact_seller');
  String get reviews => get('reviews');

  // ===================== FRANÇAIS =====================
  static const Map<String, String> _fr = {
    'app_name': 'PayPro Market RDC',
    'home': 'Accueil',
    'products': 'Produits',
    'orders': 'Commandes',
    'profile': 'Profil',
    'cart': 'Panier',
    'search': 'Rechercher...',
    'login': 'Connexion',
    'register': 'Inscription',
    'logout': 'Déconnexion',
    'settings': 'Paramètres',
    'notifications': 'Notifications',
    'messages': 'Messages',
    'dashboard': 'Tableau de bord',
    'add_product': 'Ajouter un produit',
    'my_orders': 'Mes commandes',
    'my_shop': 'Ma boutique',
    'delivery': 'Livraison',
    'tracking': 'Suivi de livraison',
    'payment': 'Paiement',
    'total': 'Total',
    'confirm': 'Confirmer',
    'cancel': 'Annuler',
    'save': 'Enregistrer',
    'delete': 'Supprimer',
    'edit': 'Modifier',
    'loading': 'Chargement...',
    'error': 'Erreur',
    'success': 'Succès',
    'no_data': 'Aucune donnée',
    'retry': 'Réessayer',
    'about': 'À propos',
    'terms': 'Conditions d\'utilisation',
    'privacy': 'Politique de confidentialité',
    'language': 'Langue',
    'welcome': 'Bienvenue sur PayPro Market',
    'add_to_cart': 'Ajouter au panier',
    'contact_seller': 'Contacter le vendeur',
    'reviews': 'Avis clients',
    'welcome_subtitle': 'La marketplace de confiance en RDC',
    'i_am_buyer': 'Je suis acheteur',
    'i_am_seller': 'Je suis vendeur',
    'categories': 'Catégories',
    'see_all': 'Voir tout',
    'popular': 'Populaire',
    'new_arrivals': 'Nouveautés',
    'promotions': 'Promotions',
    'order_placed': 'Commande passée',
    'order_confirmed': 'Confirmée',
    'in_preparation': 'En préparation',
    'shipped': 'Expédiée',
    'delivered': 'Livrée',
    'cancelled': 'Annulée',
    'fc': 'FC',
  };

  // ===================== LINGALA =====================
  static const Map<String, String> _ln = {
    'app_name': 'PayPro Market RDC',
    'home': 'Ndako',
    'products': 'Biloko',
    'orders': 'Bitikeli',
    'profile': 'Profil na ngai',
    'cart': 'Panier',
    'search': 'Luka...',
    'login': 'Kokota',
    'register': 'Komisalisa',
    'logout': 'Kobima',
    'settings': 'Mibeko',
    'notifications': 'Nsango',
    'messages': 'Mamesaje',
    'dashboard': 'Tableau ya misala',
    'add_product': 'Bakisa eloko',
    'my_orders': 'Bitikeli na ngai',
    'my_shop': 'Butiki na ngai',
    'delivery': 'Kopesa',
    'tracking': 'Kolanda livrezon',
    'payment': 'Kofuta',
    'total': 'Nyonso',
    'confirm': 'Kondima',
    'cancel': 'Koboya',
    'save': 'Kobomba',
    'delete': 'Kolongola',
    'edit': 'Kobongola',
    'loading': 'Tozali kotia...',
    'error': 'Libunga',
    'success': 'Elongi',
    'no_data': 'Eloko moko te',
    'retry': 'Meka lisusu',
    'about': 'Na tina na biso',
    'terms': 'Mibeko ya kosalela',
    'privacy': 'Mibeko ya sekele',
    'language': 'Monoko',
    'welcome': 'Boyei malamu na PayPro Market',
    'add_to_cart': 'Tia na panier',
    'contact_seller': 'Solola na motekisi',
    'reviews': 'Makanisi ya basombi',
    'welcome_subtitle': 'Zando ya bondimu na RDC',
    'i_am_buyer': 'Nazali mosombi',
    'i_am_seller': 'Nazali motekisi',
    'categories': 'Mikili',
    'see_all': 'Tala nyonso',
    'popular': 'Oyo etondami',
    'new_arrivals': 'Biloko ya sika',
    'promotions': 'Promotions',
    'order_placed': 'Bitikeli esalami',
    'order_confirmed': 'Endimami',
    'in_preparation': 'Bazali kolengela',
    'shipped': 'Etindami',
    'delivered': 'Ekomi',
    'cancelled': 'Eboyami',
    'fc': 'FC',
  };

  // ===================== SWAHILI =====================
  static const Map<String, String> _sw = {
    'app_name': 'PayPro Market RDC',
    'home': 'Nyumbani',
    'products': 'Bidhaa',
    'orders': 'Maagizo',
    'profile': 'Wasifu',
    'cart': 'Kikapu',
    'search': 'Tafuta...',
    'login': 'Ingia',
    'register': 'Jisajili',
    'logout': 'Toka',
    'settings': 'Mipangilio',
    'notifications': 'Arifa',
    'messages': 'Ujumbe',
    'dashboard': 'Dashibodi',
    'add_product': 'Ongeza bidhaa',
    'my_orders': 'Maagizo yangu',
    'my_shop': 'Duka langu',
    'delivery': 'Utoaji',
    'tracking': 'Fuatilia usafirishaji',
    'payment': 'Malipo',
    'total': 'Jumla',
    'confirm': 'Thibitisha',
    'cancel': 'Ghairi',
    'save': 'Hifadhi',
    'delete': 'Futa',
    'edit': 'Hariri',
    'loading': 'Inapakia...',
    'error': 'Hitilafu',
    'success': 'Mafanikio',
    'no_data': 'Hakuna data',
    'retry': 'Jaribu tena',
    'about': 'Kuhusu',
    'terms': 'Masharti ya matumizi',
    'privacy': 'Sera ya faragha',
    'language': 'Lugha',
    'welcome': 'Karibu PayPro Market',
    'add_to_cart': 'Ongeza kwenye kikapu',
    'contact_seller': 'Wasiliana na muuzaji',
    'reviews': 'Maoni ya wateja',
    'welcome_subtitle': 'Soko la kuaminika katika DRC',
    'i_am_buyer': 'Mimi ni mnunuzi',
    'i_am_seller': 'Mimi ni muuzaji',
    'categories': 'Kategoria',
    'see_all': 'Tazama yote',
    'popular': 'Maarufu',
    'new_arrivals': 'Bidhaa mpya',
    'promotions': 'Ofa',
    'order_placed': 'Agizo limewekwa',
    'order_confirmed': 'Imethibitishwa',
    'in_preparation': 'Inaandaliwa',
    'shipped': 'Imetumwa',
    'delivered': 'Imewasilishwa',
    'cancelled': 'Imeghairiwa',
    'fc': 'FC',
  };

  // ===================== ENGLISH =====================
  static const Map<String, String> _en = {
    'app_name': 'PayPro Market DRC',
    'home': 'Home',
    'products': 'Products',
    'orders': 'Orders',
    'profile': 'Profile',
    'cart': 'Cart',
    'search': 'Search...',
    'login': 'Login',
    'register': 'Register',
    'logout': 'Logout',
    'settings': 'Settings',
    'notifications': 'Notifications',
    'messages': 'Messages',
    'dashboard': 'Dashboard',
    'add_product': 'Add product',
    'my_orders': 'My orders',
    'my_shop': 'My shop',
    'delivery': 'Delivery',
    'tracking': 'Delivery tracking',
    'payment': 'Payment',
    'total': 'Total',
    'confirm': 'Confirm',
    'cancel': 'Cancel',
    'save': 'Save',
    'delete': 'Delete',
    'edit': 'Edit',
    'loading': 'Loading...',
    'error': 'Error',
    'success': 'Success',
    'no_data': 'No data',
    'retry': 'Retry',
    'about': 'About',
    'terms': 'Terms of use',
    'privacy': 'Privacy policy',
    'language': 'Language',
    'welcome': 'Welcome to PayPro Market',
    'add_to_cart': 'Add to cart',
    'contact_seller': 'Contact seller',
    'reviews': 'Customer reviews',
    'welcome_subtitle': 'The trusted marketplace in DRC',
    'i_am_buyer': 'I am a buyer',
    'i_am_seller': 'I am a seller',
    'categories': 'Categories',
    'see_all': 'See all',
    'popular': 'Popular',
    'new_arrivals': 'New arrivals',
    'promotions': 'Promotions',
    'order_placed': 'Order placed',
    'order_confirmed': 'Confirmed',
    'in_preparation': 'In preparation',
    'shipped': 'Shipped',
    'delivered': 'Delivered',
    'cancelled': 'Cancelled',
    'fc': 'FC',
  };
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['fr', 'ln', 'sw', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
