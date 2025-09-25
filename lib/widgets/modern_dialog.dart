import 'package:flutter/material.dart';
import '../utils/animations.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class ModernDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget> actions;
  final bool showCloseButton;
  final double? width;
  final double? height;

  const ModernDialog({
    super.key,
    required this.title,
    required this.content,
    required this.actions,
    this.showCloseButton = true,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ModernAnimations.fadeScaleIn(
        duration: ModernAnimations.normal,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: ModernShadows.floating,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    if (showCloseButton)
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.close,
                          color: AppColors.textSecondary,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.gray100,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Content
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: content,
                ),
              ),
              // Actions
              if (actions.isNotEmpty)
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: actions
                        .map(
                          (action) => Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: action,
                          ),
                        )
                        .toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class ModernBottomSheet extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget> actions;
  final bool showCloseButton;

  const ModernBottomSheet({
    super.key,
    required this.title,
    required this.content,
    this.actions = const [],
    this.showCloseButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: ModernShadows.floating,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.gray300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (showCloseButton)
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.textSecondary,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.gray100,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Content
          Flexible(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: content,
            ),
          ),
          // Actions
          if (actions.isNotEmpty)
            Container(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: actions
                    .map(
                      (action) => Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: action,
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}

// Utility functions for showing modern dialogs
class ModernDialogUtils {
  static Future<T?> showModernDialog<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    required List<Widget> actions,
    bool showCloseButton = true,
    double? width,
    double? height,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: true,
      builder: (context) => ModernDialog(
        title: title,
        content: content,
        actions: actions,
        showCloseButton: showCloseButton,
        width: width,
        height: height,
      ),
    );
  }

  static Future<T?> showModernBottomSheet<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    List<Widget> actions = const [],
    bool showCloseButton = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ModernAnimations.slideIn(
        begin: const Offset(0, 1),
        end: Offset.zero,
        child: ModernBottomSheet(
          title: title,
          content: content,
          actions: actions,
          showCloseButton: showCloseButton,
        ),
      ),
    );
  }

  static Future<bool?> showModernConfirmationDialog({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Подтвердить',
    String cancelText = 'Отмена',
    Color? confirmColor,
  }) {
    return showModernDialog<bool>(
      context: context,
      title: title,
      content: Text(message, style: Theme.of(context).textTheme.bodyMedium),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelText),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmColor ?? AppColors.primary,
          ),
          child: Text(confirmText),
        ),
      ],
    );
  }
}
