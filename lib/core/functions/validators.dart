String? emailValidator(String value) {
  if (value.isEmpty) {
    return 'Email is required';
  }
  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
    return 'Please enter a valid email';
  }
  return null;
}

String? passwordValidator(String value) {
  if (value.isEmpty) {
    return 'Password is required';
  }

  return null;
}

String? confirmPasswordValidator(String value, String password) {
  if (value.isEmpty) {
    return 'Confirm Password is required';
  }
  if (value != password) {
    return 'Password does not match';
  }
  return null;
}
