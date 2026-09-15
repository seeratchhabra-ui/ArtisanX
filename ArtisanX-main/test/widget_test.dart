import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:artisanx/main.dart';
import 'package:artisanx/providers/app_state.dart';

void main() {
  testWidgets('KalaSetu App smoke test', (WidgetTester tester) async {
    // Build KalaSetu app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => AppState())],
        child: const KalaSetuApp(),
      ),
    );

    // Verify brand title and role options exist on the welcome screen
    expect(find.text('Kalasetu'), findsOneWidget);
    expect(find.text('ARTISAN'), findsOneWidget);
    expect(find.text('CUSTOMER'), findsOneWidget);
  });
}
