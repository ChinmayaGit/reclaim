import 'dart:io';

import 'package:flutter/material.dart';

import '../data/habit_model.dart';

/// Renders a habit visual from [HabitIconSource] (Material / emoji / photo).
class HabitIconAvatar extends StatelessWidget {
  const HabitIconAvatar({
    super.key,
    required this.habit,
    this.size = 38,
    this.done = false,
  });

  final HabitItem habit;
  final double size;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final color = Color(habit.colorValue);
    final path = habit.customImagePath;
    final hasImage =
        path != null && path.isNotEmpty && File(path).existsSync();
    final emoji = habit.emoji;

    switch (habit.iconSource) {
      case HabitIconSource.customImage:
        if (hasImage) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(size * 0.26),
            child: Image.file(
              File(path),
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _materialIcon(color, done),
            ),
          );
        }
        return _materialIcon(color, done);
      case HabitIconSource.emoji:
        if (emoji != null && emoji.isNotEmpty) {
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color.withValues(alpha: done ? 0.22 : 0.12),
              borderRadius: BorderRadius.circular(size * 0.26),
            ),
            alignment: Alignment.center,
            child: Text(emoji, style: TextStyle(fontSize: size * 0.52)),
          );
        }
        return _materialIcon(color, done);
      case HabitIconSource.material:
        return _materialIcon(color, done);
    }
  }

  Widget _materialIcon(Color color, bool isDone) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isDone ? color : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(size * 0.26),
      ),
      alignment: Alignment.center,
      child: Icon(
        IconData(habit.iconCode, fontFamily: 'MaterialIcons'),
        color: isDone ? Colors.white : color,
        size: size * 0.47,
      ),
    );
  }
}
