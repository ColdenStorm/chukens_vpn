// settings_screen.dart — Chukens VPN (Clean version)
// Only:
// - Подключение
// - Безопасность
// No protocol/DNS text, no extra info.
//
// Expected asset:
//   assets/images/back.png

import 'package:flutter/material.dart';
import 'app_settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool autoConnect = AppSettings.autoConnectOnAppStart;
  bool reconnectOnDrop = AppSettings.reconnectOnDrop;
  bool killSwitchSystemWide = AppSettings.killSwitchSystemWide;
  bool killSwitchAppLevel = AppSettings.killSwitchAppLevel;

  void _toast(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/back.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const _FallbackGradientBackground(),
            ),
          ),
          Positioned.fill(child: Container(color: Colors.black.withOpacity(0.45))),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                  child: Row(
                    children: [
                      _GlassIconButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        tooltip: 'Назад',
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Настройки',
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
                      _sectionTitle('Подключение'),
                      const SizedBox(height: 8),
                      _switchTile(
                        title: 'Автоподключение',
                        subtitle: 'Подключаться при запуске приложения',
                        value: autoConnect,
                        onChanged: (v) => setState(() {
                          autoConnect = v;
                          AppSettings.setAutoConnectOnAppStart(v);
                        }),
                      ),
                      _switchTile(
                        title: 'Переподключение при обрыве VPN соединения',
                        subtitle: 'Автоматически восстанавливать соединение',
                        value: reconnectOnDrop,
                        onChanged: (v) => setState(() {
                          reconnectOnDrop = v;
                          AppSettings.setReconnectOnDrop(v);
                        }),
                      ),

                      const SizedBox(height: 18),
                      _sectionTitle('Безопасность'),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0B1220).withOpacity(0.86),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Colors.white.withOpacity(0.10)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 18,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Kill Switch',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Автоматически отключает интернет, если соединение с VPN внезапно обрывается.',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 10),
                              _killSwitchRow(
                                title: 'System-wide',
                                subtitle: 'Блокировка весь интернет на устройстве',
                                value: killSwitchSystemWide,
                                onChanged: (v) => setState(() {
                                  killSwitchSystemWide = v;
                                  AppSettings.setKillSwitchSystemWide(v);
                                }),
                              ),
                              const SizedBox(height: 8),
                              _killSwitchRow(
                                title: 'App-level',
                                subtitle: 'Блокировать интернет только выбранных приложений',
                                value: killSwitchAppLevel,
                                onChanged: (v) => setState(() {
                                  killSwitchAppLevel = v;
                                  AppSettings.setKillSwitchAppLevel(v);
                                }),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white.withOpacity(0.92),
        fontWeight: FontWeight.w900,
        fontSize: 14,
      ),
    );
  }

  Widget _switchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF0B1220).withOpacity(0.86),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.10)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SwitchListTile(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFFFF8A00),
            title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
            subtitle: Text(subtitle, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }

  Widget _killSwitchRow({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFFFF8A00),
        ),
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
