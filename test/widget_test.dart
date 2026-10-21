
import 'package:flutter_test/flutter_test.dart';
import 'package:semester_project/app.dart';

void main() {
  testWidgets('Semester Project app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const SemesterProjectApp());

    expect(find.text('Semester Project'), findsOneWidget);
    expect(
      find.text('Your Flutter App Is Running!'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
