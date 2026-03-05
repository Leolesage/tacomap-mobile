import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppLoader extends StatelessWidget {
  final String? message;

  const AppLoader({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 3),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
