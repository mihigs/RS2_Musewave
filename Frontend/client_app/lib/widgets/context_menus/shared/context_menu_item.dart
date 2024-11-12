import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ContextMenuItem extends StatelessWidget {
  final IconData icon;
  Color iconColor;
  final String label;
  final VoidCallback onPressed;

  ContextMenuItem({
    Key? key,
    required this.icon,
    this.iconColor = Colors.white,
    required this.label,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Icon(icon, color: iconColor),
      title: Text(label),
      onTap: () {
        GoRouter.of(context).pop();
        onPressed();
      },
    );
  }
}