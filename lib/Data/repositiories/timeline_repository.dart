import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkle_lite/Data/models/timeline_item_model.dart';
import 'package:sparkle_lite/Data/models/health_record_model.dart';
import 'symptom_repository.dart';
import 'record_repository.dart';
import 'insight_repository.dart';

/// Repository for managing the user's timeline, which includes symptom logs, health records, and AI insights. This repository abstracts the data layer for the timeline feature, allowing for easy replacement of the underlying data sources in the future without affecting the rest of the application.
/// It fetches data from the SymptomRepository, RecordRepository, and InsightRepository, and combines them into a unified list of TimelineItems that can be displayed in the timeline UI. The repository also provides functionality for filtering the timeline by item type (symptom, record, insight) and sorting items by date. This design ensures that the timeline feature is flexible and can easily adapt to changes in the underlying data models or sources in the future.

final timelineRepositoryProvider = Provider<TimelineRepository>((ref) {

  final symptomRepo = ref.read(symptomRepositoryProvider);

  final recordRepo = ref.read(recordRepositoryProvider);

  final insightRepo = ref.read(insightRepositoryProvider);
  
  return TimelineRepository(
    symptomRepository: symptomRepo,
    recordRepository: recordRepo,
    insightRepository: insightRepo,
  );
});

class TimelineRepository {
  final SymptomRepository symptomRepository;
  final RecordRepository recordRepository;
  final InsightRepository insightRepository;
  
  TimelineRepository({
    required this.symptomRepository,
    required this.recordRepository,
    required this.insightRepository,
  });
  
  Future<List<TimelineItem>> getTimeline(String userId) async {
    final List<TimelineItem> items = [];
    
    // Get all data
    final symptoms = await symptomRepository.getSymptoms(userId);
    final records = await recordRepository.getHealthRecords(userId);
    final insights = await insightRepository.getAIInsights(userId);
    
    // Convert symptoms to timeline items
    for (final symptom in symptoms) {
      items.add(TimelineItem(
        id: symptom.id,
        type: TimelineItemType.symptom,
        date: symptom.date,
        title: 'Symptom Log',
        subtitle: 'Pain: ${symptom.painLevel}/10 • ${symptom.symptoms.take(2).join(', ')}',
        icon: Icons.favorite,
        iconColor: symptom.painLevel >= 7 ? Colors.red : const Color(0xFF7B61FF),
        data: {
          'symptom': symptom.toJson(),
        },
      ));
    }
    
    // Convert records to timeline items
    for (final record in records) {
      items.add(TimelineItem(
        id: record.id,
        type: TimelineItemType.record,
        date: record.recordDate,
        title: record.title,
        subtitle: '${record.recordType.displayName} • ${record.doctorName ?? 'No doctor specified'}',
        icon: record.recordType.icon,
        iconColor: const Color(0xFF7B61FF),
        data: {
          'record': record.toJson(),
        },
      ));
    }
    
    // Convert insights to timeline items
    for (final insight in insights) {
      items.add(TimelineItem(
        id: insight.id,
        type: TimelineItemType.insight,
        date: insight.createdAt,
        title: 'AI Health Insight',
        subtitle: insight.summary.length > 80 
            ? '${insight.summary.substring(0, 80)}...' 
            : insight.summary,
        icon: Icons.psychology,
        iconColor: const Color(0xFF4ECDC4),
        data: {
          'insight': insight.toJson(),
        },
      ));
    }
    
    // Sort by date (newest first)
    items.sort((a, b) => b.date.compareTo(a.date));
    
    return items;
  }
  
  Future<List<TimelineItem>> getFilteredTimeline(String userId, TimelineItemType? type) async {
    final allItems = await getTimeline(userId);
    
    if (type == null) {
      return allItems;
    }
    
    return allItems.where((item) => item.type == type).toList();
  }
}