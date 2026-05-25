import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class ExpenseStatisticsCard extends StatelessWidget {
  final List<Map<String, dynamic>> categoryData;
  final List<Map<String, dynamic>> trendData; // Kept for API compatibility with main.dart
  final Color themeColor;
  final String title;

  const ExpenseStatisticsCard({
    super.key,
    required this.categoryData,
    required this.trendData,
    required this.themeColor,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    if (categoryData.isEmpty) return _buildEmptyState(title);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle(title),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                flex: 5,
                child: SizedBox(
                  height: 140,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 28,
                      sections: _generatePieSections(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 7,
                child: _buildExpandedLegend(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  Widget _cardTitle(String title) {
    return Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1E293B),
      ),
    );
  }

  Widget _buildEmptyState(String title) {
    return Container(
      height: 180,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ),
    );
  }

  List<PieChartSectionData> _generatePieSections() {
    final List<Color> colors = _getPalette();
    return List.generate(categoryData.length, (i) {
      final data = categoryData[i];
      final total = (data['total'] as num).toDouble();
      return PieChartSectionData(
        color: colors[i % colors.length],
        value: total,
        title: '',
        radius: 38,
      );
    });
  }

  List<Color> _getPalette() {
    return [
      themeColor,
      const Color(0xFF38BDF8), // Sky Blue
      const Color(0xFF34D399), // Emerald
      const Color(0xFFFBBF24), // Amber
      const Color(0xFFF472B6), // Pink
      const Color(0xFFA78BFA), // Purple
      const Color(0xFFFB7185), // Rose
    ];
  }

  Widget _buildExpandedLegend() {
    final List<Color> colors = _getPalette();
    final displayData = categoryData.take(6).toList();
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(displayData.length, (i) {
        final data = displayData[i];
        final total = (data['total'] as num);
        final formattedTotal = currencyFormat.format(total);

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: colors[i % colors.length],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  data['category'] ?? '...',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                formattedTotal,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
