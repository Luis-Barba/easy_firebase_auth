import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_firebase_auth/values/auth_strings.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../states/auth_state.dart';

const String _logTitle = "easy_firebase_auth";

class EmailLoginScreen extends StatefulWidget {
  final AppBar appBar;
  final Color mainColor, shimmerColor1, shimmerColor2;

  final AuthStrings authStrings;

  const EmailLoginScreen(
      {Key key,
      this.appBar,
      this.mainColor, //not white
      this.shimmerColor1,
      this.shimmerColor2,
      this.authStrings})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => new _EmailLoginScreenState();
}

enum _Mode { LOGIN, SIGN_UP }

class _EmailLoginScreenState extends State<EmailLoginScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  AuthState _authState;

  bool _isEmailRegistered;
  String _email;
  String _password;
  String _name;

  String _errorMessage;

  bool _loading;

  @override
  void initState() {
    _loading = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AuthStrings strings = widget.authStrings ?? AuthStrings.english();

    _authState = Provider.of<AuthState>(context);

    Color mainColor = widget.mainColor ?? Theme.of(context).primaryColor;

    _accessWithEmail(_Mode mode) async {
      setState(() {
        _loading = true;
        _errorMessage = "";
      });

      try {
        if (mode == _Mode.LOGIN) {
          await _authState.signInWithEmail(_email, _password);
        } else {
          await _authState.signUpWithEmail(_email, _password, _name);
        }

        setState(() {
          _loading = false;
        });

        Navigator.pop(context);
      } catch (e) {
        /// Errors:
        ///   • `ERROR_WEAK_PASSWORD` - If the password is not strong enough.
        ///   • `ERROR_INVALID_EMAIL` - If the email address is malformed.
        ///   • `ERROR_EMAIL_ALREADY_IN_USE` - If the email is already in use by a different account.
        ///
        ///
        ///   • `ERROR_INVALID_EMAIL` - If the [email] address is malformed.
        ///   • `ERROR_WRONG_PASSWORD` - If the [password] is wrong.
        ///   • `ERROR_USER_NOT_FOUND` - If there is no user corresponding to the given [email] address, or if the user has been deleted.
        ///   • `ERROR_USER_DISABLED` - If the user has been disabled (for example, in the Firebase console)
        ///   • `ERROR_TOO_MANY_REQUESTS` - If there was too many attempts to sign in as this user.
        ///   • `ERROR_OPERATION_NOT_ALLOWED` - Indicates that Email & Password accounts are not enabled.

        String errorCode;
        String message;

        if (e is PlatformException) {
          errorCode = e.code;
          message = e.message;
        } else {
          errorCode = "UNKNOWN";
          message = "Unknown error";
        }

        switch (errorCode) {
          case "ERROR_WEAK_PASSWORD":
            message = strings.errorWeakPassword;
            break;
          case "ERROR_INVALID_EMAIL":
            message = strings.errorInvalidEmail;
            break;
          case "ERROR_EMAIL_ALREADY_IN_USE":
            message = strings.errorEmailAlreadyInUse;
            break;
          case "ERROR_WRONG_PASSWORD":
            message = strings.errorWrongPassword;
            break;
          case "ERROR_USER_NOT_FOUND":
            message = strings.errorUserNotFound;
            break;
          case "ERROR_USER_DISABLED":
            message = strings.errorUserDisabled;
            break;
          case "ERROR_TOO_MANY_REQUESTS":
            message = strings.errorTooManyRequests;
            break;
          case "ERROR_OPERATION_NOT_ALLOWED":
            message = strings.errorOperationNotAllowed;
            break;
        }

        setState(() {
          _loading = false;
          _errorMessage = message;
        });
      }
    }

    Widget _showErrorMessage() {
      if (_errorMessage != null && _errorMessage.length > 0) {
        return Center(
          child: Text(
            _errorMessage,
            style: TextStyle(
                fontSize: 13.0,
                color: Colors.red,
                height: 1.0,
                fontWeight: FontWeight.w300),
          ),
        );
      } else {
        return Container(
          height: 0.0,
        );
      }
    }

    _showResetPasswordSnackBar(String mail) {
      final snackBar = SnackBar(
        content:
            Text(strings.emailSentToChangePassword.replaceAll('\$', '$mail')),
        duration: Duration(seconds: 30),
        action: SnackBarAction(
          label: strings.understood,
          onPressed: () {
            // Some code to undo the change.
            _scaffoldKey.currentState.hideCurrentSnackBar();
          },
        ),
      );
      _scaffoldKey.currentState.showSnackBar(snackBar);
    }

    _showDialogForResetPassword(String mail) {
      showDialog(
          context: context,
          builder: (BuildContext ctx) {
            return AlertDialog(
              title: Text(strings.changePassword),
              content: Text(strings.weWillSendYouAnEmailToChangePassword
                  .replaceAll('\$', '$mail')),
              actions: <Widget>[
                FlatButton(
                  child: Text(strings.cancel),
                  onPressed: () => {Navigator.of(ctx).pop()},
                ),
                FlatButton(
                  child: Text(strings.accept),
                  onPressed: () => {
                    setState(() => {_loading = true}),
                    _authState.resetPassword(mail).then((_) => {
                          _showResetPasswordSnackBar(mail),
                          setState(() => {_loading = false}),
                        }),
                    Navigator.of(context).pop()
                  },
                )
              ],
            );
          });
    }

    _getEmailInput() {
      return Container(
          padding: EdgeInsets.all(16.0),
          child: new Form(
              key: _formKey,
              child: ListView(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 16, 0, 32),
                    child: TextFormField(
                      maxLines: 1,
                      keyboardType: TextInputType.emailAddress,
                      autofocus: false,
                      decoration: InputDecoration(
                          hintText: strings.email,
                          icon: Icon(
                            Icons.mail,
                            color: Colors.grey,
                          )),
                      validator: (value) {
                        if (value.isEmpty) {
                          return strings.emailCantBeEmpty;
                        } else if (!isValidEmail(value)) {
                          return strings.emailNotValid;
                        }
                        return null;
                      },
                      onSaved: (value) => _email = value,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      RaisedButton(
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            _formKey.currentState.save();
                            setState(() {
                              _loading = true;
                            });
                            _isEmailRegistered =
                                await _authState.isEmailRegistered(_email);
                            log("$_email $_isEmailRegistered", name: _logTitle);
                            setState(() {
                              _loading = false;
                            });
                          }
                        },
                        color: mainColor,
                        child: Text(
                          strings.next,
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    ],
                  )
                ],
              )));
    }

    _getPasswordInput() {
      return Container(
          padding: EdgeInsets.all(16.0),
          child: new Form(
              key: _formKey,
              child: ListView(
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    height: 110,
                    child: Markdown(
                      data: strings.emailRegisteredEnterPasswordNoticeMarkdown
                          .replaceAll("\$", "$_email"),
                      styleSheet:
                          MarkdownStyleSheet.fromTheme(Theme.of(context))
                              .copyWith(
                                  p: Theme.of(context)
                                      .textTheme
                                      .bodyText2
                                      .copyWith(fontSize: 16)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 16, 0, 32),
                    child: new TextFormField(
                      maxLines: 1,
                      obscureText: true,
                      autofocus: false,
                      decoration: InputDecoration(
                          hintText: strings.passwordHint,
                          icon: Icon(
                            Icons.lock,
                            color: Colors.grey,
                          )),
                      validator: (value) {
                        if (value.isEmpty) {
                          return strings.passwordEmpty;
                        }

                        //This check is not done in sign up
                        /*if(value.length<6){
                          return strings.passwordTooShort;
                        }*/

                        return null;
                      },
                      onSaved: (value) => _password = value,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(right: 16),
                          child: FlatButton(
                            child: Text(
                              strings.forgotPassword,
                              style: TextStyle(color: mainColor),
                            ),
                            onPressed: () {
                              _showDialogForResetPassword(_email);
                            },
                          ),
                        ),
                      ),
                      RaisedButton(
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            _formKey.currentState.save();
                            log("$_email $_password", name: _logTitle);
                            await _accessWithEmail(_Mode.LOGIN);
                          }
                        },
                        color: mainColor,
                        child: Text(
                          strings.next,
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: _showErrorMessage(),
                  ),
                ],
              )));
    }

    _getSignUpInput() {
      return Container(
          padding: EdgeInsets.all(16.0),
          child: new Form(
              key: _formKey,
              child: ListView(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
                    child: new TextFormField(
                      maxLines: 1,
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.words,
                      autofocus: false,
                      decoration: InputDecoration(
                          hintText: strings.nameHint,
                          icon: Icon(
                            Icons.person,
                            color: Colors.grey,
                          )),
                      validator: (value) {
                        var name = value.trim();
                        if (name.isEmpty) {
                          return strings.nameCantBeEmpty;
                        }
                        return null;
                      },
                      onSaved: (value) => _name = value.trim(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
                    child: new TextFormField(
                      maxLines: 1,
                      obscureText: true,
                      autofocus: false,
                      decoration: InputDecoration(
                          hintText: strings.passwordHint,
                          icon: Icon(
                            Icons.lock,
                            color: Colors.grey,
                          )),
                      validator: (value) {
                        if (value.isEmpty) {
                          return strings.passwordEmpty;
                        } else if (value.length < 6) {
                          return strings.passwordTooShort;
                        }
                        return null;
                      },
                      onSaved: (value) => _password = value,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: _showErrorMessage(),
                  ),
                  Container(
                      padding: EdgeInsets.only(bottom: 16),
                      child: MarkdownBody(
                        data: strings.privacyMarkdown,
                        onTapLink: (url) async {
                          if (await canLaunch(url)) {
                            await launch(url);
                          } else {
                            throw 'Could not launch $url';
                          }
                        },
                      )),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      RaisedButton(
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            _formKey.currentState.save();
                            log("$_email $_password", name: _logTitle);
                            await _accessWithEmail(_Mode.SIGN_UP);
                          }
                        },
                        color: mainColor,
                        child: Text(
                          strings.next,
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    ],
                  ),
                ],
              )));
    }

    var _mainWidget = Container();
    if (_email == null && _isEmailRegistered == null) {
      _mainWidget = _getEmailInput();
    } else if (_isEmailRegistered != null && _isEmailRegistered) {
      _mainWidget = _getPasswordInput();
    } else if (_isEmailRegistered != null && !_isEmailRegistered) {
      _mainWidget = _getSignUpInput();
    }

    return Scaffold(
        key: _scaffoldKey,
        appBar: widget.appBar ??
            AppBar(
              title: Text(strings.loginAppBarTitle),
            ),
        body: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            _mainWidget,
            _loading ? CircularProgressIndicator() : Container(),
          ],
        ));
  }
}

bool isValidEmail(String email) {
  return RegExp(
          r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$")
      .hasMatch(email);
}
