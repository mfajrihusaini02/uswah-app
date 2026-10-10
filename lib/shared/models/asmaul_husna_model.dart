class AsmaulHusnaModel {
  final int number;
  final String name;
  final String arabic;
  final String meaning;
  final String pronunciation;

  AsmaulHusnaModel({
    required this.number,
    required this.name,
    required this.arabic,
    required this.meaning,
    required this.pronunciation,
  });

  factory AsmaulHusnaModel.fromJson(Map<String, dynamic> json) {
    return AsmaulHusnaModel(
      number: json['urutan'] ?? json['number'] ?? 0,
      name: json['latin'] ?? json['name'] ?? '',
      arabic: json['arab'] ?? json['arabic'] ?? '',
      meaning: json['arti'] ?? json['meaning'] ?? '',
      pronunciation: json['latin'] ?? '',
    );
  }
}
