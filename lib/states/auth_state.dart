import 'dart:async';
import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_twitter/flutter_twitter.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AuthStatus {
  CHECKING, // verifying login
  NOT_LOGGED_FIRST_OPEN, // user not logged & intro not completed
  NOT_LOGGED_INTRO_COMPLETE, // user not logged & intro completed
  LOGGED // user logged
}

enum AuthMethod {
  EMAIL,
  GOOGLE,
  APPLE,
  FACEBOOK,
  TWITTER,
  ANONYMOUS,
  NULL // If already logged
}

/// [_onLogin] & [_onLogout] are called only one time after sign in or sign out
class AuthState extends ChangeNotifier {
  Function(AuthMethod) _onLogin;
  Function() _onLogout;
  final int splashScreenDurationMillis;

  _MyFirebaseAuth _myFirebaseAuth;

  bool _introductionCompleted;

  AuthStatus _authStatus = AuthStatus.CHECKING;

  bool _splashScreenComplete = false;

  AuthState({this.splashScreenDurationMillis = 0}) {
    _setSplashScreenComplete();

    _myFirebaseAuth = _MyFirebaseAuth((user) {
      if (user != null) {
        _onUserLogged(AuthMethod.NULL, user);
      } else {
        _onUserNotLogged();
      }
    });
  }

  setOnLoginListener(Function(AuthMethod) onLogin) {
    this._onLogin = onLogin;
  }

  setOnLogoutListener(Function() onLogout) {
    this._onLogout = onLogout;
  }

  Future _onUserNotLogged() async {
    _introductionCompleted =
        await _MySharedPreferences.getIntroductionCompleted();
    if (_introductionCompleted) {
      _authStatus = AuthStatus.NOT_LOGGED_INTRO_COMPLETE;
    } else {
      _authStatus = AuthStatus.NOT_LOGGED_FIRST_OPEN;
    }

    notifyListeners();
  }

  Future _onUserLogged(AuthMethod method, User user) async {
    _authStatus = AuthStatus.LOGGED;
    notifyListeners();
  }

  _setSplashScreenComplete() {
    if (splashScreenDurationMillis > 0) {
      Future.delayed(Duration(milliseconds: splashScreenDurationMillis))
          .then((_) {
        _splashScreenComplete = true;

        notifyListeners();
      });
    } else {
      _splashScreenComplete = true;
    }
  }

  setIntroductionCompleted(bool b) {
    _MySharedPreferences.setIntroductionCompleted(b);
    _introductionCompleted = b;
    if ((b) && (_authStatus == AuthStatus.NOT_LOGGED_FIRST_OPEN)) {
      _authStatus = AuthStatus.NOT_LOGGED_INTRO_COMPLETE;
      notifyListeners();
    }
  }

  Future<bool> supportsAppleSignIn() async {
    return !kIsWeb && await AppleSignIn.isAvailable();
  }

  Future<User> signInAnonymous() async {
    var user = await _myFirebaseAuth.signInAnonymous();
    if (user != null) {
      _onUserLogged(AuthMethod.ANONYMOUS, user);
      _onLogin?.call(AuthMethod.ANONYMOUS);
    }
    return user;
  }

  Future<User> signInGoogle() async {
    var user = await _myFirebaseAuth.signInGoogle();
    if (user != null) {
      _onUserLogged(AuthMethod.GOOGLE, user);
      _onLogin?.call(AuthMethod.GOOGLE);
    }
    return user;
  }


  Future<User> signInTwitter(String twitterConsumerKey, String twitterConsumerSecret) async {
    var user = await _myFirebaseAuth.signInTwitter(twitterConsumerKey, twitterConsumerSecret);
    if (user != null) {
      _onUserLogged(AuthMethod.TWITTER, user);
      _onLogin?.call(AuthMethod.TWITTER);
    }
    return user;
  }


  Future<User> signInFacebook(List<String> permissions) async {
    var user = await _myFirebaseAuth.signInFacebook(permissions);
    if (user != null) {
      _onUserLogged(AuthMethod.FACEBOOK, user);
      _onLogin?.call(AuthMethod.FACEBOOK);
    }
    return user;
  }

  Future<User> signInApple() async {
    var user = await _myFirebaseAuth.signInApple();
    if (user != null) {
      _onUserLogged(AuthMethod.APPLE, user);
      _onLogin?.call(AuthMethod.APPLE);
    }
    return user;
  }

  Future<User> signInWithEmail(String email, String password) async {
    var user = await _myFirebaseAuth.signInWithEmail(email, password);
    if (user != null) {
      _onUserLogged(AuthMethod.EMAIL, user);
      _onLogin?.call(AuthMethod.EMAIL);
    }
    return user;
  }

