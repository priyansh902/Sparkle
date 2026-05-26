import 'package:flutter/material.dart';

/// Reusable widget for a form text field with label, icon, and validation. This widget is used across the app for various input fields such as email, password, symptom details, and health record details. It includes a TextFormField with customizable label, hint text, prefix icon, keyboard type, and validation logic. The design is consistent with the overall app theme, featuring rounded borders and a filled background for better user experience. The FormTextField helps to maintain a cohesive look and feel across the app while providing a flexible and reusable component for handling user input in forms.
/// The FormTextField is designed to be easy to use and integrate into different screens by simply providing the necessary parameters such as the controller, label, icon, and validation logic. It enhances the user experience by providing clear input fields with appropriate visual cues and feedback for validation errors. Overall, this widget plays an important role in ensuring that user input is handled consistently and effectively throughout the app, contributing to a polished and professional user interface.
/// The FormTextField can be easily extended in the future to include additional features such as support for password visibility toggling, input formatting, or integration with form validation libraries. By centralizing the form field logic in a single widget, it becomes easier to maintain and update the input handling across the app as new requirements arise or design changes are made. The use of TextEditingController allows for easy management of the input state and interaction with other parts of the app, such as submitting forms or clearing input fields after successful operations. Overall, the FormTextField is a key component of the app's form handling strategy, ensuring that user input is captured accurately and presented in a user-friendly manner.
class FormTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData prefixIcon;
  final String? hint;
  final int maxLines;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  
  const FormTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.prefixIcon,
    this.hint,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(prefixIcon, color: const Color(0xFF7B61FF)),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
    );
  }
}