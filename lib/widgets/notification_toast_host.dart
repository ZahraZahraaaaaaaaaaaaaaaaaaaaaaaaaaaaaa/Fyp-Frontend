import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/notification_provider.dart';
import 'notification_toast.dart';

/// Global overlay host for session-only toast notifications.
class NotificationToastHost extends StatelessWidget {
  const NotificationToastHost({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned(
          top: 0,
          right: 0,
          child: SafeArea(
            child: Consumer<NotificationProvider>(
              builder: (context, provider, _) {
                if (provider.activeToasts.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8, right: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (final entry in provider.activeToasts)
                        NotificationToast(
                          key: ValueKey(entry.toastKey),
                          notification: entry.notification,
                          onClose: () => provider.dismissToast(entry.toastKey),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
