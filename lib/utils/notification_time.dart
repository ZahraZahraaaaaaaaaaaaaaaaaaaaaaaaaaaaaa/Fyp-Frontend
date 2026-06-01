String formatNotificationTime(DateTime createdAt) {
  final now = DateTime.now();
  final local = createdAt.toLocal();
  final diff = now.difference(local);

  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';

  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(local.year, local.month, local.day);
  if (day == today) return 'Today';
  if (day == today.subtract(const Duration(days: 1))) return 'Yesterday';

  if (diff.inDays < 7) return '${diff.inDays} days ago';
  return '${local.month}/${local.day}/${local.year}';
}
