import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../services/local_notification_service.dart';
import '../data/habit_model.dart';
import '../domain/discipline_notifier.dart';

/// Opens the add-habit bottom sheet (templates, icon mode, goal, difficulty, reminder).
Future<void> showAddHabitSheet(BuildContext context, WidgetRef ref) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => _AddHabitSheetBody(
      onClose: () => Navigator.pop(ctx),
      onSave: (habit) async {
        await ref.read(disciplineProvider.notifier).addHabit(habit);
      },
    ),
  );
}

class _AddHabitSheetBody extends StatefulWidget {
  const _AddHabitSheetBody({
    required this.onClose,
    required this.onSave,
  });

  final VoidCallback onClose;
  final Future<void> Function(HabitItem habit) onSave;

  @override
  State<_AddHabitSheetBody> createState() => _AddHabitSheetBodyState();
}

class _AddHabitSheetBodyState extends State<_AddHabitSheetBody> {
  final _ctrl = TextEditingController();
  final _emojiCtrl = TextEditingController();
  int _selectedIcon = 0;
  String _difficulty = 'medium';
  XFile? _pickedImage;
  bool _saving = false;
  HabitIconSource _iconMode = HabitIconSource.material;
  int _dailyGoal = 1;
  bool _reminderOn = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);

  static const _icons = [
    (Icons.water_drop, AppColors.blue400),
    (Icons.fitness_center, AppColors.amber400),
    (Icons.menu_book, AppColors.purple400),
    (Icons.no_cell, AppColors.coral400),
    (Icons.self_improvement, AppColors.teal400),
    (Icons.directions_run, AppColors.green400),
    (Icons.nightlight, AppColors.purple600),
    (Icons.apple, AppColors.coral600),
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    _emojiCtrl.dispose();
    super.dispose();
  }

  Future<String?> _persistImage(String habitId) async {
    final picked = _pickedImage;
    if (picked == null) return null;
    final dir = await getApplicationSupportDirectory();
    final folder = Directory('${dir.path}/habit_images');
    await folder.create(recursive: true);
    final ext = picked.path.split('.').last.toLowerCase();
    final safe = ['jpg', 'jpeg', 'png', 'webp'].contains(ext) ? ext : 'jpg';
    final dest = File('${folder.path}/$habitId.$safe');
    await File(picked.path).copy(dest.path);
    return dest.path;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (file != null) setState(() => _pickedImage = file);
  }

  Future<void> _pickReminderTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (t != null) setState(() => _reminderTime = t);
  }

  Future<void> _submit() async {
    final name = _ctrl.text.trim();
    if (name.isEmpty) return;

    if (_iconMode == HabitIconSource.emoji &&
        _emojiCtrl.text.trim().isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter an emoji, or switch icon mode.')),
      );
      return;
    }
    if (_iconMode == HabitIconSource.customImage && _pickedImage == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick a photo, or switch icon mode.')),
      );
      return;
    }
    if (_reminderOn) {
      final ok = await LocalNotificationService.instance.requestPermission();
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Notification permission was denied — reminder may not fire.',
            ),
          ),
        );
      }
    }

    setState(() => _saving = true);
    final id = 'habit_${DateTime.now().millisecondsSinceEpoch}';
    final (icon, color) = _icons[_selectedIcon];
    final pts = pointsForDifficulty(_difficulty);

    String? emoji;
    String? imagePath;
    var iconCode = icon.codePoint;
    var colorValue = color.toARGB32();
    HabitIconSource source = _iconMode;

    if (_iconMode == HabitIconSource.emoji) {
      emoji = _emojiCtrl.text.trim();
      imagePath = null;
    } else if (_iconMode == HabitIconSource.customImage) {
      emoji = null;
      imagePath = await _persistImage(id);
    } else {
      emoji = null;
      imagePath = null;
    }

    final habit = HabitItem(
      id: id,
      name: name,
      iconCode: iconCode,
      colorValue: colorValue,
      emoji: emoji,
      customImagePath: imagePath,
      pointsWeight: pts,
      iconSource: source,
      dailyGoal: _dailyGoal.clamp(1, 99),
      reminderEnabled: _reminderOn,
      reminderHour: _reminderTime.hour,
      reminderMinute: _reminderTime.minute,
    );
    await widget.onSave(habit);
    if (mounted) {
      setState(() => _saving = false);
      widget.onClose();
    }
  }

  Future<void> _savePreset(HabitItem p) async {
    setState(() => _saving = true);
    await widget.onSave(
      HabitItem(
        id: 'habit_${DateTime.now().millisecondsSinceEpoch}',
        name: p.name,
        iconCode: p.iconCode,
        colorValue: p.colorValue,
        emoji: p.emoji,
        customImagePath: p.customImagePath,
        pointsWeight: p.pointsWeight,
        iconSource: p.iconSource,
        dailyGoal: p.dailyGoal,
        reminderEnabled: p.reminderEnabled,
        reminderHour: p.reminderHour,
        reminderMinute: p.reminderMinute,
      ),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom +
        MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 20, 24, bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'Add habit',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: context.colText,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Quick templates (tap to add — edit later in checklist)',
              style: TextStyle(color: context.colTextSec, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: kHabitPresets.map((p) {
                return ActionChip(
                  avatar: Text(
                    p.emoji ?? '📝',
                    style: const TextStyle(fontSize: 14),
                  ),
                  label: Text(
                    p.dailyGoal > 1 ? '${p.name} (${p.dailyGoal}×)' : p.name,
                    style: const TextStyle(fontSize: 12),
                  ),
                  onPressed: _saving ? null : () => _savePreset(p),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Text(
              'Custom habit',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: context.colText,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ctrl,
              decoration: InputDecoration(
                hintText: 'Name (e.g. Evening walk, Vitamins)',
                hintStyle:
                    TextStyle(color: context.colTextHint, fontSize: 13),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Icon',
              style: TextStyle(color: context.colTextSec, fontSize: 12),
            ),
            const SizedBox(height: 8),
            SegmentedButton<HabitIconSource>(
              segments: const [
                ButtonSegment(
                  value: HabitIconSource.material,
                  label: Text('Material'),
                  icon: Icon(Icons.widgets_outlined, size: 16),
                ),
                ButtonSegment(
                  value: HabitIconSource.emoji,
                  label: Text('Emoji'),
                  icon: Icon(Icons.emoji_emotions_outlined, size: 16),
                ),
                ButtonSegment(
                  value: HabitIconSource.customImage,
                  label: Text('Photo'),
                  icon: Icon(Icons.image_outlined, size: 16),
                ),
              ],
              selected: {_iconMode},
              onSelectionChanged: (s) =>
                  setState(() => _iconMode = s.first),
            ),
            const SizedBox(height: 12),
            if (_iconMode == HabitIconSource.emoji) ...[
              TextField(
                controller: _emojiCtrl,
                maxLength: 8,
                decoration: InputDecoration(
                  labelText: 'Emoji',
                  hintText: 'e.g. 💧 📚',
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ],
            if (_iconMode == HabitIconSource.customImage) ...[
              OutlinedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image_outlined, size: 18),
                label: Text(
                  _pickedImage == null
                      ? 'Choose photo'
                      : 'Photo: ${_pickedImage!.name}',
                ),
              ),
            ],
            if (_iconMode == HabitIconSource.material) ...[
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _icons.asMap().entries.map((e) {
                  final (ic, col) = e.value;
                  final isSel = e.key == _selectedIcon;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIcon = e.key),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isSel
                            ? col.withValues(alpha: 0.18)
                            : context.colTint(
                                AppColors.slate100, AppColors.slate100Dk),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSel ? col : context.colBorder,
                        ),
                      ),
                      child: Icon(
                        ic,
                        color: isSel ? col : context.colTextSec,
                        size: 20,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              'Times to log per day',
              style: TextStyle(color: context.colTextSec, fontSize: 12),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                IconButton.filledTonal(
                  onPressed: _dailyGoal <= 1
                      ? null
                      : () => setState(() => _dailyGoal--),
                  icon: const Icon(Icons.remove),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '$_dailyGoal',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: context.colText,
                    ),
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: _dailyGoal >= 24
                      ? null
                      : () => setState(() => _dailyGoal++),
                  icon: const Icon(Icons.add),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _dailyGoal > 1
                        ? 'Repeating habit (e.g. water glasses, short walks).'
                        : 'Once per day (e.g. workout, journal).',
                    style: TextStyle(fontSize: 11, color: context.colTextHint),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Difficulty → max points when goal is met',
              style: TextStyle(color: context.colTextSec, fontSize: 12),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ('easy', 'Easy · 1 pt'),
                ('medium', 'Medium · 2 pt'),
                ('hard', 'Hard · 3 pt'),
                ('expert', 'Expert · 5 pt'),
              ].map((e) {
                final sel = _difficulty == e.$1;
                return FilterChip(
                  selected: sel,
                  label: Text(e.$2, style: const TextStyle(fontSize: 11)),
                  onSelected: (_) => setState(() => _difficulty = e.$1),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Daily reminder'),
              subtitle: Text(
                _reminderOn
                    ? 'Required: pick a time below.'
                    : 'Optional nudge at the same time each day.',
                style: TextStyle(fontSize: 11, color: context.colTextHint),
              ),
              value: _reminderOn,
              onChanged: (v) => setState(() => _reminderOn = v),
            ),
            if (_reminderOn) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.schedule),
                title: const Text('Notify at'),
                subtitle: Text(_reminderTime.format(context)),
                trailing: const Icon(Icons.chevron_right),
                onTap: _pickReminderTime,
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _saving || _ctrl.text.trim().isEmpty ? null : _submit,
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Save custom habit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
