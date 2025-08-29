// lib/constants.dart

import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

// ** THEME COLOR IS NOW GREEN AND GOLD **
// The primary color is now a vibrant green.
const Color primaryColor = Color(0xFF108A00);
const Color goldColor = Color(0xFFFFD700); // New gold accent color

// A new MaterialColor swatch based on the new primary green.
const MaterialColor primaryMaterialColor = MaterialColor(
  0xFF108A00,
  <int, Color>{
    50: Color(0xFFE2F3E0),
    100: Color(0xFFB7E0B3),
    200: Color(0xFF88CC80),
    300: Color(0xFF59B84D),
    400: Color(0xFF35A826),
    500: primaryColor,
    600: Color(0xFF0E8200),
    700: Color(0xFF0C7800),
    800: Color(0xFF096F00),
    900: Color(0xFF055D00),
  },
);

// The rest of the constants remain the same.
const String grandisExtendedFont = "Grandis Extended";

const Color blackColor = Color(0xFF16161E);
const Color blackColor80 = Color(0xFF45454B);
const Color successColor = Color(0xFF2ED573);
const Color warningColor = Color(0xFFFFBE21);
const Color errorColor = Color(0xFFEA5B5B);

const double defaultPadding = 16.0;
const double defaultBorderRadious = 12.0;
const Duration defaultDuration = Duration(milliseconds: 300);

final passwordValidator = MultiValidator([
  RequiredValidator(errorText: 'Password is required'),
  MinLengthValidator(4, errorText: 'password must be at least 3 digits long'),
  MaxLengthValidator(20, errorText: 'password must not be more than 20 digits long'),
]);

final emaildValidator = MultiValidator([
  RequiredValidator(errorText: 'Email is required'),
  EmailValidator(errorText: "Enter a valid email address"),
]);

const pasNotMatchErrorText = "passwords do not match";