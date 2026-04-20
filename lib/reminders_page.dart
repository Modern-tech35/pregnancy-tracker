import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:easy_localization/easy_localization.dart';

class RemindersPage extends StatefulWidget {
  const RemindersPage({super.key});

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  late Box box;
  bool ready = false;
  final ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    openBox();
  }

  Future<void> openBox() async {
    box = await Hive.openBox('reminders_text');
    setState(() => ready = true);
  }

  void add() {
    final t = ctrl.text.trim();
    if (t.isNotEmpty) {
      box.add(t);
      ctrl.clear();
    }
  }

  void deleteReminder(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("delete".tr()),
        content: Text("delete_confirm".tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("cancel".tr()),
          ),
          TextButton(
            onPressed: () {
              box.deleteAt(index);
              Navigator.pop(context);
            },
            child: const Text(
              "delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!ready) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('reminders'.tr()),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(width * 0.04),
        child: Column(
          children: [
            TextField(
              controller: ctrl,
              decoration: InputDecoration(
                hintText: 'write_reminder'.tr(),
                filled: true,
                fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                contentPadding: EdgeInsets.symmetric(
                  horizontal: width * 0.04,
                  vertical: height * 0.015,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: height * 0.02),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: add,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: height * 0.015),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('save'.tr()),
              ),
            ),
            SizedBox(height: height * 0.025),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: box.listenable(),
                builder: (_, Box b, __) {
                  final reminders = b.values.toList();

                  if (reminders.isEmpty) {
                    return Center(
                      child: Text(
                        'no_reminders'.tr(),
                        style: const TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: reminders.length,
                    itemBuilder: (_, i) => Container(
                      margin: EdgeInsets.only(bottom: height * 0.015),
                      padding: EdgeInsets.all(width * 0.04),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              reminders[i].toString(),
                              style: TextStyle(fontSize: width * 0.04),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => deleteReminder(i),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
