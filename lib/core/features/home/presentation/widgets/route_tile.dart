import 'package:flutter/material.dart';

import '../../../../widgets/app_card.dart';

class RouteTile extends StatelessWidget {
  final String from;
  final String to;

  const RouteTile(this.from, this.to, {super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("$from → $to"),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    );
  }
}