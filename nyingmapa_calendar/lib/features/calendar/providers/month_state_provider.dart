import 'package:flutter_riverpod/flutter_riverpod.dart';

class MonthState {
  final int year;
  final int month;

  const MonthState({
    required this.year,
    required this.month,
  });

  MonthState copyWith({
    int? year,
    int? month,
  }) {
    return MonthState(
      year: year ?? this.year,
      month: month ?? this.month,
    );
  }
}

class MonthStateNotifier extends StateNotifier<MonthState> {
  MonthStateNotifier()
      : super(
          MonthState(
            year: DateTime.now().year,
            month: DateTime.now().month,
          ),
        );

  MonthState _normalize(int year, int month) {
    int y = year;
    int m = month;

    while (m > 12) {
      m -= 12;
      y += 1;
    }

    while (m < 1) {
      m += 12;
      y -= 1;
    }

    return MonthState(year: y, month: m);
  }

  void nextMonth() {
    state = _normalize(state.year, state.month + 1);
  }

  void prevMonth() {
    state = _normalize(state.year, state.month - 1);
  }

  void goToToday() {
    final now = DateTime.now();
    state = MonthState(year: now.year, month: now.month);
  }

  void jumpTo(int year, int month) {
    state = _normalize(year, month);
  }
}

final monthStateProvider =
    StateNotifierProvider<MonthStateNotifier, MonthState>(
  (ref) => MonthStateNotifier(),
);