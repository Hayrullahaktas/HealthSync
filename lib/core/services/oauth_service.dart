import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../constants/auth_constants.dart';

class OAuthService {
  final GoogleSignIn _googleSignIn;
  final FacebookAuth _facebookAuth;

  OAuthService()
      : _googleSignIn = GoogleSignIn(
    scopes: AuthConstants.googleScopes,
    clientId: AuthConstants.googleClientId,
  ),
        _facebookAuth = FacebookAuth.instance;

  // Google ile giriş
  Future<GoogleSignInAuthentication?> signInWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return null;

      return await account.authentication;
    } catch (e) {
      return null;
    }
  }

  // Facebook ile giriş
  Future<Map<String, dynamic>?> signInWithFacebook() async {
    try {
      final result = await _facebookAuth.login();

      if (result.status == LoginStatus.success) {
        final userData = await _facebookAuth.getUserData();
        return {
          'token': result.accessToken?.token,
          'userData': userData,
        };
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Google hesabından çıkış
  Future<void> signOutGoogle() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      // Handle error
    }
  }

  // Facebook hesabından çıkış
  Future<void> signOutFacebook() async {
    try {
      await _facebookAuth.logOut();
    } catch (e) {
      // Handle error
    }
  }

  // Google hesap durumunu kontrol et
  Future<bool> isGoogleSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }

  // Facebook hesap durumunu kontrol et
  Future<bool> isFacebookSignedIn() async {
    final accessToken = await _facebookAuth.accessToken;
    return accessToken != null;
  }
}