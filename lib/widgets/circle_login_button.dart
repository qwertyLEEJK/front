import 'package:flutter/material.dart';
import 'package:midas_project/theme/app_colors.dart';

class CircleLoginButton extends StatelessWidget {
  final String asset;
  const CircleLoginButton({required this.asset, super.key});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 28,
  backgroundColor: AppColors.grayscale.s30,
      child: Image.asset(asset, width: 32, height: 32),
    );
  }
}
