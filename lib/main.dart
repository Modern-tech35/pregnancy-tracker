import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hive_flutter/hive_flutter.dart';


import 'profile_page.dart';
import 'articles_page.dart';
import 'tracker_page.dart';
import 'notes_page.dart';
import 'reminders_page.dart';
import 'settings_page.dart';


late ValueNotifier<ThemeMode> themeNotifier;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة EasyLocalization
  await EasyLocalization.ensureInitialized();

  // تهيئة Hive
  await Hive.initFlutter();

  // فتح صناديق Hive
  await Hive.openBox('settings');
  await Hive.openBox('profile');
  await Hive.openBox('notes');
  await Hive.openBox('reminders');

  final settingsBox = Hive.box('settings');

  // قراءة الوضع الليلي
  bool dark = settingsBox.get('darkTheme', defaultValue: false);
  themeNotifier = ValueNotifier(dark ? ThemeMode.dark : ThemeMode.light);

  // قراءة اللغة المخزنة
  String savedLang = settingsBox.get('language', defaultValue: 'ar');
  Locale initialLocale = savedLang == 'fr'
      ? const Locale('fr')
      : savedLang == 'en'
          ? const Locale('en')
          : const Locale('ar');

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
        Locale('fr'),
      ],
      path: 'assets/translations', // مجلد ملفات الترجمة
      fallbackLocale: const Locale('ar'),
      startLocale: initialLocale,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'Pregnancy Tracker',
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light().copyWith(
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.pink,
              centerTitle: true,
              elevation: 0,
              titleTextStyle: TextStyle(
                  color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              iconTheme: IconThemeData(color: Colors.white),
            ),
          ),
          darkTheme: ThemeData.dark().copyWith(
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.pink,
              centerTitle: true,
              elevation: 0,
              titleTextStyle: TextStyle(
                  color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              iconTheme: IconThemeData(color: Colors.white),
            ),
          ),
          themeMode: currentMode,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          home: const MainPage(),
        );
      },
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const ProfilePage(),
    const ArticlesPage(),
    const TrackerPage(),
    const NotesPage(),
    const RemindersPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: 'profile'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.article),
            label: 'articles'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.track_changes),
            label: 'tracker'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.note),
            label: 'notes'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.notifications),
            label: 'reminders'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: 'settings'.tr(),
          ),
        ],
      ),
    );
  }
}
