import 'package:flutter/material.dart';
import 'package:easy_firebase_auth/widgets/buttons/sign_in_button.dart';

class EmailSignInButton extends StatelessWidget {
  final double? height, width;
  final String text;
  final bool darkMode;
  final VoidCallback? onPressed;
  final bool centerText;
  final TextStyle? textStyle;
  final ButtonStyle? buttonStyle;
  final Color lightTextColor, lightButtonColor, darkTextColor, darkButtonColor;

  EmailSignInButton(
      {this.height,
      this.width,
      this.onPressed,
      this.text = 'Sign in with Email',
      this.darkMode = false,
      this.centerText = false,
      this.textStyle,
      this.buttonStyle,
      Key? key,
      this.lightTextColor = Colors.black,
      this.lightButtonColor = Colors.white,
      this.darkTextColor = Colors.white,
      this.darkButtonColor = Colors.green})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color buttonColor = darkMode ? darkButtonColor : lightButtonColor;
    Color textColor = darkMode ? darkTextColor : lightTextColor;

    Widget leading = Icon(
      Icons.email,
      color: textColor,
      size: 24,
    );

    return SignInButton(
      height: height,
      width: width,
      onPressed: onPressed,
      text: text,
      leading: leading,
      centerText: centerText,
      style: buttonStyle ??
          ElevatedButton.styleFrom(
            primary: buttonColor,
            onPrimary: textColor,
            textStyle: textStyle ??
                TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
          ),
    );
  }
}
