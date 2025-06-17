import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class GeneralStatsDialog extends StatefulWidget {
  final List<List<double>> barDataSets;
  final List<List<double>> lineDataSets;
  final List<String> labels;
  final List<String> barNames;
  final List<String> lineNames;
  const GeneralStatsDialog({
    required this.barDataSets,
    required this.lineDataSets,
    required this.labels,
    required this.barNames,
    required this.lineNames,
    super.key,
  });

  @override
  State<GeneralStatsDialog> createState() => _GeneralStatsDialogState();
}

class _GeneralStatsDialogState extends State<GeneralStatsDialog> {
  int selectedStat = 0; // 0: barras, 1: lineas

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(32),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            width: 600,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PREDICCIÓN GENERAL',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    _GeneralTabButton(
                      icon: Icons.bar_chart,
                      selected: selectedStat == 0,
                      onTap: () => setState(() => selectedStat = 0),
                      label: 'Barras',
                    ),
                    const SizedBox(width: 12),
                    _GeneralTabButton(
                      icon: Icons.show_chart,
                      selected: selectedStat == 1,
                      onTap: () => setState(() => selectedStat = 1),
                      label: 'Líneas',
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  height: 320,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child:
                            selectedStat == 0
                                ? _MultiBarChart(
                                  dataSets: widget.barDataSets,
                                  labels: widget.labels,
                                  names: widget.barNames,
                                )
                                : _MultiLineChart(
                                  dataSets: widget.lineDataSets,
                                  labels: widget.labels,
                                  names: widget.lineNames,
                                ),
                      ),
                      const SizedBox(height: 12),
                      _GeneralLegend(
                        names:
                            selectedStat == 0
                                ? widget.barNames
                                : widget.lineNames,
                        colors:
                            selectedStat == 0
                                ? _MultiBarChart.barColors
                                : _MultiLineChart.lineColors,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GeneralTabButton extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final String label;
  const _GeneralTabButton({
    required this.icon,
    required this.selected,
    required this.onTap,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.white.withOpacity(0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? Colors.white : Colors.white24),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MultiBarChart extends StatelessWidget {
  final List<List<double>> dataSets;
  final List<String> labels;
  final List<String> names;
  const _MultiBarChart({
    required this.dataSets,
    required this.labels,
    required this.names,
  });

  static List<Color> get barColors => const [
    Color(0xFF00E5FF),
    Color(0xFFFF4081),
    Color(0xFF43E97B),
    Color(0xFF7C4DFF),
  ];

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        minY: 0,
        maxY: dataSets.expand((e) => e).reduce((a, b) => a > b ? a : b) * 1.2,
        barTouchData: BarTouchData(enabled: true),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          getDrawingHorizontalLine:
              (value) =>
                  FlLine(color: Colors.white.withOpacity(0.08), strokeWidth: 1),
          getDrawingVerticalLine:
              (value) =>
                  FlLine(color: Colors.white.withOpacity(0.08), strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget:
                  (value, meta) => Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              reservedSize: 28,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                int idx = value.toInt();
                if (value == idx.toDouble() &&
                    idx >= 0 &&
                    idx < labels.length) {
                  return Text(
                    labels[idx],
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
              reservedSize: 28,
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(
          labels.length,
          (i) => BarChartGroupData(
            x: i,
            barRods: List.generate(
              dataSets.length,
              (j) => BarChartRodData(
                toY: dataSets[j][i],
                width: 12,
                borderRadius: BorderRadius.circular(4),
                color: barColors[j % barColors.length],
              ),
            ),
            showingTooltipIndicators: [0],
          ),
        ),
        groupsSpace: 18,
      ),
    );
  }
}

class _MultiLineChart extends StatelessWidget {
  final List<List<double>> dataSets;
  final List<String> labels;
  final List<String> names;
  const _MultiLineChart({
    required this.dataSets,
    required this.labels,
    required this.names,
  });

  static List<Color> get lineColors => const [
    Color(0xFF00E5FF),
    Color(0xFFFF4081),
    Color(0xFF43E97B),
    Color(0xFF7C4DFF),
  ];

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        minY: 0,
        maxY: dataSets.expand((e) => e).reduce((a, b) => a > b ? a : b) * 1.2,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          getDrawingHorizontalLine:
              (value) =>
                  FlLine(color: Colors.white.withOpacity(0.08), strokeWidth: 1),
          getDrawingVerticalLine:
              (value) =>
                  FlLine(color: Colors.white.withOpacity(0.08), strokeWidth: 1),
        ),
        lineBarsData: List.generate(
          dataSets.length,
          (j) => LineChartBarData(
            spots: List.generate(
              dataSets[j].length,
              (i) => FlSpot(i.toDouble(), dataSets[j][i]),
            ),
            isCurved: true,
            color: lineColors[j % lineColors.length],
            barWidth: 4,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(show: false),
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget:
                  (value, meta) => Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              reservedSize: 28,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                int idx = value.toInt();
                if (value == idx.toDouble() &&
                    idx >= 0 &&
                    idx < labels.length) {
                  return Text(
                    labels[idx],
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
              reservedSize: 28,
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}

class _GeneralLegend extends StatelessWidget {
  final List<String> names;
  final List<Color> colors;
  const _GeneralLegend({required this.names, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        names.length,
        (i) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: colors[i % colors.length],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                names[i],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  shadows: [
                    Shadow(
                      blurRadius: 2,
                      color: Colors.black,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
