import 'package:form_field_validator/form_field_validator.dart';

class HeightValidator extends TextFieldValidator {
  // pass the error text to the super constructor
  HeightValidator({String errorText = 'Select height of the tree'})
      : super(errorText);

  // return false if you want the validator to return error
  // message when the value is empty.
  @override
  bool get ignoreEmptyValues => true;

  @override
  bool isValid(String? value) {
    if (value!.compareTo("Select") == 0) {
      return false;
    }
    return true;
  }
}
