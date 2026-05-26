import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Represents a health record uploaded by the user, such as lab reports, prescriptions, or doctor visit notes.
/// The record includes metadata such as the type of record, date, associated doctor, and optional
/// file URL for attached documents. This model is designed to be flexible to accommodate various types of health records.

enum RecordType {
  labReport,
  prescription,
  scanReport,
  doctorVisit,
  vaccination,
  other,
}

extension RecordTypeExtension on RecordType {
  String get displayName {
    switch (this) {
      case RecordType.labReport:
        return 'Lab Report';
      case RecordType.prescription:
        return 'Prescription';
      case RecordType.scanReport:
        return 'Scan Report';
      case RecordType.doctorVisit:
        return 'Doctor Visit Note';
      case RecordType.vaccination:
        return 'Vaccination Record';
      case RecordType.other:
        return 'Other';
    }
  }
  
  IconData get icon {
    switch (this) {
      case RecordType.labReport:
        return Icons.science;
      case RecordType.prescription:
        return Icons.medication;
      case RecordType.scanReport:
        return Icons.image;
      case RecordType.doctorVisit:
        return Icons.person;
      case RecordType.vaccination:
        return Icons.vaccines;
      case RecordType.other:
        return Icons.folder;
    }
  }
}

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
  final DateTime? updatedAt;

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
    this.updatedAt,
  });

  @override
  List<Object?> get props => [id, userId, title, recordType];
  
  bool get hasFile => fileUrl != null && fileUrl!.isNotEmpty;
  bool get hasDoctor => doctorName != null && doctorName!.isNotEmpty;
  bool get hasNotes => notes != null && notes!.isNotEmpty;

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'recordType': recordType.toString().split('.').last,
      'recordDate': recordDate.toIso8601String(),
      'doctorName': doctorName,
      'fileUrl': fileUrl,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Create from JSON
  factory HealthRecord.fromJson(Map<String, dynamic> json) {
    return HealthRecord(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      recordType: _parseRecordType(json['recordType']),
      recordDate: DateTime.parse(json['recordDate']),
      doctorName: json['doctorName'],
      fileUrl: json['fileUrl'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    );
  }

  static RecordType _parseRecordType(String value) {
    return RecordType.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => RecordType.other,
    );
  }

  // Factory for empty state
  factory HealthRecord.empty(String userId) {
    return HealthRecord(
      id: '',
      userId: userId,
      title: '',
      recordType: RecordType.other,
      recordDate: DateTime.now(),
      createdAt: DateTime.now(),
    );
  }
  
  // Copy with method
  HealthRecord copyWith({
    String? id,
    String? userId,
    String? title,
    RecordType? recordType,
    DateTime? recordDate,
    String? doctorName,
    String? fileUrl,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HealthRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      recordType: recordType ?? this.recordType,
      recordDate: recordDate ?? this.recordDate,
      doctorName: doctorName ?? this.doctorName,
      fileUrl: fileUrl ?? this.fileUrl,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}