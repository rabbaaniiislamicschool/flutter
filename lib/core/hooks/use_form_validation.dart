import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class FormValidationResult {
  final bool isValid;
  final Map<String, String?> errors;
  final void Function(String field, String? error) setError;
  final void Function() clearErrors;
  final void Function() validate;

  FormValidationResult({
    required this.isValid,
    required this.errors,
    required this.setError,
    required this.clearErrors,
    required this.validate,
  });
}

FormValidationResult useFormValidation({
  required Map<String, TextEditingController> controllers,
  required Map<String, String? Function(String?)> validators,
}) {
  final errors = useState<Map<String, String?>>({});

  void setError(String field, String? error) {
    errors.value = {...errors.value, field: error};
  }

  void clearErrors() {
    errors.value = {};
  }

  void validate() {
    final newErrors = <String, String?>{};

    for (final entry in controllers.entries) {
      final validator = validators[entry.key];
      if (validator != null) {
        newErrors[entry.key] = validator(entry.value.text);
      }
    }

    errors.value = newErrors;
  }

  final isValid = errors.value.values.every((e) => e == null);

  return FormValidationResult(
    isValid: isValid,
    errors: errors.value,
    setError: setError,
    clearErrors: clearErrors,
    validate: validate,
  );
}
