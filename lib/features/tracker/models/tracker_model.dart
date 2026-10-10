class HabitItem {
  final String id;
  final String title;
  final String subtitle;
  final String category; // 'sholat', 'quran', 'dzikir'
  final bool isCompleted;

  const HabitItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    this.isCompleted = false,
  });

  HabitItem copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? category,
    bool? isCompleted,
  }) {
    return HabitItem(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
