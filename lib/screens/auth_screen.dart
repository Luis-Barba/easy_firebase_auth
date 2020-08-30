import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../states/auth_state.dart';

class AuthManagerWidget extends StatefulWidget {
  final Widget splashScreen, loginScreen, mainScreen;
  final Function(AuthMethod) onLogin;
  final Function() onLogout;

  AuthManagerWidget(
      {Key key,
      this.splashScreen,
      this.onLogin,
      this.onLogout,
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
    authModel.setOnLoginListener(widget.onLogin);
    authModel.setOnLogoutListener(widget.onLogout);

    switch (authModel.authStatus) {
      case AuthStatus.CHECKING:
        return widget.splashScreen != null ? widget.splashScreen : Scaffold();

      case AuthStatus.NOT_LOGGED:
        return widget.loginScreen;

      case AuthStatus.LOGGED:
        return widget.mainScreen;

      default:
        return null;
    }
  }
}
