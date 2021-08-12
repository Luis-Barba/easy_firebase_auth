import 'dart:async';
import 'dart:convert';
import 'dart:developer' as $;
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

const String LOG_TITLE = "easy_firebase_auth";

enum AuthStatus {
  CHECKING, // verifying login
  NOT_LOGGED, // user not logged
  LOGGED // user logged
}

enum AuthMethod {
  EMAIL,
  GOOGLE,
  APPLE,
  ANONYMOUS,
  NULL // If already logged
}

/// [_onLogin] & [_onLogout] are called only one time after sign in or sign out
class AuthState extends ChangeNotifier {
  final int splashScreenDurationMillis;
  bool autoSignInAnonymously;

  Future Function(AuthMethod, User?)? actionsAfterLogIn;
  Future Function(User?)? actionsBeforeLogOut;
  Future Function(String)? onZombieGenerated;

  late _MyFirebaseAuth _myFirebaseAuth;

  AuthStatus _authStatus = AuthStatus.CHECKING;

  bool _splashScreenComplete = false;

  AuthState(
      {this.splashScreenDurationMillis = 0,
      this.autoSignInAnonymously = false,
      this.onZombieGenerated}) {
    _init();
  }

  _init() async {
    var timeMillis = DateTime.now().millisecondsSinceEpoch;

    _myFirebaseAuth = _MyFirebaseAuth((user) async {
      if (user != null) {
        _authStatus = AuthStatus.LOGGED;
        await actionsAfterLogIn?.call(AuthMethod.NULL, user);
      } else {
        _authStatus = AuthStatus.NOT_LOGGED;
        if (autoSignInAnonymously) {
          await _signIn(AuthMethod.ANONYMOUS, shouldNotify: false);
        }
      }

      $.log("Initial auth status $_authStatus", name: LOG_TITLE);

      // Check Splash Screen remaining time
      var splashScreenRemainingTime = splashScreenDurationMillis -
          (DateTime.now().millisecondsSinceEpoch - timeMillis);

      if (splashScreenRemainingTime > 0) {
        Future.delayed(Duration(milliseconds: splashScreenRemainingTime))
            .then((_) {
          _splashScreenComplete = true;
          notifyListeners();
        });
      } else {
        _splashScreenComplete = true;
        notifyListeners();
      }
    });
  }

  // Todo: Add support for Android
  Future<bool> supportsAppleSignIn() async {
    return Platform.isIOS && await SignInWithApple.isAvailable();
  }

  Future<User?> signInAnonymous() async {
    return _signIn(AuthMethod.ANONYMOUS);
  }

  Future<User?> signInGoogle() async {
    return _signIn(AuthMethod.GOOGLE);
  }

  Future<User?> signInApple() async {
    return _signIn(AuthMethod.APPLE);
  }

  Future<User?> signInWithEmail(String email, String password) async {
    return _signIn(AuthMethod.EMAIL, email: email, password: password);
  }

  Future<User?> signUpWithEmail(
      String email, String password, String name) async {
    if (_authStatus == AuthStatus.LOGGED) {
      await signOut(shouldNotify: false, canReauthenticate: false);
    }
    var user = await _myFirebaseAuth.signUpWithEmail(email, password, name);

    if (user != null) {
      await changeName(name);
      _authStatus = AuthStatus.LOGGED;
      $.log("Status $_authStatus", name: LOG_TITLE);

      await actionsAfterLogIn?.call(AuthMethod.EMAIL, firebaseUser);
    }

    notifyListeners();

    return user;
  }

  /// [email] only for sign in with email
  /// [password] only for sign in with email
  Future<User?> _signIn(AuthMethod method,
      {String email = "",
      String password = "",
      bool shouldNotify = true}) async {
    String? previousUid = uid;
    bool wasAnonymous = isAnonymous;

    User? user;

    switch (method) {
      case AuthMethod.EMAIL:
        user = await _myFirebaseAuth.signInWithEmail(email, password);
        break;

      case AuthMethod.GOOGLE:
        user = await _myFirebaseAuth.signInGoogle();
        break;

      case AuthMethod.APPLE:
        user = await _myFirebaseAuth.signInApple();
        break;

      case AuthMethod.ANONYMOUS:
        user = await _myFirebaseAuth.signInAnonymous();
        break;

      case AuthMethod.NULL:
        // Nothing to do
        break;
    }

    if (user != null) {
      // Successful Login
      _authStatus = AuthStatus.LOGGED;
      $.log("Status $_authStatus", name: LOG_TITLE);

      // Check Zombie
      if (wasAnonymous && previousUid != null) {
        $.log("Zombie: $previousUid", name: LOG_TITLE);
        await onZombieGenerated?.call(previousUid);
      }

      await actionsAfterLogIn?.call(method, firebaseUser);
      if (shouldNotify) notifyListeners();
    } else {
      // Fail
    }

    return user;
  }

