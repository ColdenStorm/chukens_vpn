import 'package:flutter/material.dart';
import 'package:flutter_device_apps_platform_interface/flutter_device_apps_platform_interface.dart';

class AppSelectionScreen extends StatefulWidget {
  const AppSelectionScreen({super.key});

  @override
  State<AppSelectionScreen> createState() => _AppSelectionScreenState();
}

class _AppSelectionScreenState extends State<AppSelectionScreen> {
  List<_AppItem> _apps = [];
  bool _isLoading = true;

  List<_AppItem> get _favoriteApps =>
      _apps.where((a) => a.isFavorite).toList(growable: false);

  List<_AppItem> get _nonFavoriteApps =>
      _apps.where((a) => !a.isFavorite).toList(growable: false);

  @override
  void initState() {
    super.initState();
    _loadApps();
  }

  Future<void> _loadApps() async {
    try {
      final apps = await FlutterDeviceAppsPlatform.instance.listApps(
        includeSystem: true,
        onlyLaunchable: true,
        includeIcons: false,
      );

      final items = apps
          .map(
            (app) => _AppItem(
              name: app.appName ?? '',
              package: app.packageName ?? '',
              enabled: true, // по умолчанию все включены
              isFavorite: false,
            ),
          )
          .toList();

      // Отсортируем по имени для удобства
      items.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );

      setState(() {
        _apps = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Не удалось загрузить список приложений: $e'),
        ),
      );
    }
  }

  void _toggleApp(String package, bool value) {
    final index = _apps.indexWhere((a) => a.package == package);
    if (index == -1) return;

    setState(() {
      _apps[index] = _apps[index].copyWith(enabled: value);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value
              ? 'Трафик "${_apps[index].name}" будет идти через VPN.'
              : 'Трафик "${_apps[index].name}" не будет идти через VPN.',
        ),
      ),
    );
  }

  Future<void> _onAddFavoritePressed() async {
    final candidates = _nonFavoriteApps;
    if (candidates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Все приложения уже находятся в избранных.'),
        ),
      );
      return;
    }

    final selected = await showModalBottomSheet<_AppItem>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: Container(
            color: const Color(0xFF0B1220).withOpacity(0.95),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      'Добавить в избранные',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: candidates.length,
                      itemBuilder: (context, index) {
                        final app = candidates[index];
                        return ListTile(
                          title: Text(
                            app.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          subtitle: Text(
                            app.package,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          onTap: () => Navigator.of(context).pop(app),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (selected == null) return;

    setState(() {
      final index =
          _apps.indexWhere((a) => a.package == selected.package);
      if (index != -1) {
        final updated =
            _apps[index].copyWith(isFavorite: true);
        _apps.removeAt(index);
        // Добавляем в начало списка, чтобы избранные были сверху
        _apps.insert(0, updated);
      }
    });
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
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.45)),
          ),
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
                          'Выбор приложений для VPN',
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
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFFFF8A00),
                            ),
                          ),
                        )
                      : _apps.isEmpty
                          ? const Center(
                              child: Text(
                                'Приложения не найдены',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          : ListView(
                              padding:
                                  const EdgeInsets.fromLTRB(14, 10, 14, 18),
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      'Избранные приложения',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const Spacer(),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.add,
                                        color: Colors.white,
                                      ),
                                      tooltip: 'Добавить приложение в избранные',
                                      onPressed: _onAddFavoritePressed,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                if (_favoriteApps.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.only(bottom: 12),
                                    child: Text(
                                      'Пока нет избранных приложений. '
                                      'Нажмите на плюс, чтобы добавить.',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  )
                                else
                                  ..._favoriteApps.map(
                                    (app) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: _AppTile(
                                        app: app,
                                        onChanged: (v) =>
                                            _toggleApp(app.package, v),
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Все приложения',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ..._nonFavoriteApps.map(
                                  (app) => Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 10),
                                    child: _AppTile(
                                      app: app,
                                      onChanged: (v) =>
                                          _toggleApp(app.package, v),
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
}

class _AppItem {
  final String name;
  final String package;
  final bool enabled;
  final bool isFavorite;

  const _AppItem({
    required this.name,
    required this.package,
    required this.enabled,
    this.isFavorite = false,
  });

  _AppItem copyWith({
    String? name,
    String? package,
    bool? enabled,
    bool? isFavorite,
  }) {
    return _AppItem(
      name: name ?? this.name,
      package: package ?? this.package,
      enabled: enabled ?? this.enabled,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

class _AppTile extends StatelessWidget {
  final _AppItem app;
  final ValueChanged<bool> onChanged;

  const _AppTile({
    required this.app,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0B1220).withOpacity(0.86),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.10)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.22),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SwitchListTile(
          value: app.enabled,
          onChanged: onChanged,
          activeColor: const Color(0xFFFF8A00),
          secondary: app.isFavorite
              ? const Icon(
                  Icons.star_rounded,
                  color: Color(0xFFFFD54F),
                )
              : null,
          title: Text(
            app.name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          subtitle: Text(
            app.package,
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
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

