import 'package:flutter/material.dart';

class SignInButton extends StatelessWidget {
  final double? height, width;
  final String text;
  final Widget leading;
  final bool centerText;
  final ButtonStyle? style;
  final VoidCallback? onPressed;

  final double defaultHeight = 40;
  final double defaultWidth = double.infinity;

  SignInButton({
    this.onPressed,
    required this.text,
    required this.leading,
    this.centerText = false,
    this.style,
    this.height,
    this.width,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double iconWidth = 24;
    double iconPadding = 8;

    return Container(
      height: height ?? defaultHeight,
      width: width ?? defaultWidth,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Container(
          height: 24,
          width: 24,
          child: leading,
        ),
        label: Container(
          margin: EdgeInsets.only(right: iconWidth + iconPadding),
          padding: EdgeInsets.symmetric(horizontal: 16),
          alignment: centerText ? Alignment.center : Alignment.centerLeft,
          child: Text(
            text,
          ),
        ),
        style: style,
      ),
    );
  }
}
