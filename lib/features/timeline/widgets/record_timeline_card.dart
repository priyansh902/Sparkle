import 'package:flutter/material.dart';
import 'package:sparkle_lite/Data/models/timeline_item_model.dart';
import 'package:sparkle_lite/Data/models/health_record_model.dart';

/// The RecordTimelineCard is a specialized widget designed to display health record entries in the timeline. It takes a TimelineItem as input, extracts the relevant health record data, and presents it in a visually appealing card format. The card includes key information such as the date of the entry, an icon representing the type of record, the title of the entry, the type of health record, the doctor's name (if available), and an indication of whether there are any attachments associated with the record. The design of the RecordTimelineCard emphasizes clarity and ease of reading, with a structured layout that allows users to quickly grasp the details of their health records at a glance. By using this card format consistently across the timeline, users can easily track their health records over time and identify patterns or trends in their healthcare management.
/// The RecordTimelineCard is built using Flutter and follows the same design principles as the other timeline cards, ensuring a cohesive and consistent user experience across different types of timeline entries. It also includes an onTap callback, allowing users to interact with the card and view more detailed information about their health records or edit their entries as needed. Overall, the RecordTimelineCard serves as an essential component of the TimelineScreen, providing users with a clear and organized way to view and manage their health records within the app.

class RecordTimelineCard extends StatelessWidget {
  final TimelineItem item;
  final VoidCallback? onTap;
  
  const RecordTimelineCard({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final recordData = item.data['record'];
    final record = HealthRecord.fromJson(recordData);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark ? Colors.grey[850] : Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date column
              SizedBox(
                width: 60,
                child: Column(
                  children: [
                    Text(
                      _getDay(item.date),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      _getMonth(item.date),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: item.iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: item.iconColor, size: 24),
              ),
              const SizedBox(width: 12),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      record.recordType.displayName,
                      style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13),
                    ),
                    if (record.doctorName != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Dr. ${record.doctorName}',
                        style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[500], fontSize: 12),
                      ),
                    ],
                    if (record.hasFile) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.attach_file, size: 14, color: isDark ? Colors.grey[600] : Colors.grey[400]),
                          const SizedBox(width: 4),
                          Text(
                            'Has attachment',
                            style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[500], fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              
              Icon(Icons.chevron_right, color: isDark ? Colors.grey[600] : Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
  
  String _getDay(DateTime date) {
    return '${date.day}';
  }
  
  String _getMonth(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[date.month - 1];
  }
}