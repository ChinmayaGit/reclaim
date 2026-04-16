import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../constants/app_constants.dart';

class MoodPicker extends StatefulWidget {
  const MoodPicker({super.key, this.initialValue = 3, required this.onChanged});

  final int initialValue;
  final ValueChanged<int> onChanged;

  @override
  State<MoodPicker> createState() => _MoodPickerState();
}

class _MoodPickerState extends State<MoodPicker> {
  late int _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How are you feeling?',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (index) {
            final value = index + 1;
            final isSelected = _selected == value;
            return GestureDetector(
              onTap: () {
                setState(() => _selected = value);
                widget.onChanged(value);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isSelected ? 58 : 50,
                height: isSelected ? 58 : 50,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.teal50 : AppColors.slate50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? AppColors.teal400 : AppColors.border,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [BoxShadow(color: AppColors.teal400.withValues(alpha: 0.2), blurRadius: 8)]
                      : [],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppConstants.moodEmojis[index],
                      style: TextStyle(fontSize: isSelected ? 24 : 20),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            AppConstants.moodLabels[_selected - 1],
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.teal600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
