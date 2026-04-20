import 'package:cloud_firestore/cloud_firestore.dart';

class GateInfo {
  final String id;
  final String branchCode;
  final String branchName;
  final String examName;
  final String eligibility;
  final DateTime examDate;
  final DateTime registrationStart;
  final DateTime registrationDeadline;
  final String syllabusLink;
  final String officialLink;
  final List<String> keyTopics;
  final int iconCode;
  final int colorHex;
  final double avgCutoff;

  GateInfo({
    required this.id,
    required this.branchCode,
    required this.branchName,
    required this.examName,
    required this.eligibility,
    required this.examDate,
    required this.registrationStart,
    required this.registrationDeadline,
    required this.syllabusLink,
    required this.officialLink,
    required this.keyTopics,
    required this.iconCode,
    required this.colorHex,
    required this.avgCutoff,
  });

  factory GateInfo.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GateInfo(
      id: doc.id,
      branchCode: data['branchCode'] ?? '',
      branchName: data['branchName'] ?? '',
      examName: data['examName'] ?? '',
      eligibility: data['eligibility'] ?? '',
      examDate: DateTime.parse(data['examDate'] ?? '2026-02-01'),
      registrationStart: DateTime.parse(data['registrationStart'] ?? '2025-08-24'),
      registrationDeadline: DateTime.parse(data['registrationDeadline'] ?? '2025-09-26'),
      syllabusLink: data['syllabusLink'] ?? '',
      officialLink: data['officialLink'] ?? '',
      keyTopics: List<String>.from(data['keyTopics'] ?? []),
      iconCode: data['iconCode'] ?? 0xE0EF,
      colorHex: data['colorHex'] ?? 0xFF6C63FF,
      avgCutoff: (data['avgCutoff'] ?? 0.0).toDouble(),
    );
  }

  int get daysToExam => examDate.difference(DateTime.now()).inDays;
  int get daysToRegistrationDeadline =>
      registrationDeadline.difference(DateTime.now()).inDays;
  bool get isRegistrationOpen =>
      DateTime.now().isAfter(registrationStart) &&
      DateTime.now().isBefore(registrationDeadline);
  bool get isRegistrationClosed => DateTime.now().isAfter(registrationDeadline);
}