  Future<void> signOut(
      {bool shouldNotify = true, bool canReauthenticate = true}) async {
    String? previousUid = uid;
    bool wasAnonymous = isAnonymous;

    await actionsBeforeLogOut?.call(firebaseUser);

    await _myFirebaseAuth.signOut();
    _authStatus = AuthStatus.NOT_LOGGED;
    $.log("Status $_authStatus", name: LOG_TITLE);

    if (autoSignInAnonymously && canReauthenticate) {
      await _signIn(AuthMethod.ANONYMOUS, shouldNotify: false);
    }

    if (wasAnonymous && previousUid != null) {
      $.log("Zombie: $previousUid", name: LOG_TITLE);
      await onZombieGenerated?.call(previousUid);
    }

    if (shouldNotify) notifyListeners();
  }

  Future<bool> isEmailRegistered(String e) async {
    return await _myFirebaseAuth.isEmailRegistered(e);
  }

  Future<void> sendEmailVerification() async {
    await _myFirebaseAuth.sendEmailVerification();
  }

  ///CHANGES///
  Future<void> resetPassword(email) async {
    await _myFirebaseAuth.resetPassword(email);
  }

  Future<void> changePhotoUrl(String photoUrl) async {
    await _myFirebaseAuth.changePhotoUrl(photoUrl);
  }

  Future<void> changeName(String name) async {
    await _myFirebaseAuth.changeName(name);
  }

  AuthStatus get authStatus =>
      _splashScreenComplete ? _authStatus : AuthStatus.CHECKING;

  bool get isAnonymous => _myFirebaseAuth.isAnonymous();

  String? get name => _myFirebaseAuth.myUser?.displayName;

  String? get email => _myFirebaseAuth.myUser?.email;

  String? get uid => _myFirebaseAuth.myUser?.uid;

  String? get photoUrl => _myFirebaseAuth.myUser?.photoURL;

  User? get firebaseUser => _myFirebaseAuth.myUser;
}

///
///
///
///
///
/// FIREBASE AUTH
///
///
///
///
///

class _MyFirebaseAuth {
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  GoogleSignIn _googleSignIn = GoogleSignIn();

  _MyFirebaseAuth(Function(User?) onUser) {
    _firebaseAuth.authStateChanges().first.then((user) {
      onUser(user);
    });
  }

  bool isAnonymous() {
    return myUser?.isAnonymous ?? true;
  }

  ///AUTH METHODS///
  Future<User?> signInAnonymous() async {
    UserCredential result = await _firebaseAuth.signInAnonymously();
    return result.user;
  }

  Future<User?> signInGoogle() async {
    GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser != null) {
      GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result =
          await _firebaseAuth.signInWithCredential(credential);

      return result.user;
    }

    return null;
  }

  /// Generates a cryptographically secure random nonce, to be included in a
  /// credential request.
  String _generateNonce([int length = 32]) {
    final charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<User?> signInApple() async {
    // To prevent replay attacks with the credential returned from Apple, we
    // include a nonce in the credential request. When signing in with
    // Firebase, the nonce in the id token returned by Apple, is expected to
    // match the sha256 hash of `rawNonce`.
    final rawNonce = _generateNonce();
    final nonce = _sha256ofString(rawNonce);

    try {
      final appleIdCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce
      );

      OAuthProvider oAuthProvider = new OAuthProvider("apple.com");
      final AuthCredential credential = oAuthProvider.credential(
        idToken: appleIdCredential.identityToken,
        accessToken: appleIdCredential.authorizationCode,
        rawNonce: rawNonce
      );

      await _firebaseAuth.signInWithCredential(credential); //AuthResult

      var displayName =
          "${appleIdCredential.givenName} ${appleIdCredential.familyName}";

      await _firebaseAuth.currentUser?.updateDisplayName(displayName);

      return _firebaseAuth.currentUser;
    } catch (e) {
      $.log("error with apple sign in", name: LOG_TITLE, error: e);
    }
    return null;
  }

  Future<User?> signInWithEmail(String email, String password) async {
    UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);

    return result.user;
  }

  Future<User?> signUpWithEmail(
      String email, String password, String name) async {
    UserCredential result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);

    return result.user;
  }

  Future<bool> isEmailRegistered(String e) async {
    var list = await _firebaseAuth.fetchSignInMethodsForEmail(e);
    return list.isNotEmpty;
  }

  Future<void> sendEmailVerification() async {
    _firebaseAuth.currentUser?.sendEmailVerification();
  }

  ///CHANGES///
  Future<void> resetPassword(email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<User?> changePhotoUrl(String photoUrl) async {
    await myUser?.updatePhotoURL(photoUrl);
    //await _myUser.reload(); //NO FUNCIONA
    return myUser;
  }

  Future<User?> changeName(String name) async {
    await myUser?.updateDisplayName(name);
    //await _myUser.reload(); //NO FUNCIONA

    return myUser;
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  Future<void> deleteUser() async {
    if (myUser != null) {
      await myUser?.delete();
    }
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  User? get myUser => _firebaseAuth.currentUser;
}
