import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:easy_localization/easy_localization.dart';

import 'main.dart'; // للوصول إلى themeNotifier

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

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
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

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // رأس القائمة
            Container(
              height: 120,
              decoration: const BoxDecoration(color: Colors.pink),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite, color: Colors.white, size: 32),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
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
                  ),
                ],
              ),
            ),

            // اللغة
            _sectionTitle('language'.tr()),
            ListTile(
              leading: const Text('🇸🇦', style: TextStyle(fontSize: 22)),
              title: const Text('العربية'),
              trailing: currentLocale.languageCode == 'ar'
                  ? const Icon(Icons.check, color: Colors.pink)
                  : null,
              onTap: () => changeLanguage(const Locale('ar')),
            ),
            ListTile(
              leading: const Text('🇬🇧', style: TextStyle(fontSize: 22)),
              title: const Text('English'),
              trailing: currentLocale.languageCode == 'en'
                  ? const Icon(Icons.check, color: Colors.pink)
                  : null,
              onTap: () => changeLanguage(const Locale('en')),
            ),
            ListTile(
              leading: const Text('🇫🇷', style: TextStyle(fontSize: 22)),
              title: const Text('Français'),
              trailing: currentLocale.languageCode == 'fr'
                  ? const Icon(Icons.check, color: Colors.pink)
                  : null,
              onTap: () => changeLanguage(const Locale('fr')),
            ),

            const Divider(),

            // الإشعارات
            SwitchListTile(
              secondary: const Icon(Icons.notifications, color: Colors.pink),
              title: Text('notifications'.tr()),
              value: notif,
              activeTrackColor: Colors.pink,
              onChanged: (v) {
                setState(() => notif = v);
                box.put('notifications', v);
              },
            ),

            const Divider(),

            // المظهر
            _sectionTitle('theme_mode'.tr()),
            RadioGroup<String>(
              groupValue: themeMode,
              onChanged: (v) => changeTheme(v!),
              child: Column(
                children: [
                  RadioListTile<String>(
                    value: 'light',
                    title: Text('light_mode'.tr()),
                    activeColor: Colors.pink,
                  ),
                  RadioListTile<String>(
                    value: 'dark',
                    title: Text('dark_mode'.tr()),
                    activeColor: Colors.pink,
                  ),
                  RadioListTile<String>(
                    value: 'system',
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
