import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:easy_localization/easy_localization.dart';

class TrackerPage extends StatelessWidget {
  const TrackerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final profileBox = Hive.box('profile');
    final String? lmpText = profileBox.get('lmp');
    DateTime? lmpDate = (lmpText != null) ? DateTime.tryParse(lmpText) : null;

    if (lmpDate == null) {
      return Scaffold(
        body: Center(
          child: Text(
            'enter_lmp'.tr(),
            style: const TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final int week = ((DateTime.now().difference(lmpDate).inDays) / 7).floor();
    final dueDate = lmpDate.add(const Duration(days: 280));
    final double fetusSize = (week * 1.3 > 50) ? 50 : week * 1.3;

    return Scaffold(
      appBar: AppBar(title: Text('tracker'.tr())),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInfoCard(
            title: "current_week".tr(),
            value: 'current_week_info'.tr(args: [week.toString()]),
            icon: Icons.calendar_month,
          ),
          _buildInfoCard(
            title: "due_date".tr(),
            value: 'due_date_info'.tr(args: [
              dueDate.year.toString(),
              dueDate.month.toString(),
              dueDate.day.toString()
            ]),
            icon: Icons.baby_changing_station,
          ),
          _buildInfoCard(
            title: "fetus_size".tr(),
            value: 'fetus_size_info'.tr(args: [fetusSize.toStringAsFixed(1)]),
            icon: Icons.child_care,
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 3,
            shadowColor: Colors.black26,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text('progress'.tr(),
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: week / 40,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.pink,
                    backgroundColor: Colors.pink.shade100,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 14),
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.pink.shade100,
              child: Icon(icon, size: 30, color: Colors.pink),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(value,
                      style: TextStyle(
                          fontSize: 15, color: Colors.grey.shade700)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
