import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ContextMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const ContextMenuItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Icon(icon, color: Colors.white),
      title: Text(label),
      onTap: () {
        GoRouter.of(context).pop();
        onPressed();
      },
    );
  }
}