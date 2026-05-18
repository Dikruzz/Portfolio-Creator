import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portique/app/portique_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Portique renders onboarding entry point', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const ProviderScope(child: PortiqueApp()));

    expect(find.text('Portique'), findsOneWidget);
    expect(find.text('Your portfolio, directed by AI.'), findsOneWidget);
  });
}
