// Immutable class to hold password validation results
class PasswordValidationResult {
  final bool isLengthValid;
  final bool hasUpperCase;
  final bool hasLowerCase;
  final bool hasNumber;
  final bool hasSpecialChar;
  final bool isValid;

  const PasswordValidationResult({
    required this.isLengthValid,
    required this.hasUpperCase,
    required this.hasLowerCase,
    required this.hasNumber,
    required this.hasSpecialChar,
  }) : isValid = isLengthValid && hasUpperCase && hasLowerCase && hasNumber && hasSpecialChar;

  // Factory constructor for easy creation
  factory PasswordValidationResult.validate(String password) {
    return PasswordValidationResult(
      isLengthValid: password.length >= 8,
      hasUpperCase: password.contains(RegExp(r"[A-Z]")),
      hasLowerCase: password.contains(RegExp(r"[a-z]")),
      hasNumber: password.contains(RegExp(r"[0-9]")),
      hasSpecialChar: password.contains(RegExp(r"[!@#\$&*~]")),
    );
  }
}

// Thread-safe, stateless validation functions
bool checkLengthOfPassword(String password) {
  return password.length >= 8;
}

bool checkPasswordContainLowerChar(String password) {
  return password.contains(RegExp(r"[a-z]"));
}

bool checkPasswordContainSpecialChar(String password) {
  return password.contains(RegExp(r"[!@#\$&*~]"));
}

bool checkPasswordContainUpperChar(String password) {
  return password.contains(RegExp(r"[A-Z]"));
}

bool checkPasswordContainNum(String password) {
  return password.contains(RegExp(r"[0-9]"));
}

String? confirmPasswordvalidator(String confirmPassword, String password) {
  if (confirmPassword != password) {
    return "Password does not match";
  }
  return null;
}

String? emailValidator(String email) {
  if (email.isEmpty) {
    return "Email is required";
  }
  
  // More comprehensive and secure email validation regex
  // This regex is more restrictive and follows RFC 5322 more closely
  if (RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(email)) {
    return null;
  } else {
    return "Invalid Email";
  }
}

// Stateless password validation function
bool validatePassword(String password) {
  final result = PasswordValidationResult.validate(password);
  return result.isValid;
}

// Comprehensive password validation with detailed feedback
PasswordValidationResult validatePasswordDetailed(String password) {
  return PasswordValidationResult.validate(password);
}
