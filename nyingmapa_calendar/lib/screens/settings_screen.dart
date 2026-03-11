import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../services/theme_provider.dart';
import '../services/translations.dart';
import '../services/local_data_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  Map<String, dynamic>? _profile;
  bool _notificationsEnabled = true;
  bool _lineageAlerts = true;
  bool _practiceReminders = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await LocalDataService.getProfile();
    if (mounted) setState(() => _profile = profile);
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final isBo = lang == 'bo';
    final isDark = ref.watch(themeNotifierProvider) == ThemeMode.dark;
    final highContrast = ref.watch(highContrastProvider);
    final tr = T.of(isBo);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          children: [
            // Header
            Row(
              children: [
                Text(
                  tr['settings']!,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.navy,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => _showProfileEditor(context, isDark, isBo),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.maroon.withOpacity(0.1),
                    ),
                    child: const Icon(Icons.person, size: 20, color: AppColors.maroon),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ─── Community ───────────────────
            _sectionLabel(tr['nyingmapa_community']!),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _socialBtn(Icons.facebook, 'Facebook', const Color(0xFF1877F2)),
                _socialBtn(Icons.camera_alt, 'Instagram', const Color(0xFFE4405F)),
                _socialBtn(Icons.play_circle_fill, 'Youtube', const Color(0xFFFF0000)),
              ],
            ),
            const SizedBox(height: 24),

            // ─── Account ─────────────────────
            _sectionLabel(tr['account']!),
            const SizedBox(height: 8),
            _settingTile(
              Icons.person_outline,
              tr['update_profile']!,
              null,
              () => _showProfileEditor(context, isDark, isBo),
              isDark: isDark,
            ),
            const SizedBox(height: 24),

            // ─── App Settings ────────────────
            _sectionLabel(tr['app_settings']!),
            const SizedBox(height: 8),
            _settingTile(Icons.notifications_outlined, tr['notification']!, null, () {}, isDark: isDark),
            // LANGUAGE CHIP
            _settingTile(
              Icons.language,
              tr['language']!,
              null,
              null,
              isDark: isDark,
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.maroon.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _langChip(
                      'EN',
                      !isBo,
                      () => ref.read(languageProvider.notifier).setLanguage('en'),
                    ),
                    _langChip(
                      'བོ',
                      isBo,
                      () => ref.read(languageProvider.notifier).setLanguage('bo'),
                    ),
                  ],
                ),
              ),
            ),
            _settingTile(Icons.sync, tr['calendar_sync']!, null, () {}, isDark: isDark),
            const SizedBox(height: 24),

            // ─── Appearance ──────────────────
            _sectionLabel(tr['appearance']!),
            const SizedBox(height: 8),
            _switchTile(
              Icons.dark_mode_outlined,
              tr['dark_mode']!,
              isDark,
              () => ref.read(themeNotifierProvider.notifier).toggleTheme(),
              isDark: isDark,
            ),
            _switchTile(
              Icons.contrast,
              tr['high_contrast']!,
              highContrast,
              () => ref.read(highContrastProvider.notifier).toggle(),
              isDark: isDark,
            ),
            const SizedBox(height: 24),

            // ─── Notifications ───────────────
            _sectionLabel(tr['notifications']!),
            const SizedBox(height: 8),
            _switchTile(
              Icons.auto_awesome,
              tr['auspicious_alerts']!,
              _notificationsEnabled,
              () => setState(() => _notificationsEnabled = !_notificationsEnabled),
              subtitle: tr['auspicious_alerts_sub'],
              isDark: isDark,
            ),
            _switchTile(
              Icons.temple_buddhist,
              tr['lineage_ann']!,
              _lineageAlerts,
              () => setState(() => _lineageAlerts = !_lineageAlerts),
              subtitle: tr['lineage_ann_sub'],
              isDark: isDark,
            ),
            _switchTile(
              Icons.self_improvement,
              tr['practice_reminders']!,
              _practiceReminders,
              () => setState(() => _practiceReminders = !_practiceReminders),
              subtitle: tr['practice_reminders_sub'],
              isDark: isDark,
            ),
            const SizedBox(height: 24),

            // ─── Support ─────────────────────
            _sectionLabel(tr['support']!),
            const SizedBox(height: 8),
            _settingTile(Icons.info_outline, tr['about_us']!, null, () {}, isDark: isDark),
            _settingTile(Icons.share, tr['share_app']!, null, () {}, isDark: isDark),
            _settingTile(Icons.star_outline, tr['rate_app']!, null, () {}, isDark: isDark),
            _settingTile(Icons.headset_mic_outlined, tr['contact_support']!, null, () {}, isDark: isDark),
            const SizedBox(height: 24),

            // ─── Sync Export ─────────────────
            _sectionLabel(tr['sync']!),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.download, size: 20, color: AppColors.maroon),
                      const SizedBox(width: 8),
                      Text(
                        tr['calendar_export']!,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppColors.navy,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tr['export_desc']!,
                    style: TextStyle(fontSize: 12, color: AppColors.lightTextSecondary),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.upload, size: 16),
                      label: Text(tr['export_all']!),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.maroon,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _tag('iCALENDAR'),
                      const SizedBox(width: 8),
                      _tag('OFFLINE SYNC'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Footer
            Center(
              child: Text(
                tr['version']!,
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.lightTextSecondary,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                tr['privacy']!,
                style: TextStyle(fontSize: 11, color: AppColors.maroon),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
        color: AppColors.maroon,
      ),
    );
  }

  Widget _settingTile(
    IconData icon,
    String title,
    String? subtitle,
    VoidCallback? onTap, {
    Widget? trailing,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        margin: const EdgeInsets.only(bottom: 2),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.maroon),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.navy,
                ),
              ),
            ),
            if (trailing != null) trailing,
            if (trailing == null)
              Icon(Icons.chevron_right, size: 18, color: AppColors.lightTextSecondary),
          ],
        ),
      ),
    );
  }

  Widget _switchTile(
    IconData icon,
    String title,
    bool value,
    VoidCallback onTap, {
    String? subtitle,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.maroon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.navy,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11, color: AppColors.lightTextSecondary),
                  ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: value ? AppColors.maroon : Colors.grey.shade300,
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _socialBtn(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _langChip(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: active ? AppColors.maroon : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: active ? Colors.white : AppColors.lightTextSecondary,
          ),
        ),
      ),
    );
  }

  Widget _tag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.maroon.withOpacity(0.08),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: AppColors.maroon,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  void _showProfileEditor(BuildContext context, bool isDark, bool isBo) {
    final tr = T.of(isBo);
    final nameCtrl = TextEditingController(text: _profile?['full_name'] ?? '');
    final dharmaCtrl = TextEditingController(text: _profile?['dharma_name'] ?? '');
    final emailCtrl = TextEditingController(text: _profile?['email'] ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : const Color(0xFF1A1A2E),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    tr['update_profile']!,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Center(
                child: Icon(Icons.person, size: 80, color: Colors.white70),
              ),
              const SizedBox(height: 24),
              _profileField(tr['fullname']!, nameCtrl),
              _profileField(tr['dharmaname']!, dharmaCtrl),
              _profileField(tr['email']!, emailCtrl),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await LocalDataService.updateProfile({
                      'full_name': nameCtrl.text,
                      'dharma_name': dharmaCtrl.text,
                      'email': emailCtrl.text,
                    });
                    if (context.mounted) {
                      Navigator.pop(context);
                      _loadProfile();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.maroon,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    tr['save_changes']!,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileField(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white.withOpacity(0.5),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: ctrl,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.08),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
