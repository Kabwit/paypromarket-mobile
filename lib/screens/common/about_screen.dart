import 'package:flutter/material.dart';
import '../../config/theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('À propos')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Logo / branding
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shopping_bag, size: 48, color: AppTheme.primaryColor),
            ),
            const SizedBox(height: 16),
            const Text('PayPro Market RDC',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Version 1.0.0', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 24),

            _card(
              'Notre mission',
              'PayPro Market est la première marketplace de confiance en République Démocratique du Congo. '
                  'Nous connectons les vendeurs et acheteurs congolais dans un environnement sécurisé, '
                  'avec paiement Mobile Money intégré et livraison partout en RDC.',
            ),
            const SizedBox(height: 12),
            _card(
              'Ce que nous offrons',
              '• Marketplace sécurisée avec vérification des vendeurs\n'
                  '• Paiement par Mobile Money (M-Pesa, Airtel Money, Orange Money)\n'
                  '• Paiement à la livraison\n'
                  '• Chat en direct avec les vendeurs\n'
                  '• Suivi de livraison en temps réel\n'
                  '• Protection acheteur et système d\'avis\n'
                  '• Plans Premium pour les vendeurs professionnels',
            ),
            const SizedBox(height: 12),
            _card(
              'Contact',
              '📧 Email : support@paypromarket.cd\n'
                  '📞 Téléphone : +243 XX XXX XXXX\n'
                  '📍 Lubumbashi, RD Congo\n'
                  '🌐 www.paypromarket.cd',
            ),
            const SizedBox(height: 24),

            // Navigation links
            _linkTile(context, Icons.description, 'Conditions d\'utilisation', const TermsScreen()),
            _linkTile(context, Icons.privacy_tip, 'Politique de confidentialité', const PrivacyScreen()),
            const SizedBox(height: 24),

            Text('© 2025 PayPro Market RDC. Tous droits réservés.',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _card(String title, String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }

  Widget _linkTile(BuildContext context, IconData icon, String title, Widget page) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryColor),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      ),
    );
  }
}

// ==================== CONDITIONS D'UTILISATION ====================
class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Conditions d\'utilisation')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Conditions Générales d\'Utilisation',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text('Dernière mise à jour : Janvier 2025',
                style: TextStyle(color: Colors.grey)),
            SizedBox(height: 20),

            _Section(title: '1. Acceptation des conditions', content:
              'En utilisant l\'application PayPro Market RDC, vous acceptez les présentes '
              'conditions générales d\'utilisation. Si vous n\'acceptez pas ces conditions, '
              'veuillez ne pas utiliser notre service.'),

            _Section(title: '2. Description du service', content:
              'PayPro Market est une plateforme de commerce en ligne permettant aux vendeurs '
              'de proposer leurs produits et aux acheteurs de les acheter. Nous agissons en '
              'tant qu\'intermédiaire et ne sommes pas partie aux transactions entre vendeurs et acheteurs.'),

            _Section(title: '3. Inscription et compte', content:
              '• Vous devez fournir des informations exactes lors de l\'inscription.\n'
              '• Vous êtes responsable de la confidentialité de vos identifiants.\n'
              '• Un seul compte par personne est autorisé.\n'
              '• Nous nous réservons le droit de suspendre tout compte en cas de violation.'),

            _Section(title: '4. Vendeurs', content:
              '• Les vendeurs doivent être vérifiés pour vendre sur la plateforme.\n'
              '• Les produits listés doivent être conformes aux lois congolaises.\n'
              '• Les articles contrefaits, illégaux ou dangereux sont strictement interdits.\n'
              '• Les vendeurs sont responsables de la qualité et de la livraison de leurs produits.'),

            _Section(title: '5. Acheteurs', content:
              '• Les commandes sont confirmées après paiement.\n'
              '• Un droit d\'annulation est possible avant la préparation de la commande.\n'
              '• Les réclamations doivent être signalées dans les 48h suivant la livraison.'),

            _Section(title: '6. Paiements', content:
              '• Les paiements sont sécurisés via Mobile Money ou à la livraison.\n'
              '• PayPro Market prélève une commission sur chaque transaction.\n'
              '• Les remboursements sont traités au cas par cas selon notre politique.'),

            _Section(title: '7. Limitation de responsabilité', content:
              'PayPro Market ne garantit pas la qualité des produits vendus par les vendeurs tiers. '
              'Notre responsabilité est limitée au montant de la commission perçue sur la transaction concernée.'),

            _Section(title: '8. Propriété intellectuelle', content:
              'L\'application PayPro Market, son design, ses logos et son contenu sont protégés par les '
              'droits de propriété intellectuelle. Toute reproduction est interdite sans autorisation.'),

            _Section(title: '9. Modification des conditions', content:
              'Nous nous réservons le droit de modifier ces conditions à tout moment. '
              'Les utilisateurs seront notifiés des changements importants.'),

            _Section(title: '10. Contact', content:
              'Pour toute question concernant ces conditions :\n'
              'Email : legal@paypromarket.cd\n'
              'Adresse : Lubumbashi, RD Congo'),
          ],
        ),
      ),
    );
  }
}

