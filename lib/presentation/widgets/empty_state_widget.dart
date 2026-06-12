import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'common/primary_button.dart';

class EmptyStateWidget extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final String? buttonLabel;
  final VoidCallback? onButton;

  const EmptyStateWidget({
    super.key,
    required this.emoji,
    required this.title,
    required this.subtitle,
    this.buttonLabel,
    this.onButton,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 72)),
            const SizedBox(height: 20),
            Text(title, style: AppTextStyles.headlineMedium, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(subtitle, style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
            if (buttonLabel != null) ...[
              const SizedBox(height: 24),
              PrimaryButton(label: buttonLabel!, onPressed: onButton, isFullWidth: false),
            ],
          ],
        ),
      ),
    );
  }
}
