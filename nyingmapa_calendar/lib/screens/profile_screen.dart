import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../services/local_data_service.dart';
import '../services/theme_provider.dart';
import '../services/translations.dart';
import 'add_events_screen.dart';
import 'add_practice_screen.dart';

// ═══════════════════════════════════════════════════════
// Practice state managed by Riverpod
// ═══════════════════════════════════════════════════════
class PracticeItem {
  final String id;
  final String keyEn;
  final String keyBo;
  bool completed;
  final Color color;
  int count;

  PracticeItem({
    required this.id,
    required this.keyEn,
    required this.keyBo,
    this.completed = false,
    required this.color,
    this.count = 0,
  });
}

class PracticeNotifier extends StateNotifier<List<PracticeItem>> {
  PracticeNotifier()
      : super([
          PracticeItem(id: 'ngondro', keyEn: 'Ngöndro Foundations', keyBo: 'སྔོན་འགྲོ།', color: AppColors.maroon),
          PracticeItem(id: 'morning_sadhana', keyEn: 'Morning Sadhana', keyBo: 'སྔ་དྲོའི་སྒྲུབ་ཐབས།', color: AppColors.gold),
          PracticeItem(id: 'guru_yoga', keyEn: 'Guru Yoga', keyBo: 'བླ་མའི་རྣལ་འབྱོར།', color: AppColors.lightTextSecondary),
          PracticeItem(id: 'vajrasattva', keyEn: 'Vajrasattva Mantra', keyBo: 'རྡོ་རྗེ་སེམས་དཔའི་སྔགས།', color: const Color(0xFF4CAF50)),
          PracticeItem(id: 'mandala', keyEn: 'Mandala Offering', keyBo: 'མཎྜལ་མཆོད་པ།', color: const Color(0xFF2196F3)),
        ]);

  void toggle(int index) {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index)
          PracticeItem(
            id: state[i].id,
            keyEn: state[i].keyEn,
            keyBo: state[i].keyBo,
            completed: !state[i].completed,
            color: state[i].color,
            count: state[i].count + (!state[i].completed ? 1 : 0),
          )
        else
          state[i],
    ];
    // Persist
    LocalDataService.trackPractice(
      state[index].keyEn,
      DateFormat('yyyy-MM-dd').format(DateTime.now()),
      state[index].completed,
    );
  }

  void addPractice(String en, String bo, Color color) {
    final id = 'practice_${DateTime.now().microsecondsSinceEpoch}';
    state = [...state, PracticeItem(id: id, keyEn: en, keyBo: bo, color: color)];
  }

  void removePractice(int index) {
    state = [...state]..removeAt(index);
  }

  int get completedCount => state.where((p) => p.completed).length;
  int get totalCount => state.length;
}

final practiceProvider = StateNotifierProvider<PracticeNotifier, List<PracticeItem>>((ref) {
  return PracticeNotifier();
});

// ═══════════════════════════════════════════════════════
// User Events
// ═══════════════════════════════════════════════════════
class UserEventsNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  UserEventsNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final events = await LocalDataService.getUserEvents();
    state = events;
  }

  Future<void> addEvent(Map<String, dynamic> event) async {
    await LocalDataService.createUserEvent(event);
    await _load();
  }

  Future<void> removeEvent(int index) async {
    final event = state[index];
    if (event['id'] != null) await LocalDataService.deleteUserEvent(event['id']);
    state = [...state]..removeAt(index);
  }

  Future<void> refresh() async => _load();
}

final userEventsProvider = StateNotifierProvider<UserEventsNotifier, List<Map<String, dynamic>>>((ref) {
  return UserEventsNotifier();
});

// ═══════════════════════════════════════════════════════
// Screen
// ═══════════════════════════════════════════════════════

