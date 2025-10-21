bool isVaildEmail = false;

bool isPassLengthLargerThan8 = false;
bool isContainUpperChar = false;
bool isContainLowerChar = false;
bool isContainNum = false;
bool isContainSpecailChar = false;
bool isPassMatchConfirmPass = false;
bool isObsecured = true;

void checkLengthOfPassword(String password) {
  if (password.length >= 8) {
    isPassLengthLargerThan8 = true;
  } else {
    isPassLengthLargerThan8 = false;
  }
}

void checkPasswordContainLowerChar(String password) {
  if (password.contains(RegExp(r"[a-z]"))) {
    isContainLowerChar = true;
  } else {
    isContainLowerChar = false;
  }
}

void checkPasswordContainSpecialChar(String password) {
  if (password.contains(RegExp(r"(?=.*?[!@#\$&*~])"))) {
    isContainSpecailChar = true;
  } else {
    isContainSpecailChar = false;
  }
}

void checkPasswordContainUpperChar(String password) {
  if (password.contains(RegExp(r"[A-Z]"))) {
    isContainUpperChar = true;
  } else {
    isContainUpperChar = false;
  }
}

void checkPasswordContainNum(String password) {
  if (password.contains(RegExp(r"[0-9]"))) {
    isContainNum = true;
  } else {
    isContainNum = false;
  }
}

String? confirmPasswordvalidator(String confirmPassword, String password) {
  if (confirmPassword != password) {
    return "Password does not match";
  }
  return null;
}

String? emailValidator(String email) {
  if (RegExp(
          r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*\.(com|org|net|edu|gov|mil|biz|info|io)$")
      .hasMatch(email)) {
    return null;
  } else if (email.isEmpty) {
    return "Email is required";
  } else {
    return "Invalid Email";
  }
}

bool validatePassword() {
  if (isPassLengthLargerThan8 &&
      isContainUpperChar &&
      isContainLowerChar &&
      isContainNum &&
      isContainSpecailChar) {
    return true;
  } else {
    return false;
  }
}

void resetFlagFields() {
  isVaildEmail = false;
  isPassLengthLargerThan8 = false;
  isContainUpperChar = false;
  isContainLowerChar = false;
  isContainNum = false;
  isContainSpecailChar = false;
  isPassMatchConfirmPass = false;
  isObsecured = true;
}