  Future<User> signUpWithEmail(
      String email, String password, String name) async {
    var user = await _myFirebaseAuth.signUpWithEmail(email, password, name);
    if (user != null) {
      await changeName(name);
      _onUserLogged(AuthMethod.EMAIL, user);
      _onLogin?.call(AuthMethod.EMAIL);
    }
    return user;
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

  Future<void> signOut() async {
    await _myFirebaseAuth.signOut();
    _onUserNotLogged();
    _onLogout?.call();
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

  User get user => _myFirebaseAuth?._myUser;
}

///
///
///
///
///
/// SHARED PREFERENCES
///
///
///
///
///
class _MySharedPreferences {
  static const _INTRODUCTION_COMPLETED = 'introduction_completed';

  static Future<bool> getIntroductionCompleted() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_INTRODUCTION_COMPLETED) ?? false;
  }

  static Future<void> setIntroductionCompleted(bool completed) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_INTRODUCTION_COMPLETED, completed);
  }
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
    _myUser=_firebaseAuth.currentUser;
    onUser(_myUser);
  }

  bool isAnonymous() {
    if (_myUser != null) return myUser.isAnonymous;

    return true;
  }

  ///AUTH METHODS///
  Future<User> signInAnonymous() async {
    UserCredential result = await _firebaseAuth.signInAnonymously();
    User user = result.user;
    _myUser = user;
    return _myUser;
  }

  Future<User> signInGoogle() async {
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();

    if (googleUser != null) {
      GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _firebaseAuth.signInWithCredential(credential);
      User user = result.user;

      _myUser = user;
      return _myUser;
    }

    return null;
  }



  Future<User> signInTwitter(String twitterConsumerKey, String twitterConsumerSecret) async {
    var twitterLogin = new TwitterLogin(
      consumerKey: twitterConsumerKey,
      consumerSecret: twitterConsumerSecret,
    );

    final TwitterLoginResult result = await twitterLogin.authorize();
    switch (result.status) {
      case TwitterLoginStatus.loggedIn:
        AuthCredential credential = TwitterAuthProvider.credential(
            accessToken: result.session.token,
            secret: result.session.secret);
        await _firebaseAuth.signInWithCredential(credential); //AuthResult

        User user = _firebaseAuth.currentUser;

        _myUser = user;
        return _myUser;

        break;
      case TwitterLoginStatus.cancelledByUser:
        print("Login cancelled");
        break;
      case TwitterLoginStatus.error:
        print("Twitter login error: "+result.errorMessage);
        break;
    }

    return null;
  }



  Future<User> signInFacebook(List<String> permissions) async {
    var facebookLogin = new FacebookLogin();
    FacebookLoginResult result = await facebookLogin.logIn(permissions);


    if (result.accessToken != null) {
      try {
        AuthCredential credential = FacebookAuthProvider.credential(result.accessToken.token);
        UserCredential authResult = await _firebaseAuth.signInWithCredential(credential);
        User user = authResult.user;
        _myUser = user;
        return _myUser;


      } catch (e) {
        print("facebook login error: "+e.toString());
        //showErrorDialog(context, e.details);
      }
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
            print("successfull sign in");
            final AppleIdCredential appleIdCredential = result.credential;

            OAuthProvider oAuthProvider =
                new OAuthProvider("apple.com");
            final AuthCredential credential = oAuthProvider.credential(
              idToken: String.fromCharCodes(appleIdCredential.identityToken),
              accessToken:
                  String.fromCharCodes(appleIdCredential.authorizationCode),
            );

            await _firebaseAuth.signInWithCredential(credential); //UserCredential

            User val = _firebaseAuth.currentUser;
            await val.updateProfile(displayName:"${appleIdCredential.fullName.givenName} ${appleIdCredential.fullName.familyName}" , /*photoURL: "define an url"*/);

            User user = _firebaseAuth.currentUser;

            _myUser = user;
            return _myUser;
          } catch (e) {
            print("error");
          }
          break;
        case AuthorizationStatus.error:
          // do something
          break;

        case AuthorizationStatus.cancelled:
          print('User cancelled');
          break;
      }
    } catch (error) {
      print("error with apple sign in");
    }

    return null;
  }

  Future<User> signInWithEmail(String email, String password) async {
    UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    User user = result.user;

    _myUser = user;
    return _myUser;
  }

  Future<User> signUpWithEmail(
      String email, String password, String name) async {
    UserCredential result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    User user = result.user;

    _myUser = user;

    return _myUser;
  }

  Future<bool> isEmailRegistered(String e) async {
    var list = await _firebaseAuth.fetchSignInMethodsForEmail(e);
    return list != null && list.isNotEmpty;
  }

  Future<void> sendEmailVerification() async {
    User user = _firebaseAuth.currentUser;
    user.sendEmailVerification();
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
    _myUser =  _firebaseAuth.currentUser;

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
