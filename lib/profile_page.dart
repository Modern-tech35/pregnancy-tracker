import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:easy_localization/easy_localization.dart';

import 'app_drawer.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _lmpController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;

  @override
  void initState() {
    super.initState();
    final profileBox = Hive.box('profile');

    _lmpController = TextEditingController(text: profileBox.get('lmp'));
    _weightController = TextEditingController(text: profileBox.get('weight'));
    _heightController = TextEditingController(text: profileBox.get('height'));
  }

  void _saveProfile() {
    final profileBox = Hive.box('profile');

    profileBox.put('lmp', _lmpController.text);
    profileBox.put('weight', _weightController.text);
    profileBox.put('height', _heightController.text);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('profile_saved'.tr())),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: ValueKey(context.locale.languageCode), // لتحديث الصفحة عند تغيير اللغة
      drawer: const AppDrawer(),
      appBar: AppBar(title: Text('profile'.tr())),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInputCard(
            title: "last_menstrual_period".tr(),
            hint: "date_format_hint".tr(),
            controller: _lmpController,
            icon: Icons.calendar_month,
            keyboard: TextInputType.datetime,
          ),
          _buildInputCard(
            title: "weight".tr(),
            hint: "example_weight".tr(),
            controller: _weightController,
            icon: Icons.monitor_weight,
            keyboard: TextInputType.number,
          ),
          _buildInputCard(
            title: "height".tr(),
            hint: "example_height".tr(),
            controller: _heightController,
            icon: Icons.height,
            keyboard: TextInputType.number,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _saveProfile,
              child: Text('save_data'.tr(),
                  style: const TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputCard({
    required String title,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    required TextInputType keyboard,
  }) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: Colors.pink.shade100,
              child: Icon(icon, size: 28, color: Colors.pink),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller,
                    keyboardType: keyboard,
                    decoration: InputDecoration(
                      hintText: hint.tr(), // الترجمة ديناميكيًا
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 12),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
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
