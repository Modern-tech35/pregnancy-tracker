import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:easy_localization/easy_localization.dart';

import 'main.dart'; // للوصول إلى themeNotifier و tabIndexNotifier

/// عنصر تنقل داخل القائمة الجانبية
class _NavItem {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.labelKey,
  });

  final IconData icon;
  final IconData activeIcon;
  final String labelKey;
}

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  late Box box;

  bool notif = true;
  String themeMode = 'system';
  Locale currentLocale = const Locale('ar');

  /// ترتيب العناصر مطابق لترتيب الصفحات في MainPage
  static const List<_NavItem> _navItems = [
    _NavItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      labelKey: 'profile',
    ),
    _NavItem(
      icon: Icons.article_outlined,
      activeIcon: Icons.article,
      labelKey: 'articles',
    ),
    _NavItem(
      icon: Icons.track_changes,
      activeIcon: Icons.track_changes,
      labelKey: 'tracker',
    ),
    _NavItem(
      icon: Icons.notifications_none,
      activeIcon: Icons.notifications,
      labelKey: 'reminders',
    ),
  ];

  @override
  void initState() {
    super.initState();
    box = Hive.box('settings');

    notif = box.get('notifications', defaultValue: true);

    // قراءة المظهر: light / dark / system (مع دعم القيم القديمة)
    final savedTheme = box.get('themeMode', defaultValue: '');
    themeMode = (savedTheme == 'light' || savedTheme == 'dark' ||
            savedTheme == 'system')
        ? savedTheme
        : (box.get('darkTheme', defaultValue: false) ? 'dark' : 'light');

    final savedLang = box.get('language', defaultValue: 'ar');
    currentLocale = savedLang == 'fr'
        ? const Locale('fr')
        : savedLang == 'en'
            ? const Locale('en')
            : const Locale('ar');
  }

  void changeLanguage(Locale locale) {
    setState(() => currentLocale = locale);
    context.setLocale(locale);
    box.put('language', locale.languageCode);
    Navigator.pop(context); // إغلاق القائمة بعد اختيار اللغة
  }

  void changeTheme(String mode) {
    setState(() => themeMode = mode);
    box.put('themeMode', mode);
    themeNotifier.value = mode == 'dark'
        ? ThemeMode.dark
        : mode == 'light'
            ? ThemeMode.light
            : ThemeMode.system;
  }

  void _goToPage(int index) {
    Navigator.pop(context); // إغلاق القائمة أولاً
    tabIndexNotifier.value = index;
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.pink,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF48FB1), Color(0xFFEC407A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white24,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.favorite, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 10),
          const Text(
            'Pregnancy Tracker',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildNavigation() {
    final current = tabIndexNotifier.value;

    return List.generate(_navItems.length, (index) {
      final item = _navItems[index];
      final selected = index == current;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
        child: ListTile(
          leading: Icon(
            selected ? item.activeIcon : item.icon,
            color: selected ? Colors.pink : null,
          ),
          title: Text(
            item.labelKey.tr(),
            style: TextStyle(
              color: selected ? Colors.pink : null,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          selected: selected,
          selectedTileColor: Colors.pink.withValues(alpha: 0.10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onTap: () => _goToPage(index),
        ),
      );
    });
  }

  Widget _languageTile(String flag, String label, Locale locale) {
    final selected = currentLocale.languageCode == locale.languageCode;

    return ListTile(
      dense: true,
      leading: Text(flag, style: const TextStyle(fontSize: 20)),
      title: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.pink : null,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing:
          selected ? const Icon(Icons.check, color: Colors.pink) : null,
      onTap: () => changeLanguage(locale),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 12),
          children: [
            _buildHeader(),
            const SizedBox(height: 6),

            // التنقل بين الصفحات
            ..._buildNavigation(),

            const Divider(height: 20),

            // الإعدادات
            _sectionTitle('settings'.tr()),
            SwitchListTile(
              secondary: const Icon(Icons.notifications_active,
                  color: Colors.pink),
              title: Text('notifications'.tr()),
              value: notif,
              activeTrackColor: Colors.pink,
              onChanged: (v) {
                setState(() => notif = v);
                box.put('notifications', v);
              },
            ),

            const Divider(height: 8, indent: 16, endIndent: 16),

            // اللغة
            _sectionTitle('language'.tr()),
            _languageTile('🇸🇦', 'العربية', const Locale('ar')),
            _languageTile('🇬🇧', 'English', const Locale('en')),
            _languageTile('🇫🇷', 'Français', const Locale('fr')),

            const Divider(height: 8, indent: 16, endIndent: 16),

            // المظهر
            _sectionTitle('theme_mode'.tr()),
            RadioGroup<String>(
              groupValue: themeMode,
              onChanged: (v) => changeTheme(v!),
              child: Column(
                children: [
                  RadioListTile<String>(
                    value: 'light',
                    dense: true,
                    title: Text('light_mode'.tr()),
                    activeColor: Colors.pink,
                  ),
                  RadioListTile<String>(
                    value: 'dark',
                    dense: true,
                    title: Text('dark_mode'.tr()),
                    activeColor: Colors.pink,
                  ),
                  RadioListTile<String>(
                    value: 'system',
                    dense: true,
                    title: Text('system_mode'.tr()),
                    activeColor: Colors.pink,
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
