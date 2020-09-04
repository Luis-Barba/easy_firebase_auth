import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_firebase_auth/easy_firebase_auth.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AuthProvider(
      splashScreenDurationMillis: 500,
      child: MaterialApp(
          home: AuthManagerWidget(
        splashScreen: SplashScreen(),
        loggedScreen: LoggedScreen(),
        notLoggedScreen: NotLoggedScreen(),
        actionsAfterLogIn: (method, user) async {
          // Initialize user data here
        },
        actionsBeforeLogOut: (user) async {
          // Stop listeners, remove notification tokens...
        },
      )),
    );
  }
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          "SPLASH SCREEN",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class LoggedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AuthState authState = Provider.of(context);
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: RaisedButton(
          onPressed: () {
            authState.signOut();
          },
          child: Text('Sign out'),
        ),
      ),
    );
  }
}

class NotLoggedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // You can set your custom strings
    // you can add the privacy of your app with markdown with the necessary links
    AuthStrings authStrings = AuthStrings.spanish(
        privacyMarkdown:
            "Al continuar aceptas la [política de privacidad](https://myPrivacyUrl.com) "
            "y las [condiciones de servicio](https://myTermsUrl.com).");

    return LoginScreen(
      authStrings: authStrings,
      backgroundColor: Colors.purple,
      expandedWidget: Center(
        child: Container(
          height: 200,
          width: 300,
          color: Colors.red,
        ),
      ),
    );
  }
}
