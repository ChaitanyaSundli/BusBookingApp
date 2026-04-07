import 'package:flutter/material.dart';

class PassengerTile extends StatelessWidget {
  final String name;
  final String seat;
  final int age;

  const PassengerTile({
    super.key,
    required this.name,
    required this.seat,
    required this.age,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const CircleAvatar(
        child: Icon(Icons.person),
      ),
      title: Text(name),
      subtitle: Text("Seat: $seat • Age: $age"),
    );
  }
}