import 'package:flutter/material.dart';
import 'strechable_button.dart';

class EmailSignInButton extends StatelessWidget {
  final String text;
  final double borderRadius;
  final Color buttonColor, textColor;
  final VoidCallback onPressed;

  EmailSignInButton(
      {this.onPressed,
      this.text = 'Sign in with Email',
      this.buttonColor = Colors.green,
      this.textColor = Colors.white,
      this.borderRadius = defaultBorderRadius,
      Key key})
      : assert(text != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return StretchableButton(
      buttonColor: buttonColor,
      borderRadius: borderRadius,
      onPressed: onPressed,
      buttonPadding: 0.0,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(1.0),
          child: Container(
            height: 38.0, // 40dp - 2*1dp border
            width: 38.0, // matches above
            decoration: BoxDecoration(
              color: null,
              borderRadius: BorderRadius.circular(this.borderRadius),
            ),
            child: Center(
              child: Icon(
                Icons.email,
                color: textColor,
              ),
            ),
          ),
        ),
        SizedBox(width: 14.0 /* 24.0 - 10dp padding */),
        Padding(
          padding: const EdgeInsets.fromLTRB(0.0, 8.0, 8.0, 8.0),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 18.0,
              fontFamily: "Roboto",
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }
}
