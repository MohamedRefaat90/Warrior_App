import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn(
  // Client ID from the Google Console for Web application
  clientId: dotenv.env['GOOGLE_WEB_CLIENT_ID'],
  scopes: [
    'email',
    'profile',
    'openid',
  ],
);

Future<String?> handleGoogleSignIn() async {
  try {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      // User canceled the sign-in process
      return null;
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final String? idToken = googleAuth.idToken;
    final String? accessToken = googleAuth.accessToken;

    return idToken;
  } catch (error) {
    print('Error during Google Sign-In: $error');
  }
}
