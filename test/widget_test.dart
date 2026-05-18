import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portique/app/portique_app.dart';

void main() {
  testWidgets('Portique renders onboarding entry point', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: PortiqueApp()));
    await tester.pumpAndSettle();

    expect(find.text('Portique'), findsOneWidget);
    expect(find.text('Craft a portfolio that feels bespoke.'), findsOneWidget);
  });
}
