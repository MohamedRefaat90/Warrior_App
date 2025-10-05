import 'package:Warrior/core/services/talker_service.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInService {
  static bool _initialized = false;

  static Future<String?> signIn() async {
    try {
      await _ensureInitialized();
      TalkerService.info('Starting Google Sign-In process...', 'GOOGLE_SIGNIN');

      GoogleSignInAccount? account;

      final Future<GoogleSignInAccount?>? maybeFuture =
          GoogleSignIn.instance.attemptLightweightAuthentication();
      if (maybeFuture != null) {
        account = await maybeFuture;
      }

      if (account == null && GoogleSignIn.instance.supportsAuthenticate()) {
        account = await GoogleSignIn.instance.authenticate();
      }

      if (account == null) {
        TalkerService.warning(
            'User not signed in (lightweight failed or UI not supported).',
            'GOOGLE_SIGNIN');
        return null;
      }

      TalkerService.info('User signed in: ${account.email}', 'GOOGLE_SIGNIN');

      final String? idToken = account.authentication.idToken;
      TalkerService.info('Authentication successful', 'GOOGLE_SIGNIN');

      return idToken;
    } catch (error) {
      TalkerService.error('Error during Google Sign-In', 'GOOGLE_SIGNIN', error);
      TalkerService.error('Error details: ${error.toString()}', 'GOOGLE_SIGNIN');
      return null;
    }
  }

  static Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await GoogleSignIn.instance.initialize(
      serverClientId:
          '466603345246-r99b4r8056lqhgrcsagpoolmvc73pjdk.apps.googleusercontent.com',
    );
    _initialized = true;
  }
}
