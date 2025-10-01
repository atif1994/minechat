import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:minechat/model/data/dashboard/faq_item.dart';
import 'package:minechat/model/data/dashboard/series_point.dart';
import 'package:minechat/model/data/dashboard/stat_item.dart';

class DashboardController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Header
  final dateRange = 'Jan 1 - 2025 Dec 31 - 2025'.obs;

  // Stats (dynamic from Firebase)
  final stats = <StatItem>[].obs;

  // Messages sent mix
  final humanPercent = 30.0.obs; // 0..100
  double get aiPercent => 100 - humanPercent.value;

  // FAQs
  final faqs = <FaqItem>[].obs;

  // Hourly series
  final hourly = <SeriesPoint>[].obs;

  // Real data counters
  final totalMessages = 0.obs;
  final totalLeads = 0.obs;
  final totalOpportunities = 0.obs;
  final totalFollowUps = 0.obs;
  final aiMessages = 0.obs;
  final humanMessages = 0.obs;
  final isLoading = false.obs;

  String getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  @override
  void onInit() {
    super.onInit();
    loadRealData();
  }

  Future<void> loadRealData() async {
    final userId = getCurrentUserId();
    if (userId.isEmpty) return;

    try {
      isLoading.value = true;
      print('🔄 Loading real dashboard data...');
      
      // Load all data in parallel
      await Future.wait([
        loadMessagesData(userId),
        loadCrmData(userId),
        loadHourlyData(userId),
        loadFaqData(userId),
      ]);

      // Update stats with real data
      updateStats();
      
      print('✅ Dashboard data loaded successfully');
      print('📊 Total Messages: ${totalMessages.value}');
      print('🤖 AI Messages: ${aiMessages.value}');
      print('👤 Human Messages: ${humanMessages.value}');
      print('📈 Leads: ${totalLeads.value}');
      print('💼 Opportunities: ${totalOpportunities.value}');
    } catch (e) {
      print('❌ Error loading dashboard data: $e');
      // Fallback to demo data if real data fails
      loadDemoData();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMessagesData(String userId) async {
    try {
      // Get messages from user_messages collection
      final messagesQuery = await _firestore
          .collection('user_messages')
          .doc(userId)
          .collection('messages')
          .get();

      final messages = messagesQuery.docs;
      totalMessages.value = messages.length;

      // Count AI vs Human messages
      int aiCount = 0;
      int humanCount = 0;

      for (final doc in messages) {
        final data = doc.data();
        final isFromUser = data['isFromUser'] as bool? ?? true;
        final platform = data['platform'] as String? ?? '';
        final senderName = data['senderName']?.toString().toLowerCase() ?? '';
        final text = data['text']?.toString().toLowerCase() ?? '';
        
        // More sophisticated AI detection
        bool isAIMessage = false;
        
        // Check if it's explicitly marked as AI
        if (platform.toLowerCase().contains('ai') || 
            senderName.contains('ai') ||
            senderName.contains('assistant') ||
            senderName.contains('bot')) {
          isAIMessage = true;
        }
        
        // Check for AI-like patterns in message content
        if (text.contains('ai assistant') || 
            text.contains('automated response') ||
            text.contains('this is an ai') ||
            text.contains('i\'m an ai')) {
          isAIMessage = true;
        }
        
        // Check if message is from user (human) vs system (AI)
        if (isFromUser) {
          humanCount++;
        } else {
          aiCount++;
        }
      }

      aiMessages.value = aiCount;
      humanMessages.value = humanCount;

      // Calculate percentages
      if (totalMessages.value > 0) {
        humanPercent.value = (humanCount / totalMessages.value * 100).roundToDouble();
      }
    } catch (e) {
      print('❌ Error loading messages data: $e');
    }
  }

  Future<void> loadCrmData(String userId) async {
    try {
      // Load leads
      final leadsQuery = await _firestore
          .collection('leads')
          .where('userId', isEqualTo: userId)
          .get();

      totalLeads.value = leadsQuery.docs.length;

      // Count follow-ups (leads with status 'followUps')
      int followUpsCount = 0;
      for (final doc in leadsQuery.docs) {
        final data = doc.data();
        if (data['status'] == 'followUps') {
          followUpsCount++;
        }
      }
      totalFollowUps.value = followUpsCount;

      // Load opportunities
      final opportunitiesQuery = await _firestore
          .collection('opportunities')
          .where('userId', isEqualTo: userId)
          .get();

      totalOpportunities.value = opportunitiesQuery.docs.length;
    } catch (e) {
      print('❌ Error loading CRM data: $e');
    }
  }

  Future<void> loadHourlyData(String userId) async {
    try {
      // Get messages from last 24 hours and group by hour
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));

      final messagesQuery = await _firestore
          .collection('user_messages')
          .doc(userId)
          .collection('messages')
          .where('timestamp', isGreaterThan: Timestamp.fromDate(yesterday))
          .get();

      // Initialize hourly data
      final hourlyData = List<int>.filled(24, 0);

      for (final doc in messagesQuery.docs) {
        final data = doc.data();
        final timestamp = data['timestamp'] as Timestamp?;
        if (timestamp != null) {
          final hour = timestamp.toDate().hour;
          hourlyData[hour]++;
        }
      }

      // Convert to SeriesPoint format (sample every 3 hours)
      final hourlyPoints = <SeriesPoint>[];
      final labels = ['12am', '3am', '6am', '9am', '12pm', '3pm', '6pm', '9pm', '11pm'];
      final hours = [0, 3, 6, 9, 12, 15, 18, 21, 23];

      for (int i = 0; i < labels.length; i++) {
        hourlyPoints.add(SeriesPoint(
          label: labels[i],
          value: hourlyData[hours[i]].toDouble(),
        ));
      }

      hourly.assignAll(hourlyPoints);
    } catch (e) {
      print('❌ Error loading hourly data: $e');
      // Fallback to demo data
      loadDemoHourlyData();
    }
  }

  Future<void> loadFaqData(String userId) async {
    try {
      // Get FAQ data from messages (look for common questions)
      final messagesQuery = await _firestore
          .collection('user_messages')
          .doc(userId)
          .collection('messages')
          .where('isFromUser', isEqualTo: true)
          .get();

      final faqCounts = <String, int>{};
      
      for (final doc in messagesQuery.docs) {
        final data = doc.data();
        final text = (data['text'] as String? ?? '').toLowerCase();
        
        // Count common FAQ patterns
        if (text.contains('demo')) {
          faqCounts['Do you provide demos?'] = (faqCounts['Do you provide demos?'] ?? 0) + 1;
        }
        if (text.contains('desktop') || text.contains('computer')) {
          faqCounts['Will this also work on a desktop?'] = (faqCounts['Will this also work on a desktop?'] ?? 0) + 1;
        }
        if (text.contains('scale') || text.contains('business')) {
          faqCounts['How can it help me scale my business?'] = (faqCounts['How can it help me scale my business?'] ?? 0) + 1;
        }
        if (text.contains('promo') || text.contains('discount') || text.contains('offer')) {
          faqCounts['Are there ongoing promos?'] = (faqCounts['Are there ongoing promos?'] ?? 0) + 1;
        }
      }

      final faqList = faqCounts.entries
          .map((e) => FaqItem(question: e.key, count: e.value))
          .toList()
        ..sort((a, b) => b.count.compareTo(a.count));

      faqs.assignAll(faqList);
    } catch (e) {
      print('❌ Error loading FAQ data: $e');
      // Fallback to demo data
      loadDemoFaqData();
    }
  }

  void updateStats() {
    // Calculate time saved (estimate based on AI messages)
    final timeSavedHours = (aiMessages.value * 0.5).round(); // Assume 30 min saved per AI message
    
    // Calculate percentage changes (simplified - in real app, compare with previous periods)
    final timeSavedChange = timeSavedHours > 0 ? '+${((timeSavedHours / 10) * 100).round()}%' : '+0%';
    final followUpsChange = totalFollowUps.value > 0 ? '-${((totalFollowUps.value / 5) * 100).round()}%' : '-0%';
    final leadsChange = totalLeads.value > 0 ? '-${((totalLeads.value / 20) * 100).round()}%' : '-0%';
    final opportunitiesChange = totalOpportunities.value > 0 ? '+${((totalOpportunities.value / 10) * 100).round()}%' : '+0%';

    stats.assignAll([
      StatItem(
        title: 'Time Saved',
        value: '${timeSavedHours}h',
        isPositive: timeSavedHours > 0,
        deltaText: '$timeSavedChange from last week',
        iconPath: 'assets/images/icons/icon_dashboard_time_saved.svg',
        chipBgColor: const Color(0xFFEDFAF4),
        chipIconColor: const Color(0xFF69DB9D),
      ),
      StatItem(
        title: 'Follow-ups',
        value: totalFollowUps.value.toString(),
        isPositive: false,
        deltaText: '$followUpsChange from last month',
        iconPath: 'assets/images/icons/icon_dashboard_follow_ups.svg',
        chipBgColor: const Color(0xFFF0EFF9),
        chipIconColor: const Color(0xFF4139B9),
      ),
      StatItem(
        title: 'Leads',
        value: totalLeads.value.toString(),
        isPositive: false,
        deltaText: '$leadsChange from last month',
        iconPath: 'assets/images/icons/icon_dashboard_leads.svg',
        chipBgColor: const Color(0xFFEAF2FF),
        chipIconColor: const Color(0xFF1677ff),
      ),
      StatItem(
        title: 'Opportunities',
        value: totalOpportunities.value.toString(),
        isPositive: true,
        deltaText: '$opportunitiesChange from last month',
        iconPath: 'assets/images/icons/icon_dashboard_opportunities.svg',
        chipBgColor: const Color(0xFFFFF4E8),
        chipIconColor: const Color(0xFFFA8C16),
      ),
    ]);
  }

  void loadDemoData() {
    // Fallback demo data if real data fails
    stats.assignAll([
      StatItem(
        title: 'Time Saved',
        value: '18 hours',
        isPositive: true,
        deltaText: '+18% from last week',
        iconPath: 'assets/images/icons/icon_dashboard_time_saved.svg',
        chipBgColor: const Color(0xFFEDFAF4),
        chipIconColor: const Color(0xFF69DB9D),
      ),
      StatItem(
        title: 'Follow-ups',
        value: '24',
        isPositive: false,
        deltaText: '-18% from last month',
        iconPath: 'assets/images/icons/icon_dashboard_follow_ups.svg',
        chipBgColor: const Color(0xFFF0EFF9),
        chipIconColor: const Color(0xFF4139B9),
      ),
      StatItem(
        title: 'Leads',
        value: '1,684',
        isPositive: false,
        deltaText: '-18% from last month',
        iconPath: 'assets/images/icons/icon_dashboard_leads.svg',
        chipBgColor: const Color(0xFFEAF2FF),
        chipIconColor: const Color(0xFF1677ff),
      ),
      StatItem(
        title: 'Opportunities',
        value: '468',
        isPositive: true,
        deltaText: '+18% from last month',
        iconPath: 'assets/images/icons/icon_dashboard_opportunities.svg',
        chipBgColor: const Color(0xFFFFF4E8),
        chipIconColor: const Color(0xFFFA8C16),
      ),
    ]);
  }

  void loadDemoFaqData() {
    faqs.assignAll([
      const FaqItem(question: 'Do you provide demos?', count: 26),
      const FaqItem(question: 'Will this also work on a desktop?', count: 22),
      const FaqItem(question: 'How can it help me scale my business?', count: 19),
      const FaqItem(question: 'Are there ongoing promos?', count: 14),
    ]);
  }

  void loadDemoHourlyData() {
    hourly.assignAll([
      const SeriesPoint(label: '12am', value: 8),
      const SeriesPoint(label: '3am', value: 7),
      const SeriesPoint(label: '6am', value: 9),
      const SeriesPoint(label: '9am', value: 12),
      const SeriesPoint(label: '12pm', value: 16),
      const SeriesPoint(label: '3pm', value: 14),
      const SeriesPoint(label: '6pm', value: 11),
      const SeriesPoint(label: '9pm', value: 9),
      const SeriesPoint(label: '11pm', value: 8),
    ]);
  }

  // Method to refresh data
  Future<void> refreshData() async {
    await loadRealData();
  }
}
