import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'neo_button.dart';

class NeoError extends StatelessWidget {
  final Object error;
  final VoidCallback? onRetry;

  const NeoError({
    super.key,
    required this.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppTheme.error, size: 48),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong.',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              NeoButton(
                text: 'Retry',
                onPressed: onRetry!,
                isPrimary: false, // Secondary style for error retry
              ),
            ],
          ],
        ),
      ),
    );
  }
}
