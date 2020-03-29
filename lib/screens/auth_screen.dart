import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../states/auth_state.dart';

class AuthManagerWidget extends StatefulWidget {
  final Widget splashScreen, introductionScreen, loginScreen, mainScreen;

  AuthManagerWidget(
      {Key key,
      this.splashScreen,
      this.introductionScreen,
      @required this.loginScreen,
      @required this.mainScreen})
      : super(key: key);

  @override
  _AuthManagerWidgetState createState() => _AuthManagerWidgetState();
}

class _AuthManagerWidgetState extends State<AuthManagerWidget> {
  @override
  Widget build(BuildContext context) {
    AuthState authModel = Provider.of<AuthState>(context);

    switch (authModel.authStatus) {
      case AuthStatus.CHECKING:
        return widget.splashScreen != null ? widget.splashScreen : Scaffold();

      case AuthStatus.NOT_LOGGED_FIRST_OPEN:
        return widget.introductionScreen != null
            ? widget.introductionScreen
            : widget.loginScreen;

      case AuthStatus.NOT_LOGGED_INTRO_COMPLETE:
        return widget.loginScreen;

      case AuthStatus.LOGGED:
        return widget.mainScreen;

      default:
        return null;
    }
  }
}
