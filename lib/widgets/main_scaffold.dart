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
  });

  final String title;
  final Widget child;
  final List<Widget>? actions;

  bool _active(BuildContext context, String route) {
    final loc = GoRouterState.of(context).matchedLocation;
    if (route == '/home') return loc == '/home';
    if (route == '/scenarios') return loc.startsWith('/scenarios');
    if (route == '/admin') return loc.startsWith('/admin');
    return loc == route;
  }

  Widget _navLink(
    BuildContext context, {
    required String route,
    required String label,
    required IconData icon,
  }) {
    final on = _active(context, route);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: TextButton(
        onPressed: () => context.go(route),
        style: TextButton.styleFrom(
          foregroundColor: on ? AppColors.primary : AppColors.textMuted,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          minimumSize: const Size(0, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: on ? AppColors.primary : AppColors.textMuted),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: on ? FontWeight.w800 : FontWeight.w600,
                decoration: on ? TextDecoration.underline : TextDecoration.none,
                decorationColor: AppColors.primary,
                decorationThickness: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final u = auth.user;
    final wide = MediaQuery.sizeOf(context).width >= 960;
    final initial = (u?.fullName ?? 'U').isNotEmpty ? u!.fullName[0].toUpperCase() : 'U';

    return Scaffold(
      appBar: AppBar(
        titleSpacing: wide ? 20 : 0,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.accentTeal],
                ),
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
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (wide) ...[
              const SizedBox(width: 16),
              _navLink(context, route: '/home', label: 'Dashboard', icon: Icons.dashboard_outlined),
              _navLink(context, route: '/scenarios', label: 'Scenarios', icon: Icons.play_circle_outline),
              _navLink(context, route: '/analytics', label: 'Analytics', icon: Icons.insights_outlined),
              _navLink(context, route: '/badges', label: 'Achievements', icon: Icons.workspace_premium_outlined),
              if (auth.isAdmin)
                _navLink(context, route: '/admin', label: 'Admin', icon: Icons.admin_panel_settings_outlined),
            ],
          ],
        ),
        actions: [
          if (actions != null) ...actions!,
          if (wide) ...[
            IconButton(
              tooltip: 'Profile',
              onPressed: () => context.go('/profile'),
              icon: CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.surface2,
                child: Text(initial, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
              ),
            ),
            IconButton(
              tooltip: 'Logout',
              onPressed: () async {
                await auth.logout();
                if (context.mounted) context.go('/login');
              },
              icon: const Icon(Icons.logout_outlined),
            ),
          ] else ...[
            IconButton(
              tooltip: 'Profile',
              onPressed: () => context.go('/profile'),
              icon: CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.surface2,
                child: Text(initial, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
              ),
            ),
            IconButton(
              tooltip: 'Logout',
              onPressed: () async {
                await auth.logout();
                if (context.mounted) context.go('/login');
              },
              icon: const Icon(Icons.logout_outlined),
            ),
          ],
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
      body: child,
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
