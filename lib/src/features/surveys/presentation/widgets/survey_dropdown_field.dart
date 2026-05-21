import 'package:flutter/material.dart';

class SurveyDropdownField<T> extends StatelessWidget {
  const SurveyDropdownField({
    required this.label,
    required this.hintText,
    required this.icon,
    required this.items,
    required this.onChanged,
    this.initialValue,
    this.validator,
    super.key,
  });

  final String label;
  final String hintText;
  final IconData icon;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final T? initialValue;
  final FormFieldValidator<T>? validator;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: initialValue,
      isExpanded: true,
      items: items,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon),
      ),
    );
  }
}
