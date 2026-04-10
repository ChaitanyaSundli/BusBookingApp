import 'package:flutter/material.dart';

class AppLayout extends StatelessWidget {
  final Widget child;
  final bool showAppBar;
  final String? title;
  final Widget? leading;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final bool extendBodyBehindAppBar;
  final PreferredSizeWidget? bottom;

  const AppLayout({
    super.key,
    required this.child,
    this.showAppBar = false,
    this.title,
    this.leading,
    this.actions,
    this.floatingActionButton,
    this.extendBodyBehindAppBar = false,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      appBar: showAppBar
          ? AppBar(
        title: title != null ? Text(title!) : null,
        leading: leading,
        actions: actions,
        bottom: bottom,
      )
          : null,
      body: child,
      floatingActionButton: floatingActionButton,
    );
  }
}