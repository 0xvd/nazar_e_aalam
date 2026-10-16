// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class ResultField extends StatelessWidget {
  final String labelText;
  final TextEditingController controllerValue;
  final bool readOnly;
  final String? Function(String?)? validator;
  final Function(String?)? onSaved;

  const ResultField({
    required this.labelText,
    required this.controllerValue,
    super.key,
    required this.readOnly,
    this.validator,
    this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: readOnly,
      keyboardType: TextInputType.number,
      controller: controllerValue,
      validator: validator,
      onSaved: onSaved,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.w400,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: Theme.of(context).primaryColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: Theme.of(context).primaryColor, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 1,
          ),
        ),
      ),
    );
  }
}
