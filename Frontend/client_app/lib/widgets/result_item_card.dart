import 'package:flutter/material.dart';

class ResultItemCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  const ResultItemCard({
    Key? key,
    required this.title,
    this.subtitle,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 1, // Makes the widget square
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                if (subtitle != null)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
