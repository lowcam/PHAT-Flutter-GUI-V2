import 'package:flutter/material.dart';
import '../constants.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final Color? color;

  const AppLogo({
    super.key,
    this.size = 32,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final logoColor = color ?? AppConstants.primaryAccent;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Background Circle
          Container(
            decoration: BoxDecoration(
              color: logoColor,
              shape: BoxShape.circle,
            ),
          ),
          // Padlock Shackle
          Positioned(
            top: size * 0.15,
            left: size * 0.3,
            right: size * 0.3,
            bottom: size * 0.45,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppConstants.scaffoldBgColor, width: size * 0.08),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(size * 0.3),
                  topRight: Radius.circular(size * 0.3),
                ),
              ),
            ),
          ),
          // Padlock Body
          Positioned(
            top: size * 0.4,
            left: size * 0.22,
            right: size * 0.22,
            bottom: size * 0.2,
            child: Container(
              decoration: BoxDecoration(
                color: AppConstants.scaffoldBgColor,
                borderRadius: BorderRadius.circular(size * 0.1),
              ),
              child: Center(
                // Keyhole
                child: Container(
                  width: size * 0.12,
                  height: size * 0.12,
                  decoration: BoxDecoration(
                    color: logoColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
          // Keyhole extension
          Positioned(
            top: size * 0.55,
            left: size * 0.46,
            width: size * 0.08,
            height: size * 0.1,
            child: Container(color: logoColor),
          ),
          // Skeleton Key handle
          Positioned(
            right: size * 0.15,
            top: size * 0.55,
            child: Container(
              width: size * 0.15,
              height: size * 0.15,
              decoration: BoxDecoration(
                border: Border.all(color: logoColor, width: size * 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Skeleton Key shaft
          Positioned(
            right: size * 0.2,
            top: size * 0.68,
            child: Container(
              width: size * 0.05,
              height: size * 0.12,
              color: logoColor,
            ),
          ),
        ],
      ),
    );
  }
}
