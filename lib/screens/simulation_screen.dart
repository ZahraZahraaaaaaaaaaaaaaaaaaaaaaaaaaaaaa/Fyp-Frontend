import 'package:flutter/material.dart';

/// Full-screen “attack consequence” UI shown after a wrong choice.
class SimulationScreen extends StatelessWidget {
  const SimulationScreen({
    super.key,
    required this.simulationType,
    required this.title,
    required this.lines,
    required this.onContinue,
  });

  final String simulationType;
  final String title;
  final List<String> lines;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final theme = _themeFor(simulationType);
    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _GridPainter(color: theme.accent.withValues(alpha: 0.08)),
              ),
            ),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(theme.icon, size: 72, color: theme.accent),
                      const SizedBox(height: 16),
                      Text(
                        title.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          color: theme.accent,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: theme.panel,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: theme.accent.withValues(alpha: 0.5), width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: theme.accent.withValues(alpha: 0.25),
                              blurRadius: 24,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.warning_amber_rounded, color: theme.accent),
                                const SizedBox(width: 8),
                                Text(
                                  'IMMEDIATE CONSEQUENCE',
                                  style: TextStyle(
                                    color: theme.accent,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            for (final line in lines)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('• ', style: TextStyle(color: theme.text, fontSize: 18)),
                                    Expanded(
                                      child: Text(
                                        line,
                                        style: TextStyle(color: theme.text, fontSize: 16, height: 1.35),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: theme.accent,
                            foregroundColor: theme.onAccent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: onContinue,
                          child: const Text('Continue to feedback'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'This is a training simulation. No real systems were harmed.',
                        style: TextStyle(color: theme.text.withValues(alpha: 0.65), fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _SimTheme _themeFor(String t) {
    switch (t) {
      case 'ransomware':
        return _SimTheme(
          background: const Color(0xFF0B0B0B),
          panel: const Color(0xFF1A0505),
          accent: const Color(0xFFFF1744),
          text: const Color(0xFFFFE0E0),
          onAccent: Colors.black,
          icon: Icons.lock_outline,
        );
      case 'system_lock':
        return _SimTheme(
          background: const Color(0xFF1A0000),
          panel: const Color(0xFF2D0A0A),
          accent: const Color(0xFFFF5252),
          text: Colors.white,
          onAccent: Colors.black,
          icon: Icons.shield_outlined,
        );
      case 'malware':
        return _SimTheme(
          background: const Color(0xFF120018),
          panel: const Color(0xFF1E0A24),
          accent: const Color(0xFFE040FB),
          text: const Color(0xFFF3E5F5),
          onAccent: Colors.black,
          icon: Icons.bug_report_outlined,
        );
      case 'vishing_breach':
        return _SimTheme(
          background: const Color(0xFF001018),
          panel: const Color(0xFF0A1E28),
          accent: const Color(0xFF00BCD4),
          text: Colors.white,
          onAccent: Colors.black,
          icon: Icons.phone_disabled_outlined,
        );
      case 'data_exfiltration':
      case 'impersonation_success':
        return _SimTheme(
          background: const Color(0xFF0D1117),
          panel: const Color(0xFF161B22),
          accent: const Color(0xFFFFAB00),
          text: Colors.white,
          onAccent: Colors.black,
          icon: Icons.outbound_outlined,
        );
      case 'phishing_alert':
      case 'unauthorized_login':
      default:
        return _SimTheme(
          background: const Color(0xFF1B0000),
          panel: const Color(0xFF2A0E0E),
          accent: const Color(0xFFFF5252),
          text: const Color(0xFFFFEBEE),
          onAccent: Colors.black,
          icon: Icons.gpp_maybe_outlined,
        );
    }
  }
}

class _SimTheme {
  const _SimTheme({
    required this.background,
    required this.panel,
    required this.accent,
    required this.text,
    required this.onAccent,
    required this.icon,
  });

  final Color background;
  final Color panel;
  final Color accent;
  final Color text;
  final Color onAccent;
  final IconData icon;
}

class _GridPainter extends CustomPainter {
  _GridPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1;
    const step = 32.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
