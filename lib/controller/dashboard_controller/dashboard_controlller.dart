import 'dart:ui';

import 'package:get/get.dart';
import 'package:minechat/model/data/dashboard/faq_item.dart';
import 'package:minechat/model/data/dashboard/series_point.dart';
import 'package:minechat/model/data/dashboard/stat_item.dart';

class DashboardController extends GetxController {
  // Header
  final dateRange = 'Jan 1 - 2025 Dec 31 - 2025'.obs;

  // Stats (dynamic later from backend)
  final stats = <StatItem>[].obs;

  // Messages sent mix
  final humanPercent = 30.0.obs; // 0..100
  double get aiPercent => 100 - humanPercent.value;

  // FAQs
  final faqs = <FaqItem>[].obs;

  // Hourly series
  final hourly = <SeriesPoint>[].obs;

  @override
  void onInit() {
    super.onInit();

    // Seed demo data (replace with Firebase later)
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

    faqs.assignAll([
      const FaqItem(question: 'Do you provide demos?', count: 26),
      const FaqItem(question: 'Will this also work on a desktop?', count: 22),
      const FaqItem(
          question: 'How can it help me scale my business?', count: 19),
      const FaqItem(question: 'Are there ongoing promos?', count: 14),
    ]);

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
}
