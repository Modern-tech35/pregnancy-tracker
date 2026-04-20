import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'main.dart'; // للوصول إلى themeNotifier

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late Box box;
  bool ready = false;

  bool notif = true;
  bool dark = false;
  Locale currentLocale = const Locale('ar');

  @override
  void initState() {
    super.initState();
    open();
  }

  Future<void> open() async {
    box = await Hive.openBox('settings');

    notif = box.get('notifications', defaultValue: true);
    dark = box.get('darkTheme', defaultValue: false);
    currentLocale = box.get('language', defaultValue: 'ar') == 'fr'
        ? const Locale('fr')
        : box.get('language', defaultValue: 'ar') == 'en'
            ? const Locale('en')
            : const Locale('ar');

    setState(() => ready = true);
  }

  void changeLanguage(Locale locale) {
    setState(() => currentLocale = locale);
    context.setLocale(locale);
    box.put('language', locale.languageCode);
  }

  void changeTheme(bool value) {
    setState(() => dark = value);
    box.put('darkTheme', value);
    themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
  }

  @override
  Widget build(BuildContext context) {
    if (!ready) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('settings'.tr()),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // بطاقة اللغة
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.language),
                  const SizedBox(width: 10),
                  Text('language'.tr(), style: const TextStyle(fontSize: 16)),
                  const Spacer(),
                  DropdownButton<Locale>(
                    value: currentLocale,
                    onChanged: (Locale? newLocale) {
                      if (newLocale != null) changeLanguage(newLocale);
                    },
                    items: const [
                      DropdownMenuItem(
                          value: Locale('ar'), child: Text('العربية')),
                      DropdownMenuItem(
                          value: Locale('en'), child: Text('English')),
                      DropdownMenuItem(
                          value: Locale('fr'), child: Text('Français')),
                    ],
                  )
                ],
              ),
            ),

            // بطاقة الإشعارات
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.notifications),
                  const SizedBox(width: 10),
                  Text('notifications'.tr(),
                      style: const TextStyle(fontSize: 16)),
                  const Spacer(),
                  Switch(
                    value: notif,
                    onChanged: (v) {
                      setState(() => notif = v);
                      box.put('notifications', v);
                    },
                  ),
                ],
              ),
            ),

            // بطاقة الوضع الليلي
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.dark_mode),
                  const SizedBox(width: 10),
                  Text('dark_mode'.tr(),
                      style: const TextStyle(fontSize: 16)),
                  const Spacer(),
                  Switch(
                    value: dark,
                    onChanged: (v) => changeTheme(v),
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
