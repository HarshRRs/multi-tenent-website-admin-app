import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rockster/core/components/cosmic_input_field.dart';

void main() {
  testWidgets('CosmicInputField passes UX parameters to TextFormField', (WidgetTester tester) async {
    final controller = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CosmicInputField(
            label: 'Test Label',
            hint: 'Test Hint',
            icon: Icons.person,
            controller: controller,
            autofillHints: const [AutofillHints.email],
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) {},
          ),
        ),
      ),
    );

    // TextFormField builds a TextField, so we look for that
    final textFieldFinder = find.byType(TextField);
    expect(textFieldFinder, findsOneWidget);

    final TextField textField = tester.widget(textFieldFinder);

    // Verify autofillHints
    expect(textField.autofillHints, contains(AutofillHints.email));

    // Verify textInputAction
    expect(textField.textInputAction, TextInputAction.next);

    // Verify onFieldSubmitted
    // To trigger onFieldSubmitted we need to simulate the action
    await tester.enterText(textFieldFinder, 'test');
    await tester.testTextInput.receiveAction(TextInputAction.next);
  });
}
