import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkle_lite/Data/models/timeline_item_model.dart';
import 'package:sparkle_lite/providers/timeline_provider.dart';
import 'package:sparkle_lite/shared/widgets/empty_state_widget.dart';
import 'package:sparkle_lite/shared/widgets/loading_widget.dart';
import 'widgets/timeline_item_widget.dart';

/// The TimelineScreen is a key feature of the app that provides users with a comprehensive view of their health journey. It displays a chronological list of health-related events, including symptoms, health records, and AI-generated insights. The screen is designed to be visually appealing and user-friendly, with a clean layout and intuitive navigation. Users can easily filter the timeline by event type using the filter chips at the top of the screen, allowing them to focus on specific aspects of their health history. Each timeline item is presented in a card format, providing a snapshot of the event with relevant details such as date, time, and a brief description. Tapping on an item allows users to view more detailed information or edit their entries. The TimelineScreen also includes pull-to-refresh functionality, enabling users to quickly update their timeline with new entries or changes. Overall, the TimelineScreen serves as a central hub for users to track and reflect on their health journey, empowering them to make informed decisions and engage more actively in their healthcare management.
/// The TimelineScreen is built using Flutter and Riverpod for state management, ensuring a responsive and efficient user experience. It handles various states such as loading, error, and empty states gracefully, providing appropriate feedback to users in each scenario. The screen's design emphasizes clarity and ease of use, making it accessible to a wide range of users regardless of their technical proficiency. By offering a comprehensive view of their health history, the TimelineScreen helps users identify patterns, track progress, and gain insights into their overall well-being.

class TimelineScreen extends ConsumerStatefulWidget {
  const TimelineScreen({super.key});

  @override
  ConsumerState<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends ConsumerState<TimelineScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(timelineProvider.notifier).loadTimeline();
    });
  }

  @override
  Widget build(BuildContext context) {
    final timelineState = ref.watch(timelineProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Health Timeline', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: _buildFilterChips(isDark),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(timelineProvider.notifier).refresh();
        },
        child: _buildBody(context, timelineState, isDark),
      ),
    );
  }
  
  Widget _buildFilterChips(bool isDark) {
    final timelineState = ref.watch(timelineProvider);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            FilterChip(
              label: Text('All', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
              selected: timelineState.selectedFilter == null,
              onSelected: (_) {
                ref.read(timelineProvider.notifier).filterByType(null);
              },
              selectedColor: const Color(0xFF7B61FF).withOpacity(0.2),
              backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
            ),
            const SizedBox(width: 8),
            FilterChip(
              label: Text('Symptoms', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
              selected: timelineState.selectedFilter == TimelineItemType.symptom,
              onSelected: (_) {
                ref.read(timelineProvider.notifier).filterByType(TimelineItemType.symptom);
              },
              selectedColor: const Color(0xFF7B61FF).withOpacity(0.2),
              backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
            ),
            const SizedBox(width: 8),
            FilterChip(
              label: Text('Records', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
              selected: timelineState.selectedFilter == TimelineItemType.record,
              onSelected: (_) {
                ref.read(timelineProvider.notifier).filterByType(TimelineItemType.record);
              },
              selectedColor: const Color(0xFF7B61FF).withOpacity(0.2),
              backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
            ),
            const SizedBox(width: 8),
            FilterChip(
              label: Text('AI Insights', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
              selected: timelineState.selectedFilter == TimelineItemType.insight,
              onSelected: (_) {
                ref.read(timelineProvider.notifier).filterByType(TimelineItemType.insight);
              },
              selectedColor: const Color(0xFF7B61FF).withOpacity(0.2),
              backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBody(BuildContext context, TimelineState state, bool isDark) {
    if (state.isLoading) {
      return const LoadingWidget(message: 'Loading timeline...');
    }
    
    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(state.error!, style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(timelineProvider.notifier).refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    if (state.filteredItems.isEmpty) {
      String message = 'No items in timeline';
      if (state.selectedFilter == TimelineItemType.symptom) {
        message = 'No symptoms logged yet. Start tracking your symptoms!';
      } else if (state.selectedFilter == TimelineItemType.record) {
        message = 'No health records yet. Upload your first record!';
      } else if (state.selectedFilter == TimelineItemType.insight) {
        message = 'No AI insights yet. Generate your first insight!';
      }
      
      return EmptyStateWidget(
        title: 'Empty Timeline',
        message: message,
        icon: Icons.timeline,
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.filteredItems.length,
      itemBuilder: (context, index) {
        final item = state.filteredItems[index];
        return TimelineItemWidget(
          item: item,
          onTap: () => _onItemTap(context, item, isDark),
        );
      },
    );
  }
  
  void _onItemTap(BuildContext context, TimelineItem item, bool isDark) {
    switch (item.type) {
      case TimelineItemType.symptom:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tap symptom: ${item.id}')),
        );
        break;
      case TimelineItemType.record:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tap record: ${item.id}')),
        );
        break;
      case TimelineItemType.insight:
        _showInsightDialog(context, item, isDark);
        break;
    }
  }
  
  void _showInsightDialog(BuildContext context, TimelineItem item, bool isDark) {
    final insightData = item.data['insight'];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Colors.grey[850] : Colors.white,
        title: Row(
          children: [
            const Icon(Icons.psychology, color: Color(0xFF4ECDC4)),
            const SizedBox(width: 8),
            Text('AI Health Insight', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                insightData['summary'],
                style: TextStyle(fontWeight: FontWeight.w500, color: isDark ? Colors.white : Colors.black87),
              ),
              const SizedBox(height: 16),
              Divider(color: isDark ? Colors.grey[700] : Colors.grey[300]),
              const SizedBox(height: 8),
              Text(
                'Pattern: ${insightData['possiblePattern']}',
                style: TextStyle(fontSize: 14, color: isDark ? Colors.grey[300] : Colors.grey[700]),
              ),
              const SizedBox(height: 8),
              Text(
                'Guidance: ${insightData['careGuidance']}',
                style: TextStyle(fontSize: 14, color: isDark ? Colors.grey[300] : Colors.grey[700]),
              ),
              const SizedBox(height: 16),
              Text(
                'Questions for your doctor:',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: isDark ? Colors.white : Colors.black87),
              ),
              const SizedBox(height: 8),
              ...(insightData['doctorQuestions'] as List).map((q) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[400] : Colors.grey[600])),
                    Expanded(child: Text(q, style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[300] : Colors.grey[700]))),
                  ],
                ),
              )),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  insightData['disclaimer'],
                  style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[600], fontSize: 11, fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}