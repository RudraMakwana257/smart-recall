import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/toast_notification.dart';

class ToastService {
  static final ToastService _instance = ToastService._internal();
  factory ToastService() => _instance;
  ToastService._internal();

  static OverlayEntry? _currentToast;
  static Timer? _toastTimer;

  void showToast(
    BuildContext context, {
    required String message,
    required ToastType type,
    Duration duration = const Duration(seconds: 3),
  }) {
    _currentToast?.remove();
    _toastTimer?.cancel();

    final overlay = Overlay.of(context);
    _currentToast = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 16,
        width: MediaQuery.of(context).size.width,
        child: ToastNotification(
          message: message,
          type: type,
          onDismiss: () {
            _currentToast?.remove();
            _currentToast = null;
            _toastTimer?.cancel();
          },
        ),
      ),
    );

    overlay.insert(_currentToast!);

    _toastTimer = Timer(duration, () {
      _currentToast?.remove();
      _currentToast = null;
    });
  }

  void showSuccessToast(BuildContext context, String message) {
    showToast(context, message: message, type: ToastType.success);
  }

  void showWarningToast(BuildContext context, String message) {
    showToast(context, message: message, type: ToastType.warning);
  }

  void showErrorToast(BuildContext context, String message) {
    showToast(context, message: message, type: ToastType.error);
  }

  void showInfoToast(BuildContext context, String message) {
    showToast(context, message: message, type: ToastType.info);
  }

  void dismissToast() {
    _currentToast?.remove();
    _currentToast = null;
    _toastTimer?.cancel();
  }
}
