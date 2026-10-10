import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:uswah_app/app.dart';

void main() {
  testWidgets('Uswah App shows onboarding on first launch',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const ProviderScope(
        child: UswahApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Jadwal Sholat'), findsOneWidget);
    expect(find.text('Lewati'), findsOneWidget);
  });
}
