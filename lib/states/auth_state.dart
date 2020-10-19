import 'dart:async';
import 'dart:developer';
import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

const String _logTitle = "easy_firebase_auth";

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

  Future Function(AuthMethod, User) actionsAfterLogIn;
  Future Function(User) actionsBeforeLogOut;
  Future Function(String) onZombieGenerated;

  _MyFirebaseAuth _myFirebaseAuth;

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

      log("Initial auth status $_authStatus", name: _logTitle);

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

  Future<bool> supportsAppleSignIn() async {
    return !kIsWeb && await AppleSignIn.isAvailable();
  }

  Future<User> signInAnonymous() async {
    return _signIn(AuthMethod.ANONYMOUS);
  }

  Future<User> signInGoogle() async {
    return _signIn(AuthMethod.GOOGLE);
  }

  Future<User> signInApple() async {
    return _signIn(AuthMethod.APPLE);
  }

  Future<User> signInWithEmail(String email, String password) async {
    return _signIn(AuthMethod.EMAIL, email: email, password: password);
  }

  Future<User> signUpWithEmail(
      String email, String password, String name) async {
    if (_authStatus == AuthStatus.LOGGED) {
      await signOut(shouldNotify: false, canReauthenticate: false);
    }
    var user = await _myFirebaseAuth.signUpWithEmail(email, password, name);

    if (user != null) {
      await changeName(name);
      _authStatus = AuthStatus.LOGGED;
      log("Status $_authStatus", name: _logTitle);

      await actionsAfterLogIn?.call(AuthMethod.EMAIL, firebaseUser);
    }

    notifyListeners();

    return user;
  }

  /// [email] only for sign in with email
  /// [password] only for sign in with email
  Future<User> _signIn(AuthMethod method,
      {String email, String password, bool shouldNotify = true}) async {
    if (_authStatus == AuthStatus.LOGGED) {
      await signOut(shouldNotify: false, canReauthenticate: false);
    }

    User user;

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
      _authStatus = AuthStatus.LOGGED;
      log("Status $_authStatus", name: _logTitle);
    }

    await actionsAfterLogIn?.call(method, firebaseUser);

    if (shouldNotify) notifyListeners();

    return user;
  }

  Future<void> signOut(
      {bool shouldNotify = true, bool canReauthenticate = true}) async {
    String previousUid = uid;
    bool wasAnonymous = isAnonymous;

    await actionsBeforeLogOut?.call(firebaseUser);

    await _myFirebaseAuth.signOut();
    _authStatus = AuthStatus.NOT_LOGGED;
    log("Status $_authStatus", name: _logTitle);

    if (autoSignInAnonymously && canReauthenticate) {
      await _signIn(AuthMethod.ANONYMOUS, shouldNotify: false);
    }

    if (wasAnonymous && previousUid != null) {
      log("Zombie: $previousUid", name: _logTitle);
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

  String get name => _myFirebaseAuth.myUser != null
      ? _myFirebaseAuth.myUser.displayName
      : null;

  String get email =>
      _myFirebaseAuth.myUser != null ? _myFirebaseAuth.myUser.email : null;

  String get uid =>
      _myFirebaseAuth.myUser != null ? _myFirebaseAuth.myUser.uid : null;

  String get photoUrl =>
      _myFirebaseAuth.myUser != null ? _myFirebaseAuth.myUser.photoURL : null;

  User get firebaseUser => _myFirebaseAuth?._myUser;
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
  User _myUser;
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  GoogleSignIn _googleSignIn = GoogleSignIn();

  _MyFirebaseAuth(Function(User) onUser) {
    _firebaseAuth.authStateChanges().first.then((user) {
      _myUser = user;
      onUser(user);
    });
  }

  bool isAnonymous() {
    if (_myUser != null) return myUser.isAnonymous;
    return true;
  }

  ///AUTH METHODS///
  Future<User> signInAnonymous() async {
    UserCredential result = await _firebaseAuth.signInAnonymously();
    _myUser = result.user;
    return _myUser;
  }

  Future<User> signInGoogle() async {
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();

    if (googleUser != null) {
      GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result =
          await _firebaseAuth.signInWithCredential(credential);

      _myUser = result.user;
      return _myUser;
    }

    return null;
  }

  Future<User> signInApple() async {
    try {
      final AuthorizationResult result = await AppleSignIn.performRequests([
        AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
      ]);

      switch (result.status) {
        case AuthorizationStatus.authorized:
          try {
            log("Successfull sign in", name: _logTitle);
            final AppleIdCredential appleIdCredential = result.credential;

            OAuthProvider oAuthProvider = new OAuthProvider("apple.com");
            final AuthCredential credential = oAuthProvider.credential(
              idToken: String.fromCharCodes(appleIdCredential.identityToken),
              accessToken:
                  String.fromCharCodes(appleIdCredential.authorizationCode),
            );

            await _firebaseAuth.signInWithCredential(credential); //AuthResult

            var displayName =
                "${appleIdCredential.fullName.givenName} ${appleIdCredential.fullName.familyName}";

            await _firebaseAuth.currentUser
                .updateProfile(displayName: displayName);

            _myUser = _firebaseAuth.currentUser;
            return _myUser;
          } catch (e) {
            log("error", name: _logTitle);
          }
          break;
        case AuthorizationStatus.error:
          // do something
          break;

        case AuthorizationStatus.cancelled:
          log('User cancelled', name: _logTitle);
          break;
      }
    } catch (error) {
      log("error with apple sign in", name: _logTitle);
    }

    return null;
  }

  Future<User> signInWithEmail(String email, String password) async {
    UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);

    _myUser = result.user;
    return _myUser;
  }

  Future<User> signUpWithEmail(
      String email, String password, String name) async {
    UserCredential result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);

    _myUser = result.user;
    return _myUser;
  }

  Future<bool> isEmailRegistered(String e) async {
    var list = await _firebaseAuth.fetchSignInMethodsForEmail(e);
    return list != null && list.isNotEmpty;
  }

  Future<void> sendEmailVerification() async {
    _firebaseAuth.currentUser.sendEmailVerification();
  }

  ///CHANGES///
  Future<void> resetPassword(email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<User> changePhotoUrl(String photoUrl) async {
    await _myUser.updateProfile(photoURL: photoUrl);
    //await _myUser.reload(); //NO FUNCIONA
    _myUser = _firebaseAuth.currentUser;
    return _myUser;
  }

  Future<User> changeName(String name) async {
    await _myUser.updateProfile(displayName: name);
    //await _myUser.reload(); //NO FUNCIONA
    _myUser = _firebaseAuth.currentUser;

    return _myUser;
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();

    _myUser = null;
  }

  bool needsReLogInForDelete() {
    int maxTime = 5 * 60 * 1000;
    return DateTime.now().millisecondsSinceEpoch -
            _myUser.metadata.lastSignInTime.millisecondsSinceEpoch >
        maxTime;
  }

  Future<void> deleteUser() async {
    if (_myUser != null) {
      await _myUser.delete();
    }
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();

    _myUser = null;
  }

  User get myUser => _myUser;
}
