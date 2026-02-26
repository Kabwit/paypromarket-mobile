import 'package:flutter_test/flutter_test.dart';

import 'package:mobile_frontend/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PayProMarketApp());
    await tester.pump();
    // Vérifier que l'app démarre sans erreur
    expect(find.byType(PayProMarketApp), findsOneWidget);
  });
}
