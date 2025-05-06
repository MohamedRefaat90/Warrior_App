import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn(
  // Use different client IDs for web vs Android
  // clientId: dotenv.env['GOOGLE_WEB_CLIENT_ID'],
  scopes: ['email', 'profile', 'openid'],
);

Future<String?> handleGoogleSignIn() async {
  try {
    debugPrint('Starting Google Sign-In process...');
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      debugPrint('User canceled the sign-in process');
      return null;
    }

    debugPrint('User signed in: ${googleUser.email}');
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    debugPrint('Authentication successful');
    final String? idToken = googleAuth.idToken;

    return idToken;
  } catch (error) {
    debugPrint('Error during Google Sign-In: $error');
    if (error is Exception) {
      debugPrint('Error details: ${error.toString()}');
    }
  }
  return null;
}
