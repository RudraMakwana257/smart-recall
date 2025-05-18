import 'package:flutter/material.dart';

enum ToastType {
  success,
  warning,
  error,
  info,
}

class ToastNotification extends StatelessWidget {
  final String message;
  final ToastType type;
  final VoidCallback onDismiss;

  const ToastNotification({
    super.key,
    required this.message,
    required this.type,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _getBorderColor(),
              width: 1,
            ),
          ),
          child: ListTile(
            leading: Icon(
              _getIcon(),
              color: _getIconColor(),
            ),
            title: Text(
              message,
              style: TextStyle(
                color: _getTextColor(),
                fontSize: 14,
              ),
            ),
            trailing: IconButton(
              icon: Icon(
                Icons.close,
                color: _getIconColor(),
                size: 20,
              ),
              onPressed: onDismiss,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (type) {
      case ToastType.success:
        return const Color(0xFFE7F8F0);
      case ToastType.warning:
        return const Color(0xFFFFF8E7);
      case ToastType.error:
        return const Color(0xFFFEEBEB);
      case ToastType.info:
        return const Color(0xFFE7F3FF);
    }
  }

  Color _getBorderColor() {
    switch (type) {
      case ToastType.success:
        return const Color(0xFF34C759);
      case ToastType.warning:
        return const Color(0xFFFF9500);
      case ToastType.error:
        return const Color(0xFFFF3B30);
      case ToastType.info:
        return const Color(0xFF007AFF);
    }
  }

  Color _getIconColor() {
    return _getBorderColor();
  }

  Color _getTextColor() {
    switch (type) {
      case ToastType.success:
        return const Color(0xFF1E824C);
      case ToastType.warning:
        return const Color(0xFFB76E00);
      case ToastType.error:
        return const Color(0xFFCF2A2A);
      case ToastType.info:
        return const Color(0xFF0055B3);
    }
  }

  IconData _getIcon() {
    switch (type) {
      case ToastType.success:
        return Icons.check_circle_outline;
      case ToastType.warning:
        return Icons.warning_amber_outlined;
      case ToastType.error:
        return Icons.error_outline;
      case ToastType.info:
        return Icons.info_outline;
    }
  }
}
