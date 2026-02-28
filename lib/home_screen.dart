// HOME SCREEN — RELEASE-LIKE POPUPS WITH YOUR IMAGES
//
// Adds two popup types (bottom-sheet style):
// 1) Subscription expired  -> assets/images/no_money.png
// 2) Internet/Server issue -> assets/images/no_internet.png
//
// Keeps:
// - Center power button with press animation
// - Status pill (dark, with colored dot)
// - Bottom NL panel
// - Right drawer menu (white icons/text)
//
// How to trigger now (UI-only):
// - In the right menu you will see "Тестовые окна" -> open each popup.
// Later you'll call `showNoInternetPopup()` / `showNoMoneyPopup()` from real backend/VPN events.
//
// Assets expected:
//   assets/images/back.png
//   assets/images/on.png
//   assets/images/off.png
//   assets/images/nl.png
//   assets/images/no_money.png
//   assets/images/no_internet.png
//
// pubspec.yaml:
// flutter:
//   assets:
//     - assets/images/

import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'about_screen.dart';
import 'app_selection_screen.dart';
import 'app_settings.dart';

class HomeScreen extends StatefulWidget {
  final String tariff; // Trial / Standard / PRO

  const HomeScreen({super.key, required this.tariff});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

enum VpnStatus { disconnected, connecting, connected }

enum ConnectIssueType { noInternetOrServer, subscriptionExpired }

class _HomeScreenState extends State<HomeScreen> {
  VpnStatus _status = VpnStatus.disconnected;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    if (AppSettings.autoConnectOnAppStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (_status == VpnStatus.disconnected) {
          _toggle();
        }
      });
    }
  }

  // Call these later from backend/VPN events:
  void showNoInternetPopup() => _showIssue(
    type: ConnectIssueType.noInternetOrServer,
    title: 'Нет подключения',
    message: 'Проверьте интернет (Wi‑Fi / мобильная сеть) и попробуйте снова.',
    assetPath: 'assets/images/no_internet.png',
    primaryText: 'Понятно',
    secondaryText: 'Повторить',
    onPrimary: () {},
    onSecondary: () {
      if (_status == VpnStatus.disconnected) _toggle();
    },
  );

  void showNoMoneyPopup() => _showIssue(
    type: ConnectIssueType.subscriptionExpired,
    title: 'Доступ закончился',
    message: 'Срок подписки истёк. Продлите доступ или войдите с новым кодом.',
    assetPath: 'assets/images/no_money.png',
    primaryText: 'Поддержка',
    secondaryText: 'Ок',
    onPrimary: () => _toast('Поддержка — позже подключим'),
    onSecondary: () {},
  );

  Future<void> _toggle() async {
    if (_status == VpnStatus.connecting) return;

    if (_status == VpnStatus.connected) {
      setState(() => _status = VpnStatus.disconnected);
      return;
    }

    // UI simulation: connecting -> connected
    setState(() => _status = VpnStatus.connecting);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _status = VpnStatus.connected);
  }

  void _toast(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  void _onConnectionDrop() {
    setState(() => _status = VpnStatus.disconnected);
    if (AppSettings.reconnectOnDrop) {
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        if (_status != VpnStatus.disconnected) return;
        _toggle();
      });
    }
  }

  void _showIssue({
    required ConnectIssueType type,
    required String title,
    required String message,
    required String assetPath,
    required String primaryText,
    required String secondaryText,
    required VoidCallback onPrimary,
    required VoidCallback onSecondary,
  }) {
    // Any connectivity issue -> disconnected (typical behavior)
    if (type == ConnectIssueType.noInternetOrServer) {
      _onConnectionDrop();
    }

    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _IssueSheet(
        title: title,
        message: message,
        assetPath: assetPath,
        primaryText: primaryText,
        secondaryText: secondaryText,
        onPrimary: () {
          Navigator.of(context).pop();
          onPrimary();
        },
        onSecondary: () {
          Navigator.of(context).pop();
          onSecondary();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusText = switch (_status) {
      VpnStatus.disconnected => 'Отключено',
      VpnStatus.connecting => 'Подключение…',
      VpnStatus.connected => 'Подключено',
    };

    final dotColor = switch (_status) {
      VpnStatus.disconnected => Colors.redAccent,
      VpnStatus.connecting => Colors.orangeAccent,
      VpnStatus.connected => Colors.greenAccent,
    };

    final powerAsset =
    _status == VpnStatus.connected ? 'assets/images/on.png' : 'assets/images/off.png';

    return Scaffold(
      endDrawer: _RightMenuDrawer(
        tariff: widget.tariff,
        onNoInternet: showNoInternetPopup,
        onNoMoney: showNoMoneyPopup,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/back.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.45)),
          ),
          SafeArea(
            child: Stack(
              children: [
                Positioned(
                  top: 10,
                  right: 12,
                  child: Builder(
                    builder: (ctx) => IconButton(
                      icon: const Icon(Icons.menu_rounded, color: Colors.white),
                      iconSize: 28,
                      onPressed: () => Scaffold.of(ctx).openEndDrawer(),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 16,
                  right: 16,
                  child: Center(
                    child: _TariffBadge(tariff: widget.tariff),
                  ),
                ),

                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTapDown: (_) => setState(() => _isPressed = true),
                        onTapCancel: () => setState(() => _isPressed = false),
                        onTapUp: (_) {
                          setState(() => _isPressed = false);
                          _toggle();
                        },
                        child: AnimatedScale(
                          scale: _isPressed ? 0.92 : 1.0,
                          duration: const Duration(milliseconds: 120),
                          curve: Curves.easeOut,
                          child: Image.asset(
                            powerAsset,
                            width: 180,
                            height: 180,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      _StatusPill(
                        label: 'Статус: $statusText',
                        dotColor: dotColor,
                      ),
                      const SizedBox(height: 16),
                      _StatsRow(status: _status),
                    ],
                  ),
                ),
                const Positioned(
                  left: 16,
                  right: 16,
                  bottom: 20,
                  child: _CountryPanel(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color dotColor;

  const _StatusPill({required this.label, required this.dotColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.65),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: Colors.white.withOpacity(0.30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(blurRadius: 12, color: dotColor.withOpacity(0.7))],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}



class _StatsRow extends StatelessWidget {
  final VpnStatus status;
  const _StatsRow({required this.status});

  String get _pingText {
    switch (status) {
      case VpnStatus.connected:
        return '23 ms';
      case VpnStatus.connecting:
        return '…';
      case VpnStatus.disconnected:
      default:
        return '—';
    }
  }

  String get _timeText {
    switch (status) {
      case VpnStatus.connected:
        return '00:12:34';
      case VpnStatus.connecting:
        return '00:00:…';
      case VpnStatus.disconnected:
      default:
        return '00:00:00';
    }
  }

  String get _speedText {
    switch (status) {
      case VpnStatus.connected:
        return '120 Mbps';
      case VpnStatus.connecting:
        return '…';
      case VpnStatus.disconnected:
      default:
        return '0 Mbps';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          Expanded(child: _StatCard(title: 'Пинг', value: _pingText)),
          const SizedBox(width: 10),
          Expanded(child: _StatCard(title: 'Время', value: _timeText)),
          const SizedBox(width: 10),
          Expanded(child: _StatCard(title: 'Скорость', value: _speedText)),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;

  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF0B1220).withOpacity(0.82),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.10)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.22),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withOpacity(0.88),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _IssueSheet extends StatelessWidget {
  final String title;
  final String message;
  final String assetPath;
  final String primaryText;
  final String secondaryText;
  final VoidCallback onPrimary;
  final VoidCallback onSecondary;

  const _IssueSheet({
    required this.title,
    required this.message,
    required this.assetPath,
    required this.primaryText,
    required this.secondaryText,
    required this.onPrimary,
    required this.onSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0B1220).withOpacity(0.92),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.10)),
            boxShadow: [
              BoxShadow(
                blurRadius: 30,
                color: Colors.black.withOpacity(0.55),
                offset: const Offset(0, 12),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(
                  assetPath,
                  height: 150,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Container(
                    height: 150,
                    alignment: Alignment.center,
                    color: Colors.white.withOpacity(0.06),
                    child: const Icon(Icons.warning_rounded, size: 54, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.86),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onSecondary,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.white.withOpacity(0.18)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(secondaryText, style: const TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: onPrimary,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFFF8A00),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(primaryText, style: const TextStyle(fontWeight: FontWeight.w900)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountryPanel extends StatelessWidget {
  const _CountryPanel();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0B1220).withOpacity(0.86),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withOpacity(0.10)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.22),
              blurRadius: 22,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/images/nl.png',
                width: 54,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 54,
                  height: 40,
                  color: Colors.white.withOpacity(0.06),
                  alignment: Alignment.center,
                  child: const Text('🇳🇱', style: TextStyle(fontSize: 22)),
                ),
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Нидерланды',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Основной сервер',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
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


class _TariffBadge extends StatelessWidget {
  final String tariff; // Trial / Standard / PRO
  const _TariffBadge({required this.tariff});

  Color get _color {
    switch (tariff) {
      case 'Trial':
        return const Color(0xFF9DB4C0); // серо-голубой
      case 'Standard':
        return const Color(0xFF2E86FF); // синий
      case 'PRO':
        return const Color(0xFFFFC857); // золотой
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _color;
    final isPro = tariff == 'PRO';

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF0B1220).withOpacity(0.86),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: c.withOpacity(0.75), width: 1.2),
          boxShadow: [
            BoxShadow(
              blurRadius: isPro ? 26 : 18,
              color: c.withOpacity(isPro ? 0.35 : 0.22),
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isPro) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: c.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'VIP',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              'Chukens • $tariff',
              style: TextStyle(
                color: c,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RightMenuDrawer extends StatelessWidget {
  final String tariff;
  final VoidCallback onNoInternet;
  final VoidCallback onNoMoney;

  const _RightMenuDrawer({
    required this.tariff,
    required this.onNoInternet,
    required this.onNoMoney,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF0B1220),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(top: 8),
          children: [
            ListTile(
              leading: const Icon(Icons.person, color: Colors.white),
              title: const Text('Мой профиль', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.of(context).pop(); // закрыть меню
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProfileScreen(tariff: tariff)),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.white),
              title: const Text('Настройки', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.apps_rounded, color: Colors.white),
              title: const Text('Выбор приложений для VPN', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AppSelectionScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info, color: Colors.white),
              title: const Text('О приложении', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutScreen()),
                );
              },
            ),
            const Divider(color: Colors.white24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Тестовые окна (потом уберём)',
                style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w700),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.wifi_off_rounded, color: Colors.white),
              title: const Text('Нет интернета / сервер', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.of(context).pop();
                onNoInternet();
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock_rounded, color: Colors.white),
              title: const Text('Доступ закончился', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.of(context).pop();
                onNoMoney();
              },
            ),
          ],
        ),
      ),
    );
  }
}
