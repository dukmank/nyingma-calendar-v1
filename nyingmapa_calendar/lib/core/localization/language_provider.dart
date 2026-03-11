import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';


enum AppLanguage {
  en,
  bo,
}

/// Async bootstrap to prevent EN -> BO flicker on startup
final languageProvider =
    AsyncNotifierProvider<LanguageNotifier, AppLanguage>(
  LanguageNotifier.new,
);

class LanguageNotifier extends AsyncNotifier<AppLanguage> {
  static const _storageKey = 'app_language';

  @override
  Future<AppLanguage> build() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_storageKey);

    if (saved == 'bo') {
      return AppLanguage.bo;
    }

    return AppLanguage.en;
  }

  Future<void> toggle() async {
    final current = state.valueOrNull;
    if (current == null) return; // prevent toggle while loading

    final next = current == AppLanguage.en
        ? AppLanguage.bo
        : AppLanguage.en;

    state = const AsyncLoading();

    try {
      await _persist(next);
      state = AsyncData(next);
    } catch (_) {
      state = AsyncData(current); // rollback on failure
    }
  }

  Future<void> setLanguage(AppLanguage lang) async {
    final previous = state.valueOrNull;
    if (previous == null) return;

    state = const AsyncLoading();

    try {
      await _persist(lang);
      state = AsyncData(lang);
    } catch (_) {
      state = AsyncData(previous);
    }
  }

  Future<void> _persist(AppLanguage lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      lang == AppLanguage.en ? 'en' : 'bo',
    );
  }
}