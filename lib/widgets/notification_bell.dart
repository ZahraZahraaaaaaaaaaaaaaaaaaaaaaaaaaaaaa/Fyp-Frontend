import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/platform_notices.dart';
import '../models/notification_model.dart';
import '../providers/notification_provider.dart';
import '../routes/app_router.dart';
import '../theme/app_colors.dart';
import '../utils/notification_style.dart';
import '../utils/notification_time.dart';

class NotificationBell extends StatefulWidget {
  const NotificationBell({super.key, this.compact = false});

  final bool compact;

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<NotificationProvider>().load();
    });
  }

  Future<void> _openPanel() async {
    final provider = context.read<NotificationProvider>();
    try {
      await provider.load(force: true);
    } catch (_) {
      // Still open panel with cached items if fetch fails.
    }
    if (!mounted) return;

    final dialogContext = rootNavigatorKey.currentContext ?? context;
    final topInset = MediaQuery.of(dialogContext).padding.top;
    final isDesktop = MediaQuery.sizeOf(dialogContext).width >= 1180;
    final topOffset = topInset + (isDesktop ? 56 : kToolbarHeight) + 8;

    await showGeneralDialog<void>(
      context: dialogContext,
      useRootNavigator: true,
      barrierDismissible: true,
      barrierLabel: 'Notifications',
      barrierColor: Colors.black.withValues(alpha: 0.45),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (overlayContext, animation, secondaryAnimation) {
        return SafeArea(
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: EdgeInsets.only(top: topOffset, right: 12, left: 12),
              child: _NotificationPanel(
                onClose: () => Navigator.of(overlayContext).pop(),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, -0.04), end: Offset.zero).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final unread = context.watch<NotificationProvider>().unreadCount;

    return IconButton(
      tooltip: 'Notifications',
      onPressed: _openPanel,
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            Icons.notifications_none,
            size: widget.compact ? 20 : 22,
            color: AppColors.textMuted,
          ),
          if (unread > 0)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: unread > 9 ? 3 : 4, vertical: 1),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                decoration: BoxDecoration(
                  color: AppColors.danger,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.topBar, width: 1.5),
                ),
                child: Text(
                  unread > 9 ? '9+' : '$unread',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NotificationPanel extends StatelessWidget {
  const _NotificationPanel({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final width = MediaQuery.sizeOf(context).width >= 400 ? 380.0 : double.infinity;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: width,
        constraints: const BoxConstraints(maxHeight: 520),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 8, 10),
              child: Row(
                children: [
                  const Text(
                    'Notifications',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  const Spacer(),
                  if (provider.hasUnread)
                    TextButton(
                      onPressed: provider.loading ? null : () => provider.markAllRead(),
                      child: const Text('Mark all as read'),
                    ),
                  IconButton(
                    onPressed: onClose,
                    icon: const Icon(Icons.close, size: 18),
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: AppColors.border),
            Flexible(
              child: provider.loading && provider.items.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
                      children: [
                        const _SectionHeader(title: 'Your Notifications'),
                        const SizedBox(height: 8),
                        if (provider.items.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              'Activity notifications will appear here as you train.',
                              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                            ),
                          )
                        else
                          ...provider.items.map(
                            (n) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _NotificationCard(
                                notification: n,
                                icon: NotificationStyle.iconForType(n.type),
                                accent: NotificationStyle.accentForType(n.type),
                                onTap: () => provider.markRead(n.id),
                              ),
                            ),
                          ),
                        const SizedBox(height: 12),
                        const _SectionHeader(title: 'Security Tips & Challenges'),
                        const SizedBox(height: 8),
                        ...PlatformNotices.tipsAndChallenges.map(
                          (notice) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _PlatformNoticeCard(notice: notice),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.4,
        color: AppColors.textMuted,
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  final NotificationModel notification;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: notification.isRead
          ? AppColors.surface2.withValues(alpha: 0.35)
          : AppColors.primary.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: accent.withValues(alpha: 0.35)),
                ),
                child: Icon(icon, size: 18, color: accent),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 7,
                            height: 7,
                            margin: const EdgeInsets.only(left: 6),
                            decoration: const BoxDecoration(
                              color: AppColors.danger,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: TextStyle(color: AppColors.textMuted, fontSize: 12, height: 1.35),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      formatNotificationTime(notification.createdAt),
                      style: TextStyle(
                        color: AppColors.textMuted.withValues(alpha: 0.85),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlatformNoticeCard extends StatelessWidget {
  const _PlatformNoticeCard({required this.notice});

  final PlatformNotice notice;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface2.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.85)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: notice.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: notice.accent.withValues(alpha: 0.3)),
            ),
            child: Icon(notice.icon, size: 18, color: notice.accent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notice.title,
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.border.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Platform',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 9, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notice.message,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
