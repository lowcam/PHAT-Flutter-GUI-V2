import 'package:flutter/material.dart';
import '../constants.dart';

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
    return Card(
      elevation: elevation,
      color: color ?? AppConstants.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: padding!,
        child: child,
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  final String label;
  final Color? color;

  const SectionLabel(this.label, {super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: 12,
        color: (color ?? AppConstants.primaryAccent).withOpacity(0.7),
        letterSpacing: 1.5,
      ),
    );
  }
}
