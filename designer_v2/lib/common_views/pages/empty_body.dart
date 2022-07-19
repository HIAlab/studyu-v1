import 'package:flutter/material.dart';

class EmptyBody extends StatelessWidget {
  const EmptyBody({
    this.icon,
    required this.title,
    required this.description,
    this.button,
    Key? key
  }) : super(key: key);
  
  final IconData? icon;
  final String title;
  final String description;
  final Widget? button;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          (icon != null)
              ? Icon(icon, size: 96.0, color: theme.colorScheme.onSurface.withOpacity(0.6))
              : const SizedBox.shrink(),
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: SelectableText(title, style: theme.textTheme.titleLarge!.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
                fontWeight: FontWeight.bold,
              ))
          ),
          SelectableText(description, style: theme.textTheme.titleMedium!.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.8),
          )),
          (button != null) ?
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: button,
            ) : const SizedBox.shrink(),
        ],
      )
    );
  }
}
