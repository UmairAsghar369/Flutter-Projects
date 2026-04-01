// lib/core/utils/helpers.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class Helpers {
  Helpers._();

  /// Format a DateTime into "HH:mm" display string
  static String formatTime(DateTime dt) => DateFormat('HH:mm').format(dt);

  /// Copy [text] to clipboard and show a snackbar confirmation
  static void copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Copied to clipboard'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF7C5CFC),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Light haptic tap feedback
  static void hapticTap() =>
      HapticFeedback.lightImpact();
}
