import 'package:Warrior/core/services/logger.dart';
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn(
  // Use different client IDs for web vs Android
  // clientId: dotenv.env['GOOGLE_WEB_CLIENT_ID'],
  scopes: ['email', 'profile', 'openid'],
);

class GoogleSignInService {
  static Future<String?> signIn() async {
    try {
      AppLogger.info('Starting Google Sign-In process...', 'GOOGLE_SIGNIN');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        AppLogger.warning('User canceled the sign-in process', 'GOOGLE_SIGNIN');
        return null;
      }

      AppLogger.info('User signed in: ${googleUser.email}', 'GOOGLE_SIGNIN');

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      AppLogger.info('Authentication successful', 'GOOGLE_SIGNIN');

      return googleAuth.idToken;
    } catch (error) {
      AppLogger.error('Error during Google Sign-In', 'GOOGLE_SIGNIN', error);

      AppLogger.error('Error details: ${error.toString()}', 'GOOGLE_SIGNIN');
      return null;
    }
  }
}
