// profile_screen.dart — "Мой профиль" for Chukens VPN (UI-only, mock data)
//
// Style matches HomeScreen (dark blurred background + glass cards + white text).
//
// Expected assets:
//   assets/images/back.png
//
// Usage:
//   import 'profile_screen.dart';
//   Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
//
// Later: replace mock data with real backend state.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'login_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  final String tariff; // Trial / Standard / PRO

  const ProfileScreen({super.key, required this.tariff});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  @override
  void initState() {
    super.initState();
    devicesLimit = _devicesLimitByTariff;
  }

  // --------- MOCK DATA (replace later) ----------

  // Tariff-derived UI (mock rules, adjust later)
  Color get _tariffColor {
    switch (widget.tariff) {
      case 'Trial':
        return const Color(0xFF9DB4C0); // серо-голубой
      case 'Standard':
        return const Color(0xFF2E86FF); // синий
      case 'PRO':
        return const Color(0xFFFFC857); // золотой
      default:
        return const Color(0xFFFF8A00);
    }
  }

  int get _devicesLimitByTariff {
    switch (widget.tariff) {
      case 'Trial':
        return 1;
      case 'Standard':
        return 2;
      case 'PRO':
        return 5;
      default:
        return 1;
    }
  }

  bool accessActive = true;
  DateTime accessUntil = DateTime(2026, 6, 12);

  String deviceCode = 'XK-29A-PL90';
  int devicesUsed = 1;
  int devicesLimit = 1; // will be set from tariff in initState

  // ---------------------------------------------

  String get _untilText {
    final d = accessUntil;
    String two(int x) => x.toString().padLeft(2, '0');
    return '${two(d.day)}.${two(d.month)}.${d.year}';
  }

  void _toast(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _copyCode() async {
    await Clipboard.setData(ClipboardData(text: deviceCode));
    if (!mounted) return;
    _toast('Код устройства скопирован');
  }

  Future<void> _changeCodeStub() async {
    // UI-only stub: "change code" just generates a new mock code
    setState(() {
      deviceCode = 'CK-${DateTime.now().millisecondsSinceEpoch % 10000}-NEW';
    });
    _toast('Новый код создан (мок)');
  }

  Future<void> _openTelegramBot() async {
    final uri = Uri.parse('https://t.me/chukens_bot');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      _toast('Не удалось открыть Telegram');
    }
  }

  Future<void> _logout() async {
    // Later: clear persisted auth / tokens if появятся
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _BackBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                child: Row(
                  children: [
                    _GlassIconButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      tooltip: 'Назад',
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Мой профиль',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 18),
                  children: [

                    // Tariff / access (без заголовка "Доступ" и без панели устройств)
                    _GlassCard(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Тариф: ${widget.tariff == 'Trial' ? 'Пробный период (2 дня)' : 'Стандартный (1 неделя или месяц)'}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Активен до: $_untilText',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: _openTelegramBot,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: BorderSide(color: Colors.white.withOpacity(0.22)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text('Продлить', style: TextStyle(fontWeight: FontWeight.w900)),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Danger zone
                    _GlassCard(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                      child: Column(
                        children: [
                          _ActionRow(
                            icon: Icons.logout_rounded,
                            title: 'Выйти',
                            subtitle: 'Завершить сессию на этом устройстве',
                            onTap: _logout,
                          ),
                        ],
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

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white.withOpacity(0.92),
        fontWeight: FontWeight.w900,
        fontSize: 14,
        letterSpacing: 0.2,
      ),
    );
  }
}

class _BackBackground extends StatelessWidget {
  final Widget child;
  const _BackBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/back.png',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const _FallbackGradientBackground(),
          ),
        ),
        Positioned.fill(
          child: Container(color: Colors.black.withOpacity(0.45)),
        ),
        child,
      ],
    );
  }
}

class _FallbackGradientBackground extends StatelessWidget {
  const _FallbackGradientBackground();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0.0, -0.3),
          radius: 1.1,
          colors: [
            Color(0xFF122B55),
            Color(0xFF0B1220),
          ],
        ),
      ),
      child: SizedBox.expand(),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double radius;

  const _GlassCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 22,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: const Color(0xFF0B1220).withOpacity(0.86),
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: Colors.white.withOpacity(0.10)),
          boxShadow: [
            BoxShadow(
              blurRadius: 30,
              color: Colors.black.withOpacity(0.35),
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _GlassIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF0B1220).withOpacity(0.86),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.10)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.20),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  const _Dot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(blurRadius: 12, color: color.withOpacity(0.7))],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;

  const _Badge({
    required this.text,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w900,
          fontSize: 12,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(width: 10),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool danger;

  const _ActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor = danger ? Colors.redAccent : Colors.white;
    final iconColor = danger ? Colors.redAccent : Colors.white;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: titleColor, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.75)),
          ],
        ),
      ),
    );
  }
}
