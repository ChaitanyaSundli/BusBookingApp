// lib/core/widgets/app_layout.dart
import 'package:flutter/material.dart';

class AppLayout extends StatelessWidget {
  final Widget child;
  final bool showAppBar;
  final String? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final bool extendBodyBehindAppBar;
  final PreferredSizeWidget? bottom;
  final Color? backgroundColor;

  const AppLayout({
    super.key,
    required this.child,
    this.showAppBar = false,
    this.title,
    this.actions,
    this.floatingActionButton,
    this.extendBodyBehindAppBar = false,
    this.bottom,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? Colors.grey.shade50,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      appBar: showAppBar
          ? AppBar(
        title: title != null ? Text(title!) : null,
        actions: actions,
        bottom: bottom,
      )
          : null,
      body: child,
      floatingActionButton: floatingActionButton,
    );
  }
}