// ==================== POLITIQUE DE CONFIDENTIALITÉ ====================
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confidentialité')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Politique de Confidentialité',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text('Dernière mise à jour : Janvier 2025',
                style: TextStyle(color: Colors.grey)),
            SizedBox(height: 20),

            _Section(title: '1. Données collectées', content:
              'Nous collectons les données suivantes :\n'
              '• Informations d\'inscription (nom, téléphone, email, adresse)\n'
              '• Données de transaction (commandes, paiements)\n'
              '• Données de localisation (ville, commune pour la livraison)\n'
              '• Messages échangés sur la plateforme\n'
              '• Données d\'utilisation (pages visitées, recherches)'),

            _Section(title: '2. Utilisation des données', content:
              'Vos données sont utilisées pour :\n'
              '• Fournir et améliorer nos services\n'
              '• Traiter vos commandes et paiements\n'
              '• Communiquer avec vous (notifications, support)\n'
              '• Prévenir la fraude et assurer la sécurité\n'
              '• Générer des statistiques anonymisées'),

            _Section(title: '3. Partage des données', content:
              '• Avec les vendeurs : nom et adresse de livraison pour traiter vos commandes\n'
              '• Avec les prestataires de paiement : données nécessaires au traitement des paiements\n'
              '• Avec les autorités : si requis par la loi congolaise\n'
              '• Nous ne vendons JAMAIS vos données personnelles à des tiers'),

            _Section(title: '4. Sécurité des données', content:
              '• Chiffrement des mots de passe (bcrypt)\n'
              '• Communications sécurisées (HTTPS)\n'
              '• Accès restreint aux données personnelles\n'
              '• Surveillance continue des activités suspectes'),

            _Section(title: '5. Conservation des données', content:
              '• Données de compte : conservées tant que le compte est actif\n'
              '• Données de transaction : conservées 5 ans (obligation légale)\n'
              '• Messages : conservés 1 an après la dernière activité\n'
              '• Données de navigation : 6 mois'),

            _Section(title: '6. Vos droits', content:
              'Conformément à la législation applicable, vous avez le droit de :\n'
              '• Accéder à vos données personnelles\n'
              '• Rectifier vos informations\n'
              '• Demander la suppression de votre compte\n'
              '• Vous opposer au traitement de certaines données\n\n'
              'Contactez-nous à privacy@paypromarket.cd pour exercer vos droits.'),

            _Section(title: '7. Cookies et technologies similaires', content:
              'L\'application mobile utilise le stockage local (SharedPreferences) pour :\n'
              '• Conserver votre session de connexion\n'
              '• Mémoriser vos préférences (langue, etc.)\n'
              '• Ces données restent sur votre appareil'),

            _Section(title: '8. Modifications', content:
              'Cette politique peut être mise à jour. Les changements significatifs seront '
              'notifiés via l\'application. La date de dernière mise à jour sera actualisée en conséquence.'),

            _Section(title: '9. Contact', content:
              'Pour toute question relative à la confidentialité :\n'
              'Email : privacy@paypromarket.cd\n'
              'Adresse : Lubumbashi, RD Congo'),
          ],
        ),
      ),
    );
  }
}

// Widget réutilisable pour les sections
class _Section extends StatelessWidget {
  final String title;
  final String content;
  const _Section({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontSize: 14, height: 1.6)),
        ],
      ),
    );
  }
}