class PracticeScreen extends ConsumerWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = ref.watch(languageProvider);
    final isBo = lang == 'bo';
    final practices = ref.watch(practiceProvider);
    final userEvents = ref.watch(userEventsProvider);
    final practiceNoti = ref.read(practiceProvider.notifier);

    final completedCount = practices.where((p) => p.completed).length;
    final streak = completedCount; // Simplified streak

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          children: [
            // Header
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(T.t('nyingma_calendar', isBo), style: TextStyle(
                      fontSize: 10, fontWeight: FontWeight.w700,
                      letterSpacing: 1.5, color: AppColors.maroon,
                    )),
                    FutureBuilder<Map<String, dynamic>?>(
                      future: LocalDataService.getProfile(),
                      builder: (context, snapshot) {
                        final profile = snapshot.data;
                        final name = profile?['full_name'] ?? T.t('my_profile', isBo);
                        return Text(
                          name,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : AppColors.navy,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.maroon.withOpacity(0.1),
                  ),
                  child: const Icon(Icons.person, size: 20, color: AppColors.maroon),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ─── Stats Card ──────────────
            _buildStatsCard(isDark, isBo, practices, userEvents.length),
            const SizedBox(height: 24),

            // ─── Daily Tracker ───────────
            _buildDailyTracker(isDark, isBo, practices, streak, ref),
            const SizedBox(height: 24),

            // ─── My Events ───────────────
            _buildMyEvents(isDark, isBo, userEvents, ref, context),
            const SizedBox(height: 16),

            Center(
              child: Text(T.t('swipe_manage', isBo),
                style: TextStyle(fontSize: 11, color: AppColors.lightTextSecondary, fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.maroon,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEventScreen()),
          );

          // reload events after returning
          if (result != null) {
            await ref.read(userEventsProvider.notifier).refresh();
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStatsCard(bool isDark, bool isBo, List<PracticeItem> practices, int eventCount) {
    final completedCount = practices.where((p) => p.completed).length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B0000), Color(0xFF5C0000)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            T.t('this_month', isBo),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statItem('$eventCount', 'TOTAL EVENTS'),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.2),
              ),
              _statItem('$completedCount', 'PRACTICES'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyTracker(bool isDark, bool isBo, List<PracticeItem> practices, int streak, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('⚡', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 4),
            Text(T.t('daily_practices', isBo), style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppColors.navy,
            )),
            const Spacer(),
            GestureDetector(
              onTap: () async {
                final result = await Navigator.push(
                  ref.context,
                  MaterialPageRoute(builder: (_) => const AddPracticeScreen()),
                );

                if (result != null && result is Map<String, dynamic>) {
                  ref.read(practiceProvider.notifier).addPractice(
                    result['title'] ?? 'New Practice',
                    result['title_bo'] ?? '',
                    AppColors.maroon,
                  );
                }
              },
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.gold.withOpacity(0.2),
                ),
                child: const Icon(Icons.add, size: 16, color: AppColors.gold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...List.generate(practices.length, (i) {
          final p = practices[i];
          return Dismissible(
            key: Key(p.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (_) => ref.read(practiceProvider.notifier).removePractice(i),
            child: GestureDetector(
              onTap: () => ref.read(practiceProvider.notifier).toggle(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(isBo ? p.keyBo : p.keyEn, style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : AppColors.navy,
                            decoration: p.completed ? TextDecoration.lineThrough : null,
                          )),
                          if (p.count > 0) Text(
                            isBo ? 'ཚར ${p.count}' : '${p.count} times completed',
                            style: TextStyle(fontSize: 10, color: AppColors.lightTextSecondary),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: p.completed ? AppColors.maroon : AppColors.lightTextSecondary,
                          width: 2,
                        ),
                        color: p.completed ? AppColors.maroon : Colors.transparent,
                      ),
                      child: p.completed
                          ? const Icon(Icons.check, size: 14, color: Colors.white)
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildMyEvents(bool isDark, bool isBo, List<Map<String, dynamic>> events, WidgetRef ref, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(T.t('my_events', isBo), style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppColors.navy,
            )),
            const Spacer(),
            Text(T.t('lunar_cycle', isBo), style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: AppColors.lightTextSecondary,
            )),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddEventScreen()),
                );

                if (result != null) {
                  await ref.read(userEventsProvider.notifier).refresh();
                }
              },
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.gold.withOpacity(0.2),
                ),
                child: const Icon(Icons.add, size: 16, color: AppColors.gold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (events.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.event_available, size: 32, color: AppColors.lightTextSecondary),
                  const SizedBox(height: 8),
                  Text(T.t('no_events_yet', isBo), style: TextStyle(fontSize: 13, color: AppColors.lightTextSecondary)),
                ],
              ),
            ),
          ),
        ...List.generate(events.length, (i) {
          final e = events[i];
          return _userEventTile(e, isDark, isBo, () {
            ref.read(userEventsProvider.notifier).removeEvent(i);
          });
        }),
      ],
    );
  }

  Widget _userEventTile(Map<String, dynamic> event, bool isDark, bool isBo, VoidCallback onDelete) {
    final title = event['title'] ?? '';
    final date = event['date'] ?? '';
    final time = event['time'] ?? '';
    final desc = event['description'] ?? '';

    return Dismissible(
      key: Key(event['id']?.toString() ?? title + date),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.maroon,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.maroon.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.maroon.withOpacity(0.2)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    date.length >= 10 ? date.substring(5, 7) : '',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppColors.lightTextSecondary,
                    ),
                  ),
                  Text(
                    date.length >= 10 ? date.substring(8, 10) : '--',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.navy,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.navy,
                  )),
                  const SizedBox(height: 2),
                  Text('$desc  •  $time', style: TextStyle(
                    fontSize: 11, color: AppColors.lightTextSecondary,
                  )),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 18, color: AppColors.lightTextSecondary),
          ],
        ),
      ),
    );
  }

}