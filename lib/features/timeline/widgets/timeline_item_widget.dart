import 'package:flutter/material.dart';
import 'package:sparkle_lite/Data/models/timeline_item_model.dart';
import 'symptom_timeline_card.dart';
import 'record_timeline_card.dart';
import 'insight_timeline_card.dart';

/// The TimelineItemWidget is a versatile widget that serves as a building block for displaying individual items in the timeline. It takes a TimelineItem as input and determines the appropriate card widget to display based on the type of the item (symptom, record, or insight). This widget abstracts away the logic of determining which card to use, allowing for a clean and modular design. By using TimelineItemWidget, developers can easily add new types of timeline items in the future without needing to modify the overall structure of the timeline screen. Each card widget (SymptomTimelineCard, RecordTimelineCard, InsightTimelineCard) is responsible for rendering its specific type of timeline item, ensuring that the presentation of each item is tailored to its content and purpose. Overall, TimelineItemWidget contributes to a cohesive and maintainable codebase while providing a consistent user experience across different types of timeline entries.

class TimelineItemWidget extends StatelessWidget {
  final TimelineItem item;
  final VoidCallback? onTap;
  
  const TimelineItemWidget({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    switch (item.type) {
      case TimelineItemType.symptom:
        return SymptomTimelineCard(item: item, onTap: onTap);
      case TimelineItemType.record:
        return RecordTimelineCard(item: item, onTap: onTap);
      case TimelineItemType.insight:
        return InsightTimelineCard(item: item, onTap: onTap);
    }
  }
}