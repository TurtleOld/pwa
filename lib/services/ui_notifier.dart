import 'package:flutter/material.dart';

/// UI-facing notifier to show friendly messages without technical details.
class UiNotifier {
  const UiNotifier();

  void showSuccess(BuildContext context, String message) {
    _showSnack(
      context,
      message,
      const Color(0xFF16A34A),
    );
  }

  void showWarning(BuildContext context, String message) {
    _showSnack(
      context,
      message,
      const Color(0xFFF59E0B),
    );
  }

  void showError(BuildContext context, String message) {
    _showSnack(
      context,
      message,
      const Color(0xFFDC2626),
    );
  }

  void _showSnack(BuildContext context, String message, Color color) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

