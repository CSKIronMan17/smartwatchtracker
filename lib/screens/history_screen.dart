// lib/screens/history_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/health_record.dart';
import '../services/database_service.dart';
import 'package:fl_chart/fl_chart.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final DatabaseService _databaseService = DatabaseService();
  String? _selectedDate;
  List<HealthRecord> _records = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    setState(() => _isLoading = true);
    try {
      _records = await _databaseService.getRecords(dateFilter: _selectedDate);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Health History'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'List View'),
              Tab(text: 'Charts'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: _showDatePicker,
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _buildListView(),
            _buildChartsView(),
          ],
        ),
      ),
    );
  }

  Widget _buildListView() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_records.isEmpty) {
      return const Center(
        child: Text('No records found for the selected period'),
      );
    }

    return ListView.builder(
      itemCount: _records.length,
      itemBuilder: (context, index) {
        final record = _records[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(
              DateFormat('MMM dd, yyyy HH:mm').format(record.timestamp),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.favorite, size: 16, color: Colors.red[400]),
                    const SizedBox(width: 4),
                    Text('${record.heartRate} BPM'),
                    const SizedBox(width: 16),
                    Icon(Icons.directions_walk, size: 16, color: Colors.blue[400]),
                    const SizedBox(width: 4),
                    Text('${record.steps} steps'),
                  ],
                ),
              ],
            ),
            trailing: record.isSynced
                ? const Icon(Icons.cloud_done, color: Colors.green)
                : const Icon(Icons.cloud_off, color: Colors.grey),
          ),
        );
      },
    );
  }

  Widget _buildChartsView() {
    if (_records.isEmpty) {
      return const Center(
        child: Text('No data available for charts'),
      );
    }

    // Prepare data for charts
    final heartRateData = _records.map((record) {
      return FlSpot(
        record.timestamp.millisecondsSinceEpoch.toDouble(),
        record.heartRate.toDouble(),
      );
    }).toList();

    final stepsData = _records.map((record) {
      return FlSpot(
        record.timestamp.millisecondsSinceEpoch.toDouble(),
        record.steps.toDouble(),
      );
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildChart(
            'Heart Rate Over Time',
            heartRateData,
            Colors.red,
            'BPM',
          ),
          const SizedBox(height: 24),
          _buildChart(
            'Steps Over Time',
            stepsData,
            Colors.blue,
            'Steps',
          ),
        ],
      ),
    );
  }

  Widget _buildChart(
    String title,
    List<FlSpot> spots,
    Color color,
    String yAxisLabel,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final date = DateTime.fromMillisecondsSinceEpoch(
                            value.toInt(),
                          );
                          return Text(
                            DateFormat('HH:mm').format(date),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                        reservedSize: 22,
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      axisNameWidget: Text(yAxisLabel),
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: color,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDatePicker() async {
    final dates = await _databaseService.getDistinctDates();
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Date'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: dates.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(DateFormat('MMM dd, yyyy').format(
                  DateTime.parse(dates[index]),
                )),
                onTap: () {
                  setState(() => _selectedDate = dates[index]);
                  Navigator.pop(context);
                  _loadRecords();
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _selectedDate = null);
              Navigator.pop(context);
              _loadRecords();
            },
            child: const Text('Show All'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}