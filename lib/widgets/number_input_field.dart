import 'package:flutter/material.dart';

import '../services/feedback_actions.dart';
import '../services/feedback_service.dart';
import '../utils/validators.dart';

/// Campo numérico con unidad, explicación breve y validación.
class NumberInputField extends StatelessWidget {
  const NumberInputField({
    super.key,
    required this.controller,
    required this.label,
    this.unit,
    this.helpText,
    this.min = 0,
    this.max,
    this.allowZero = true,
    this.integer = false,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String? unit;
  final String? helpText;
  final double? min;
  final double? max;
  final bool allowZero;
  final bool integer;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.numberWithOptions(
          decimal: !integer,
          signed: min == null || min! < 0,
        ),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onTap: () => context.emitFeedback(FeedbackEvent.seleccion),
        decoration: InputDecoration(
          labelText: label,
          suffixText: unit,
          helperText: helpText,
          helperMaxLines: 3,
          errorMaxLines: 3,
          border: const OutlineInputBorder(),
        ),
        validator: (value) => Validators.number(
          value,
          min: min,
          max: max,
          allowZero: allowZero,
          integer: integer,
        ),
        onChanged: onChanged,
      ),
    );
  }
}
