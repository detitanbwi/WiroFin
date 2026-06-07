import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String cleanText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanText.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final int value = int.parse(cleanText);
    final String formattedText = NumberFormat('#,###', 'id_ID').format(value);

    final int selectionIndexFromRight = newValue.text.length - newValue.selection.end;
    int newSelectionIndex = formattedText.length - selectionIndexFromRight;
    if (newSelectionIndex < 0) newSelectionIndex = 0;

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: newSelectionIndex),
    );
  }
}
