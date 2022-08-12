import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

class CustomFormField extends StatelessWidget {
  final String labelText;
  final String initialValue;
  bool enabled;
  Function(String) onChanged;
  CustomFormField(
      {required this.labelText,
      required this.initialValue,
      required this.onChanged,
      this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      child: TextFormField(
        enabled: enabled,
        cursorColor: Colors.green[900],
        keyboardType: TextInputType.text,
        initialValue: initialValue,
        onChanged: enabled == true ? onChanged : (val) {},
        validator:
            MultiValidator([RequiredValidator(errorText: "Cannot Be Empty")]),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color: Colors.black87, fontSize: 15),
          border: OutlineInputBorder(
            borderRadius: new BorderRadius.circular(20.0),
            borderSide: BorderSide(color: Colors.green),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: new BorderRadius.circular(20.0),
            borderSide: BorderSide(color: Colors.green),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: new BorderRadius.circular(20.0),
            borderSide: BorderSide(color: Colors.red),
          ),
        ),
      ),
    );
  }
}
