import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/notification_provider.dart';
import 'notification_toast.dart';

/// In-app overlay for session-only toast notifications (inside MaterialApp.builder).
class NotificationToastHost extends StatelessWidget {
  const NotificationToastHost({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Consumer<NotificationProvider>(
          builder: (context, provider, _) {
            return Positioned(
              top: 0,
              right: 0,
              child: SafeArea(
                child: IgnorePointer(
                  ignoring: provider.activeToasts.isEmpty,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8, right: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final entry in provider.activeToasts)
                          NotificationToast(
                            key: ValueKey(entry.toastKey),
                            notification: entry.notification,
                            onClose: () => provider.dismissToast(entry.toastKey),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
