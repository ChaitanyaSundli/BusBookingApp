import 'package:flutter/material.dart';

class AppLayoutFrame extends StatelessWidget {
  final Widget child;

  const AppLayoutFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= 600) {
          return child;
        }

        final width = constraints.maxWidth;
        final maxContentWidth = width >= 1200 ? 560.0 : 520.0;
        final horizontalPadding = width >= 900 ? 28.0 : 16.0;

        return Scaffold(
          backgroundColor: const Color(0xFFF1F5F9),
          body: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: ColoredBox(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
