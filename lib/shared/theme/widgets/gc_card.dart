import 'package:flutter/material.dart';

import '../app_radius.dart';
import '../app_spacing.dart';

class GcCard extends StatelessWidget {
  const GcCard({
    required this.child,
    super.key,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.margin = const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.sm,
    ),
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final card = Card(
      margin: margin,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.md),
      child: Padding(padding: padding, child: child),
    );

    if (onTap == null) {
      return card;
    }

    return InkWell(borderRadius: AppRadius.md, onTap: onTap, child: card);
  }
}
