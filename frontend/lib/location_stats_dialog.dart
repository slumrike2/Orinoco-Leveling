import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class LocationStatsDialog extends StatefulWidget {
  final String location;
  final List<double> weekData;
  final List<String> weekDays;
  const LocationStatsDialog({
    required this.location,
    required this.weekData,
    required this.weekDays,
    super.key,
  });

  @override
  State<LocationStatsDialog> createState() => _LocationStatsDialogState();
}

class _LocationStatsDialogState extends State<LocationStatsDialog> {
  int selectedStat = 0;
  final List<IconData> statIcons = [
    Icons.bar_chart,
    Icons.pie_chart,
    Icons.show_chart,
  ];

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
            width: 480,
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
                Text(
                  widget.location.toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '2026-07-22',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      3,
                      (i) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: IconButton(
                          icon: Icon(
                            statIcons[i],
                            color:
                                selectedStat == i
                                    ? Colors.white
                                    : Colors.white70,
                            size: 28,
                          ),
                          onPressed: () => setState(() => selectedStat = i),
                          splashRadius: 22,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  height: 260,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.brown.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: _buildChart(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChart() {
    switch (selectedStat) {
      case 0:
        return _BarChartWidget(data: widget.weekData, labels: widget.weekDays);
      case 1:
        return _PieChartWidget(data: widget.weekData, labels: widget.weekDays);
      case 2:
      default:
        return _LineChartWidget(data: widget.weekData, labels: widget.weekDays);
    }
  }
}

class _BarChartWidget extends StatelessWidget {
  final List<double> data;
  final List<String> labels;
  const _BarChartWidget({required this.data, required this.labels});

  @override
  Widget build(BuildContext context) {
    final Gradient barGradient = const LinearGradient(
      colors: [Color(0xFF2196F3), Color(0xFF43E97B)],
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
    );
    final double minY =
        (data.reduce((a, b) => a < b ? a : b) * 0.95).floorToDouble();
    final double maxY =
        (data.reduce((a, b) => a > b ? a : b) * 1.05).ceilToDouble();
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barTouchData: BarTouchData(enabled: false),
        minY: minY,
        maxY: maxY == minY ? minY + 1 : maxY,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 2,
                        color: Colors.black,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                );
              },
              reservedSize: 28,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                int idx = value.toInt();
                // Solo mostrar el label si el valor es entero y está en el rango
                if (value == idx.toDouble() &&
                    idx >= 0 &&
                    idx < labels.length) {
                  return Text(
                    labels[idx],
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 2,
                          color: Colors.black,
                          offset: Offset(1, 1),
                        ),
                      ],
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
        gridData: FlGridData(show: false),
        barGroups: List.generate(
          data.length,
          (i) => BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: data[i],
                width: 18,
                borderRadius: BorderRadius.circular(4),
                gradient: barGradient,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PieChartWidget extends StatelessWidget {
  final List<double> data;
  final List<String> labels;
  const _PieChartWidget({required this.data, required this.labels});

  List<Color> get pieColors => const [
    Color(0xFF2196F3), // blue
    Color(0xFFFFB300), // orange
    Color(0xFF8E24AA), // purple
    Color(0xFF43A047), // green
    Color(0xFFE91E63), // pink
    Color(0xFF00B8D4), // cyan
    Color(0xFFFF7043), // deep orange
  ];

  @override
  Widget build(BuildContext context) {
    final double total = data.fold(0, (a, b) => a + b);
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: PieChart(
            PieChartData(
              sections: List.generate(
                data.length,
                (i) => PieChartSectionData(
                  value: data[i],
                  color: pieColors[i % pieColors.length],
                  title: '${((data[i] / total) * 100).toStringAsFixed(0)}%',
                  titleStyle: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 2,
                        color: Colors.black,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                  radius: 70,
                  titlePositionPercentageOffset: 0.7,
                ),
              ),
              sectionsSpace: 2,
              centerSpaceRadius: 45,
            ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              data.length,
              (i) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: pieColors[i % pieColors.length],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      // Solo mostrar el nombre del día, sin salto de línea ni fecha
                      labels[i].split('\n')[0],
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
          ),
        ),
      ],
    );
  }
}

class _LineChartWidget extends StatelessWidget {
  final List<double> data;
  final List<String> labels;
  const _LineChartWidget({required this.data, required this.labels});

  @override
  Widget build(BuildContext context) {
    final Gradient lineGradient = const LinearGradient(
      colors: [
        Color.fromARGB(108, 33, 149, 243),
        Color.fromARGB(87, 67, 233, 122),
      ],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );
    final double minY =
        (data.reduce((a, b) => a < b ? a : b) * 0.95).floorToDouble();
    final double maxY =
        (data.reduce((a, b) => a > b ? a : b) * 1.05).ceilToDouble();
    return LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY == minY ? minY + 1 : maxY,

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
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              data.length,
              (i) => FlSpot(i.toDouble(), data[i]),
            ),
            isCurved: true,
            gradient: lineGradient,
            barWidth: 5,
            dotData: FlDotData(
              show: true,
              getDotPainter:
                  (spot, percent, barData, index) => FlDotCirclePainter(
                    radius: 6,
                    color: Colors.white,
                    strokeWidth: 4,
                    strokeColor: lineGradient.colors.first,
                  ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: lineGradient,
              color: Colors.transparent,
              applyCutOffY: false,
            ),
          ),
        ],
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 2,
                        color: Colors.black,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                );
              },
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
                      shadows: [
                        Shadow(
                          blurRadius: 2,
                          color: Colors.black,
                          offset: Offset(1, 1),
                        ),
                      ],
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
