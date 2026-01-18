import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
// import '../../data/models/session.dart';
// import '../../data/repositories/analytics_repository.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetch sessions
    // Ideally we subscribe to a provider.
    // For now, we'll just read from repository or use a future.
    // We can create a provider for sessions in providers.dart or here
    
    return Scaffold(
      appBar: AppBar(title: const Text('Insights')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Learning Consistency', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 20),
            
            // Placeholder for Weekly Chart
            SizedBox(
              height: 200,
              child: _WeeklyChart(),
            ),
             const SizedBox(height: 40),
             
             Text('Contribution Graph', style: Theme.of(context).textTheme.headlineMedium),
             const SizedBox(height: 20),
             _HeatMap(),
          ],
        ),
      ),
    );
  }
}

class _WeeklyChart extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
     // Mock data or read from Repo
     return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100, // max minutes?
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const style = TextStyle(color: Colors.white, fontSize: 10);
                String text;
                switch (value.toInt()) {
                  case 0: text = 'M'; break;
                  case 1: text = 'T'; break;
                  case 2: text = 'W'; break;
                  case 3: text = 'T'; break;
                  case 4: text = 'F'; break;
                  case 5: text = 'S'; break;
                  case 6: text = 'S'; break;
                  default: text = '';
                }
                return SideTitleWidget(meta: meta, child: Text(text, style: style));
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: [
          // Simplified implementation: displaying dummy data structure
          // In real app, map Repository data to these groups
          makeGroupData(0, 5),
          makeGroupData(1, 6.5),
          makeGroupData(2, 5),
          makeGroupData(3, 7.5),
          makeGroupData(4, 9),
          makeGroupData(5, 11.5),
          makeGroupData(6, 6.5),
        ],
        gridData: const FlGridData(show: false),
      ),
    );
  }

  BarChartGroupData makeGroupData(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: AppTheme.accent,
          width: 16,
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 20, // Max scale
            color: Colors.white.withValues(alpha: 0.05),
          ),
        ),
      ],
    );
  }
}

class _HeatMap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: 28, // 4 weeks
      itemBuilder: (context, index) {
        // Random opacity for demo
        final opacity = (index % 5 + 1) * 0.2; 
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.accent.withValues(alpha: opacity),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      },
    );
  }
}
