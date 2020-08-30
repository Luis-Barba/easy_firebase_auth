import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_firebase_auth/easy_firebase_auth.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthState>(
      child: MaterialApp(
        home: ParentPage(),
      ),
      create: (_) => AuthState(
          splashScreenDurationMillis:
              2000), // You can set the splash screen duration
    );
  }
}

class ParentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // You can set your custom strings
    // you can add the privacy of your app with markdown with the necessary links
    AuthStrings authStrings = AuthStrings.spanish(
        privacyMarkdown:
            "Al continuar aceptas la [política de privacidad](https://myPrivacyUrl.com) "
            "y las [condiciones de servicio](https://myTermsUrl.com).");

    var actionsAfterLogIn = (a, b) async {
      await Future.delayed(Duration(seconds: 1));
      print("actionsAfterLogIn $a");
    };

    var actionsBeforeLogOut = (_) async {
      await Future.delayed(Duration(seconds: 1));
      print("actionsBeforeLogOut $_");
    };

    return AuthManagerWidget(
      actionsAfterLogIn : actionsAfterLogIn,
      actionsBeforeLogOut : actionsBeforeLogOut,

      splashScreen: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            "Splash Screen",
            style: TextStyle(fontSize: 40, color: Colors.white),
          ),
        ),
      ),
      //introductionScreen: MyIntroductionScreen(),
      loginScreen: LoginScreen(
        authStrings: authStrings,
        backgroundColor: Colors.purple,
        expandedWidget: Center(
          child: Container(
            height: 200,
            width: 300,
            color: Colors.red,
          ),
        ),
      ),
      mainScreen: Builder(
        builder: (BuildContext context) {
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
        },
      ),
    );
  }
}
