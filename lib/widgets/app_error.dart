import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppError extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const AppError({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF5F5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.danger, width: 1),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error_outline, color: AppTheme.danger, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFFC53030),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Réessayer'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
