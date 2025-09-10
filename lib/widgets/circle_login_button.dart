import 'package:flutter/material.dart';

class CircleLoginButton extends StatelessWidget {
  final String asset;
  const CircleLoginButton({required this.asset, super.key});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 28,
      backgroundColor: Colors.white,
      child: Image.asset(asset, width: 32, height: 32),
    );
  }
}
