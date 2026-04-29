import 'package:flutter_test/flutter_test.dart';
import 'package:termoplan/main.dart';

void main() {
  testWidgets('TermoPlan opens', (WidgetTester tester) async {
    await tester.pumpWidget(const TermoPlanApp());
    expect(find.text('TermoPlan'), findsOneWidget);
  });
}