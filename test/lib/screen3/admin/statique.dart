import 'package:flutter/material.dart';

import '../agent/listassu (2).dart';
import '../contra.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Cards
          Row(
            children: [
              _buildStatCard(
                  'Remorquages', '120', Icons.car_repair, Colors.blue, context),
              const SizedBox(width: 10),
              _buildStatCard("Total d'assurances", '1,248', Icons.assignment,
                  Colors.green, context),
              const SizedBox(width: 10),
              _buildStatCard('Total depannages', '84', Icons.receipt,
                  Colors.orange, context),
              const SizedBox(width: 10),
              _buildStatCard(
                  'Paiements', '3200DA', Icons.people, Colors.green, context),
              const SizedBox(width: 10),
              _buildStatCard('Revenu', '48799DA', Icons.attach_money,
                  Colors.purple, context),
            ],
          ),
          const SizedBox(height: 30),
          // Recent Activities and Charts
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _buildSectionTitle('Les assurances '),
                    const SizedBox(height: 10),
                    _buildRecentPoliciesTable(context),
                    const SizedBox(height: 30),
                    _buildSectionTitle('État de la réclamation'),
                    const SizedBox(height: 10),
                    _buildClaimStatusChart(),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    _buildSectionTitle('Actions rapides'),
                    const SizedBox(height: 10),
                    _buildQuickActions(context),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color,
      BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildRecentPoliciesTable(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RequestListPage(),
                  ),
                );
              },
              child: const Text('Voir tout'),
            ),
            SizedBox(
              height: 10,
            ),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1.5),
                2: FlexColumnWidth(1.5),
                3: FlexColumnWidth(1),
                4: FlexColumnWidth(1),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  children: [
                    _buildTableHeader("Numéro d'assurance"),
                    _buildTableHeader('Client'),
                    _buildTableHeader('Vehicle'),
                    _buildTableHeader('Type'),
                    _buildTableHeader('Matricule'),
                  ],
                ),
                ...List.generate(5, (index) {
                  return TableRow(
                    decoration: index < 4
                        ? BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.grey[300]!),
                            ),
                          )
                        : null,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text('POL-${1 + index}'),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text('Client ${index + 1}'),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                            ['Toyota', 'Honda', 'Ford', 'BMW', 'Tesla'][index]),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child:
                            Text(["tous risque ", "tous risque  "][index % 2]),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Chip(
                          label: Text(
                            ['554225', 'A5533553', '134555535'][index % 3],
                            style: TextStyle(
                              color: [
                                Colors.green,
                                Colors.red,
                                Colors.orange
                              ][index % 3],
                            ),
                          ),
                          backgroundColor: [
                            Colors.green[50],
                            Colors.red[50],
                            Colors.orange[50]
                          ][index % 3],
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildClaimStatusChart() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: Stack(
                children: [
                  Center(
                    child: SizedBox(
                      width: 150,
                      height: 150,
                      child: CircularProgressIndicator(
                        value: 0.7,
                        strokeWidth: 15,
                        color: Colors.blue,
                        backgroundColor: Colors.grey[200],
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '70%',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Réclamations traitées',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildChartLegend('Approuvé', Colors.green),
                _buildChartLegend('En instance', Colors.orange),
                _buildChartLegend('Refuse', Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartLegend(String text, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(text),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildQuickActionButton(
              context,
              'list politiques',
              Icons.add_circle_outline,
              Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InsuranceDocumentScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivities() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: List.generate(5, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          '${index + 1} hour${index == 0 ? '' : 's'} ago',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
