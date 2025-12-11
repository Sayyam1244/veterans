import 'package:flutter/material.dart';

class LoadingService {
  static OverlayEntry? _overlayEntry;
  static bool _isShowing = false;

  // Show loading overlay
  static void show(BuildContext context, {String? message}) {
    if (_isShowing) return;

    _isShowing = true;

    _overlayEntry = OverlayEntry(
      builder:
          (context) => Material(
            color: Colors.black54,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE91E63)),
                    ),
                    if (message != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        message,
                        style: const TextStyle(fontSize: 14, color: Color(0xFF2D2D2D)),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  // Hide loading overlay
  static void hide() {
    if (!_isShowing) return;

    _overlayEntry?.remove();
    _overlayEntry = null;
    _isShowing = false;
  }
}
