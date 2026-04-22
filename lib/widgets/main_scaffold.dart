import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../theme/design_tokens.dart';

/// App shell inspired by `figma_ui/src/components/EmployeeNavbar.tsx` + drawer for small widths.
class MainScaffold extends StatelessWidget {
  const MainScaffold({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.sidebarCtaLabel = 'Deploy Mission',
    this.sidebarCtaRoute = '/scenarios',
  });

  final String title;
  final Widget child;
  final List<Widget>? actions;
  final String sidebarCtaLabel;
  final String sidebarCtaRoute;

  bool _active(BuildContext context, String route) {
    final loc = GoRouterState.of(context).matchedLocation;
    if (route == '/home') return loc == '/home';
    if (route == '/scenarios') return loc.startsWith('/scenarios');
    if (route == '/admin') return loc.startsWith('/admin');
    return loc == route;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final u = auth.user;
    final desktop = MediaQuery.sizeOf(context).width >= 1180;
    final wide = MediaQuery.sizeOf(context).width >= 960;
    final initial = (u?.fullName ?? 'U').isNotEmpty ? u!.fullName[0].toUpperCase() : 'U';

    return Scaffold(
      appBar: desktop
          ? null
          : AppBar(
              titleSpacing: wide ? 20 : 0,
              title: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                      gradient: const LinearGradient(colors: [AppColors.primary, AppColors.accentTeal]),
                    ),
                    child: const Icon(Icons.shield_outlined, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'SecureLearn',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          title,
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                if (actions != null) ...actions!,
                IconButton(
                  tooltip: 'Profile',
                  onPressed: () => context.go('/profile'),
                  icon: CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.surface2,
                    child: Text(initial, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                  ),
                ),
              ],
            ),
      drawer: wide
          ? null
          : Drawer(
              backgroundColor: AppColors.surface,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      border: Border(bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.9))),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                            gradient: const LinearGradient(colors: [AppColors.primary, AppColors.accentTeal]),
                          ),
                          child: const Icon(Icons.shield_outlined, color: Colors.white),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'SecureLearn',
                          style: TextStyle(color: AppColors.text, fontSize: 18, fontWeight: FontWeight.w800),
                        ),
                        const Text(
                          'Security awareness training',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  _drawerTile(context, '/home', 'Dashboard', Icons.dashboard_outlined),
                  _drawerTile(context, '/scenarios', 'Scenarios', Icons.play_circle_outline),
                  _drawerTile(context, '/analytics', 'Analytics', Icons.insights_outlined),
                  _drawerTile(context, '/badges', 'Achievements', Icons.workspace_premium_outlined),
                  _drawerTile(context, '/profile', 'Profile', Icons.person_outline),
                  if (auth.isAdmin) _drawerTile(context, '/admin', 'Admin', Icons.admin_panel_settings_outlined),
                ],
              ),
            ),
      body: desktop
          ? Row(
              children: [
                _DesktopSidebar(
                  title: title,
                  ctaLabel: sidebarCtaLabel,
                  ctaRoute: sidebarCtaRoute,
                ),
                Expanded(
                  child: Column(
                    children: [
                      _DesktopTopBar(
                        title: title,
                        actions: actions,
                      ),
                      Expanded(child: child),
                    ],
                  ),
                ),
              ],
            )
          : child,
    );
  }

  Widget _drawerTile(BuildContext context, String route, String label, IconData icon) {
    final on = _active(context, route);
    return ListTile(
      leading: Icon(icon, color: on ? AppColors.primary : AppColors.textMuted),
      title: Text(label, style: TextStyle(fontWeight: on ? FontWeight.w800 : FontWeight.w500)),
      selected: on,
      selectedTileColor: AppColors.primary.withValues(alpha: 0.08),
      onTap: () {
        Navigator.pop(context);
        context.go(route);
      },
    );
  }
}

class _DesktopTopBar extends StatelessWidget {
  const _DesktopTopBar({
    required this.title,
    this.actions,
  });

  final String title;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final u = auth.user;
    final initial = (u?.fullName ?? 'U').isNotEmpty ? u!.fullName[0].toUpperCase() : 'U';
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF060F22),
        border: Border(bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.8))),
      ),
      child: Row(
        children: [
          Text(title, style: const TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w700)),
          const Spacer(),
          Container(
            width: 220,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surface2,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.border),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: const Row(
              children: [
                Icon(Icons.search, size: 16, color: AppColors.textMuted),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Search Intel...',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none, size: 18)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.settings_outlined, size: 18)),
          const SizedBox(width: 4),
          CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.surface2,
            child: Text(initial, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
          ),
          if (actions != null) ...actions!,
        ],
      ),
    );
  }
}

class _DesktopSidebar extends StatelessWidget {
  const _DesktopSidebar({
    required this.title,
    required this.ctaLabel,
    required this.ctaRoute,
  });

  final String title;
  final String ctaLabel;
  final String ctaRoute;

  bool _active(BuildContext context, String route) {
    final loc = GoRouterState.of(context).matchedLocation;
    if (route == '/home') return loc == '/home';
    if (route == '/scenarios') return loc.startsWith('/scenarios');
    if (route == '/admin') return loc.startsWith('/admin');
    return loc == route;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final u = auth.user;
    final initial = (u?.fullName ?? 'U').isNotEmpty ? u!.fullName[0].toUpperCase() : 'U';
    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: const Color(0xFF060D1D),
        border: Border(right: BorderSide(color: AppColors.border.withValues(alpha: 0.8))),
      ),
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('SecureLearn', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22)),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surface2,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.18),
                  child: Text(initial, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        u?.fullName ?? 'Operator',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                      ),
                      Text(
                        'LEVEL ${u?.level ?? 1} OPERATOR',
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _sidebarLink(context, '/home', 'Dashboard', Icons.dashboard_outlined),
          _sidebarLink(context, '/scenarios', 'Scenarios', Icons.play_circle_outline),
          _sidebarLink(context, '/analytics', 'Analytics', Icons.insights_outlined),
          _sidebarLink(context, '/badges', 'Achievements', Icons.workspace_premium_outlined),
          _sidebarLink(context, '/profile', 'Profile', Icons.person_outline),
          if (auth.isAdmin) _sidebarLink(context, '/admin', 'Admin', Icons.admin_panel_settings_outlined),
          const Spacer(),
          FilledButton(
            onPressed: () => context.go(ctaRoute),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 40),
              backgroundColor: const Color(0xFFB3C7FF),
              foregroundColor: const Color(0xFF122040),
            ),
            child: Text(ctaLabel),
          ),
          const SizedBox(height: 8),
          TextButton.icon(onPressed: () {}, icon: const Icon(Icons.help_outline, size: 16), label: const Text('Support')),
          TextButton.icon(
            onPressed: () async {
              await auth.logout();
              if (context.mounted) context.go('/login');
            },
            icon: const Icon(Icons.logout_outlined, size: 16),
            label: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  Widget _sidebarLink(BuildContext context, String route, String label, IconData icon) {
    final on = _active(context, route);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => context.go(route),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: on ? AppColors.primary.withValues(alpha: 0.16) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: on ? Border.all(color: AppColors.primary.withValues(alpha: 0.45)) : null,
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: on ? AppColors.primary : AppColors.textMuted),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: on ? AppColors.text : AppColors.textMuted,
                  fontWeight: on ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
