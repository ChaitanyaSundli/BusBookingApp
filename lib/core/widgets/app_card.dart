import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double? elevation;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.elevation,
    this.onTap,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final ShapeBorder shape = borderRadius != null
        ? RoundedRectangleBorder(borderRadius: borderRadius!)
        : theme.cardTheme.shape ?? const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20)));

    final card = Card(
      margin: margin ?? EdgeInsets.zero,
      elevation: elevation ?? theme.cardTheme.elevation ?? 0,
      color: color ?? theme.cardTheme.color,
      shape: shape,
      shadowColor: theme.cardTheme.shadowColor,
      clipBehavior: theme.cardTheme.clipBehavior ?? Clip.none,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );

    if (onTap != null) {
      final rippleBorderRadius = borderRadius ?? BorderRadius.circular(20);
      return InkWell(
        onTap: onTap,
        borderRadius: rippleBorderRadius,
        child: card,
      );
    }
    return card;
  }
}