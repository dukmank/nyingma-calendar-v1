import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import 'profile_screen.dart';
import '../services/local_data_service.dart';

class AddEventScreen extends ConsumerStatefulWidget {
  const AddEventScreen({super.key});

  @override
  ConsumerState<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends ConsumerState<AddEventScreen> {
  final titleCtrl = TextEditingController();
  final contentCtrl = TextEditingController();

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  String calendarType = "solar";

  String repeatValue = "Never";
  String reminderValue = "On time";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Create special event",
          style: TextStyle(
            color: AppColors.navy,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.navy),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const SizedBox(height: 10),

                    _input("Title", "Enter event name", titleCtrl),
                    const SizedBox(height: 16),

                    _input("Content", "Enter event content", contentCtrl, maxLines: 4),

                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: _tab("Solar calendar", calendarType == "solar", () {
                            setState(() => calendarType = "solar");
                          }),
                        ),
                        Expanded(
                          child: _tab("Lunar calendar", calendarType == "lunar", () {
                            setState(() => calendarType = "lunar");
                          }),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    _sectionLabel("Time"),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final t = await showTimePicker(
                                context: context,
                                initialTime: selectedTime,
                              );
                              if (t != null) setState(() => selectedTime = t);
                            },
                            child: _selector(selectedTime.format(context)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final d = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime(2024),
                                lastDate: DateTime(2035),
                              );
                              if (d != null) setState(() => selectedDate = d);
                            },
                            child: _selector(
                              "${selectedDate.day}/${selectedDate.month}/${selectedDate.year.toString().substring(2)}",
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    _rowSelector("Repeat", repeatValue),
                    const SizedBox(height: 14),

                    _rowSelector("Reminder", reminderValue),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFE6C089),
                        Color(0xFFD8A95A),
                      ],
                    ),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () async {
                      final title = titleCtrl.text.trim();
                      if (title.isEmpty) return;

                      final event = {
                        "title": title,
                        "description": contentCtrl.text.trim(),
                        "date": "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}",
                        "time": selectedTime.format(context),
                        "calendar_type": calendarType,
                        "repeat": repeatValue,
                        "reminder": reminderValue
                      };

                      await LocalDataService.createUserEvent(event);

                      if (mounted) Navigator.pop(context, event);
                    },
                    child: const Text(
                      "Add",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.navy,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            )

          ],
        ),
      ),
    );
  }
  Widget _rowSelector(String label, String value) {
  return GestureDetector(
    onTap: () async {
      final result = await showModalBottomSheet<String>(
        context: context,
        builder: (_) {
          final options = label == "Repeat"
              ? ["Never", "Daily", "Weekly", "Monthly"]
              : ["On time", "5 min before", "15 min before", "1 hour before"];

          return ListView(
            shrinkWrap: true,
            children: options
                .map((e) => ListTile(
                      title: Text(e),
                      onTap: () => Navigator.pop(context, e),
                    ))
                .toList(),
          );
        },
      );

      if (result != null) {
        setState(() {
          if (label == "Repeat") {
            repeatValue = result;
          } else {
            reminderValue = result;
          }
        });
      }
    },
    child: Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade700,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.navy,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 6),
        const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
      ],
    ),
  );
}

  Widget _tab(String text, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active ? AppColors.maroon : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: active ? AppColors.maroon : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _selector(String text) {
  return Container(
    height: 40,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.grey.shade300),
      color: Colors.white,
    ),
    child: Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        color: AppColors.navy,
        fontSize: 14,
      ),
    ),
  );
}

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Colors.grey.shade600,
        letterSpacing: 0.4,
      ),
    );
  }

  Widget _input(String label, String hint, TextEditingController ctrl,
      {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
          ),
        )
      ],
    );
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    contentCtrl.dispose();
    super.dispose();
  }
}