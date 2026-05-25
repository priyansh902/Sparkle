
import 'package:equatable/equatable.dart';

/// Represents a health record entry for a user, capturing details about various types of health-related documents and information.
enum RecordType{
  labReport,
  prescription,
  scanReports,
  doctorVisits,
  vaccination,
  other
}

/// A data model class representing a health record, which includes details such as the record's title, type, date, associated doctor, and any relevant notes or file attachments.
class HealthRecord extends Equatable {
  final String id;
  final String userId;
  final String title;
  final RecordType recordType;
  final DateTime recordDate;
  final String? doctorName;
  final String? fileUrl;
  final String? notes;
  final DateTime createdAt;

/// Creates a new instance of [HealthRecord] with the provided parameters.
  const HealthRecord({
    required this.id,
    required this.userId,
    required this.title,
    required this.recordType,
    required this.recordDate,
    this.doctorName,
    this.fileUrl,
    this.notes,
    required this.createdAt,
  });

/// Returns a list of properties that are used to determine equality between instances of [HealthRecord].
  @override
  List<Object?> get props => [id, userId, title, recordType];
  
  /// A computed property that checks if the health record has an associated file URL, indicating the presence of an attached document or report.
  bool get hasFile => fileUrl != null && fileUrl!.isNotEmpty;
}