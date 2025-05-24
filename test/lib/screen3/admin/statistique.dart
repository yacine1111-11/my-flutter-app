import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class CarInsuranceDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Statistiques Assurance',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color(0xFFF3F6FA),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: DashboardPanel(),
          ),
        ),
      ),
    );
  }
}

class DashboardPanel extends StatefulWidget {
  @override
  State<DashboardPanel> createState() => _DashboardPanelState();
}

class _DashboardPanelState extends State<DashboardPanel> {
  String selectedPeriod = 'Mois';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '📊 Statistiques Assurance Auto',
          style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey[800]),
        ),
        SizedBox(height: 25),
        Row(
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.directions_car,
                title: 'Polices émises',
                value: '1,250',
                color: Color(0xFF2A9D8F),
                percentage: '+0%',
                percentageColor: Colors.grey,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: StatCard(
                icon: Icons.account_balance_wallet,
                title: 'Primes collectées',
                value: '5.4K €',
                color: Color(0xFFE9C46A),
                percentage: '+10.2%',
                percentageColor: Colors.green,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        StatCard(
          icon: Icons.warning_amber_rounded,
          title: "Demandes d'indemnisation", // ✅ تم التصحيح
          value: '20',
          color: Color(0xFFE76F51),
          percentage: '-3.1%',
          percentageColor: Colors.red,
        ),

        SizedBox(height: 16),

        // 📈 Performance Globale
        PerformanceCard(
          performanceText: '+8.3%',
          isPositive: true,
        ),

        SizedBox(height: 24),

        /// Dropdown de filtrage
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '📈 Réclamations par $selectedPeriod',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            DropdownButton<String>(
              value: selectedPeriod,
              items: ['Jour', 'Semaine', 'Mois', 'Année']
                  .map((period) =>
                      DropdownMenuItem(value: period, child: Text(period)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedPeriod = value;
                  });
                }
              },
            ),
          ],
        ),
        SizedBox(height: 200, child: ClaimsChart(period: selectedPeriod)),

        Spacer(),
        Center(
          child: Column(
            children: [
              FlutterLogo(size: 40),
              SizedBox(height: 8),
              Text('Développé avec Flutter',
                  style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
      ],
    );
  }
}

class ClaimsChart extends StatelessWidget {
  final String period;

  ClaimsChart({required this.period});

  List<double> getDataForPeriod(String period) {
    switch (period) {
      case 'Jour':
        return [5, 7, 8, 6, 10, 12, 9];
      case 'Semaine':
        return [60, 70, 50, 40];
      case 'Mois':
        return [30, 45, 20, 50, 40, 60, 35, 25, 70, 55, 30, 45];
      case 'Année':
        return [300, 450, 320, 500, 400];
      default:
        return [];
    }
  }

  List<String> getLabelsForPeriod(String period) {
    switch (period) {
      case 'Jour':
        return ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
      case 'Semaine':
        return ['Sem 1', 'Sem 2', 'Sem 3', 'Sem 4'];
      case 'Mois':
        return [
          'Jan',
          'Fév',
          'Mar',
          'Avr',
          'Mai',
          'Juin',
          'Juil',
          'Août',
          'Sep',
          'Oct',
          'Nov',
          'Déc'
        ];
      case 'Année':
        return ['2019', '2020', '2021', '2022', '2023'];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = getDataForPeriod(period);
    final labels = getLabelsForPeriod(period);

    return BarChart(
      BarChartData(
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 32),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                int index = value.toInt();
                if (index >= 0 && index < labels.length) {
                  return Text(labels[index], style: TextStyle(fontSize: 10));
                }
                return Text('');
              },
              interval: 1,
              reservedSize: 28,
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: [
          for (int i = 0; i < data.length; i++)
            BarChartGroupData(x: i, barRods: [
              BarChartRodData(
                toY: data[i],
                color: Colors.blueAccent,
                width: 14,
                borderRadius: BorderRadius.circular(4),
              ),
            ]),
        ],
        gridData: FlGridData(show: true),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final String percentage;
  final Color percentageColor;

  const StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.percentage,
    required this.percentageColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 5)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, color: color),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                SizedBox(height: 4),
                Text(value,
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Text(
            percentage,
            style:
                TextStyle(color: percentageColor, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class PerformanceCard extends StatelessWidget {
  final String performanceText;
  final bool isPositive;

  const PerformanceCard({
    required this.performanceText,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isPositive ? Color(0xFFDFF5E3) : Color(0xFFFFE1E1),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: isPositive ? Colors.green : Colors.red, width: 1),
      ),
      child: Row(
        children: [
          Icon(
            isPositive ? Icons.trending_up : Icons.trending_down,
            color: isPositive ? Colors.green : Colors.red,
          ),
          SizedBox(width: 12),
          Text(
            'Performance globale : ',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          Text(
            performanceText,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isPositive ? Colors.green : Colors.red,
            ),
          ),
          SizedBox(width: 4),
          Text(
            isPositive ? '📈' : '📉',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
