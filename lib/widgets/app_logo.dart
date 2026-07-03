import 'package:flutter/material.dart';

/// A custom-drawn logo representing a padlock and a skeleton key.
/// Created using a [Stack] of [Container]s and [BoxDecoration]s for vector-like scalability.
class AppLogo extends StatelessWidget {
  /// The size (width and height) of the logo.
  final double size;
  /// Optional color override. Defaults to the theme's primary color.
  final Color? color;

  const AppLogo({
    super.key,
    this.size = 32,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final logoColor = color ?? theme.colorScheme.primary;
    final backgroundColor = theme.scaffoldBackgroundColor;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Background Circle - the main "coin" or button background
          Container(
            decoration: BoxDecoration(
              color: logoColor,
              shape: BoxShape.circle,
            ),
          ),
          // Padlock Shackle - the curved top part of the lock
          Positioned(
            top: size * 0.15,
            left: size * 0.3,
            right: size * 0.3,
            bottom: size * 0.45,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: backgroundColor, width: size * 0.08),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(size * 0.3),
                  topRight: Radius.circular(size * 0.3),
                ),
              ),
            ),
          ),
          // Padlock Body - the rectangular base of the lock
          Positioned(
            top: size * 0.4,
            left: size * 0.22,
            right: size * 0.22,
            bottom: size * 0.2,
            child: Container(
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(size * 0.1),
              ),
              child: Center(
                // Keyhole - represented by a small circular dot
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
          // Keyhole extension - the vertical part of the keyhole
          Positioned(
            top: size * 0.55,
            left: size * 0.46,
            width: size * 0.08,
            height: size * 0.1,
            child: Container(color: logoColor),
          ),
          // Skeleton Key handle - decorative circle for the key
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
          // Skeleton Key shaft - the bit/blade of the key
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
