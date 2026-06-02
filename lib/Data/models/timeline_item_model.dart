
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// TimelineItem model representing an item in the user's timeline, which can be a symptom log, health record, or AI insight.
/// This model is designed to be flexible and easily extendable, allowing for different types of timeline

enum TimelineItemType {
  symptom,
  record,
  insight,
}

class TimelineItem extends Equatable {
  final String id;
  final TimelineItemType type;
  final DateTime date;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Map<String, dynamic> data;
  
  const TimelineItem({
    required this.id,
    required this.type,
    required this.date,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.data,
  });
  
  @override
  List<Object?> get props => [id, type, date];
  
  String get formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    if (dateOnly == today) return 'Today';
    if (dateOnly == yesterday) return 'Yesterday';
    return '${date.month}/${date.day}/${date.year}';
  }
}