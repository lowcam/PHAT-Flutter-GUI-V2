import 'package:flutter/material.dart';

/// A styled [Card] component with consistent rounded corners and padding.
/// Used for grouping sections in the main UI.
class PHATCard extends StatelessWidget {
  final Widget child;
  final double elevation;
  final Color? color;
  final EdgeInsetsGeometry? padding;

  const PHATCard({
    super.key,
    required this.child,
    this.elevation = 4,
    this.color,
    this.padding = const EdgeInsets.all(20.0),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: elevation,
      // Use the provided color, or fallback to the theme's card color (surface)
      color: color ?? theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: padding!,
        child: child,
      ),
    );
  }
}

/// A small, bold, uppercase label used to header different sections of the UI.
class SectionLabel extends StatelessWidget {
  final String label;
  final Color? color;

  const SectionLabel(this.label, {super.key, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      label,
      style: TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: 12,
        // Default to the theme's primary color if no color is provided
        color: (color ?? theme.colorScheme.primary).withOpacity(0.7),
        letterSpacing: 1.5,
      ),
    );
  }
}
