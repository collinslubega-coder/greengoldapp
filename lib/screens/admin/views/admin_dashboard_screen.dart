// lib/screens/admin/views/admin_dashboard_screen.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:green_gold/constants.dart';
import 'package:green_gold/models/order_model.dart';
import 'package:green_gold/services/user_data_service.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

// Enum to manage the selected time frame for filtering data
enum TimeFrame { daily, weekly, monthly, yearly, allTime }

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  TimeFrame _selectedTimeFrame = TimeFrame.daily;
  late Future<Map<String, dynamic>> _dashboardDataFuture;

  @override
  void initState() {
    super.initState();
    _dashboardDataFuture = _fetchDashboardData();
  }

  // Fetches and processes all data needed for the dashboard widgets
  Future<Map<String, dynamic>> _fetchDashboardData() async {
    final userDataService = Provider.of<UserDataService>(context, listen: false);
    await userDataService.refreshOrders(); // Ensure we have the latest orders
    final allOrders = userDataService.orders;

    return {'orders': allOrders};
  }

  void _refreshDashboardData() {
    setState(() {
      _dashboardDataFuture = _fetchDashboardData();
    });
  }

  // Filters a list of orders based on the selected time frame
  List<Order> _filterByTimeFrame(List<Order> data) {
    if (_selectedTimeFrame == TimeFrame.allTime) return data;

    final now = DateTime.now();
    DateTime startDate;

    switch (_selectedTimeFrame) {
      case TimeFrame.daily:
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case TimeFrame.weekly:
        startDate = now.subtract(Duration(days: now.weekday - 1));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        break;
      case TimeFrame.monthly:
        startDate = DateTime(now.year, now.month, 1);
        break;
      case TimeFrame.yearly:
        startDate = DateTime(now.year, 1, 1);
        break;
      case TimeFrame.allTime:
        return data;
    }
    return data.where((item) => item.createdAt.isAfter(startDate)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => _refreshDashboardData(),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _dashboardDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }
            if (!snapshot.hasData || (snapshot.data!['orders'] as List).isEmpty) {
              return const Center(child: Text("No sales data available."));
            }

            final allOrders = snapshot.data!['orders'] as List<Order>;
            final filteredOrders = _filterByTimeFrame(allOrders);

            // Customer Insights Calculation
            final allTimeCustomerContacts = allOrders.map((o) => o.customerContact).toSet();
            final today = DateTime.now();
            final startOfToday = DateTime(today.year, today.month, today.day);
            
            final ordersToday = allOrders.where((o) => o.createdAt.isAfter(startOfToday)).toList();
            final customersToday = ordersToday.map((o) => o.customerContact).toSet();
            
            int newCustomersToday = 0;
            for (var contact in customersToday) {
                final firstOrder = allOrders.where((o) => o.customerContact == contact).reduce((a, b) => a.createdAt.isBefore(b.createdAt) ? a : b);
                if (firstOrder.createdAt.isAfter(startOfToday)) {
                    newCustomersToday++;
                }
            }
            final continuingCustomersAllTime = allTimeCustomerContacts.length;

            // Sales by Category Calculation
            final salesByCategory = <String, int>{};
            for (var order in filteredOrders) {
              for (var item in order.items) {
                final category = item.product?.category ?? 'Unknown';
                salesByCategory[category] = (salesByCategory[category] ?? 0) + item.quantity;
              }
            }

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Sales Dashboard", style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: defaultPadding),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ToggleButtons(
                      isSelected: TimeFrame.values.map((tf) => tf == _selectedTimeFrame).toList(),
                      onPressed: (index) => setState(() => _selectedTimeFrame = TimeFrame.values[index]),
                      borderRadius: BorderRadius.circular(8),
                      children: const [
                        Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("Daily")),
                        Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("Weekly")),
                        Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("Monthly")),
                        Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("Yearly")),
                        Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("All Time")),
                      ],
                    ),
                  ),
                  const SizedBox(height: defaultPadding),

                  // Sales Bar Chart
                  Text("Sales Performance", style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: defaultPadding),
                  SizedBox(
                    height: 280,
                    child: SalesChart(orders: filteredOrders, timeFrame: _selectedTimeFrame),
                  ),
                  const SizedBox(height: defaultPadding * 2),

                  // Customer Insights
                  Text("Customer Insights", style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: defaultPadding / 2),
                   Wrap(
                    spacing: defaultPadding,
                    runSpacing: defaultPadding,
                    children: [
                      MetricCard(title: "New Customers (Today)", value: newCustomersToday.toString()),
                      MetricCard(title: "Total Unique Customers", value: continuingCustomersAllTime.toString()),
                    ],
                  ),
                  const SizedBox(height: defaultPadding * 2),
                  
                  // Sales by Category Pie Chart
                  Text("Units Sold by Category", style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: defaultPadding),
                  SizedBox(
                    height: 250,
                    child: SalesCategoryPieChart(salesData: salesByCategory),
                  ),
                  const SizedBox(height: kToolbarHeight + defaultPadding),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// --- Reusable Widgets for the Dashboard ---

class MetricCard extends StatelessWidget {
  const MetricCard({super.key, required this.title, required this.value});
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(defaultBorderRadious)),
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class PieChartData {
  PieChartData(this.category, this.value);
  final String category;
  final int value;
}

class SalesCategoryPieChart extends StatelessWidget {
  const SalesCategoryPieChart({super.key, required this.salesData});
  final Map<String, int> salesData;

  @override
  Widget build(BuildContext context) {
    final List<PieChartData> chartData = salesData.entries.map((entry) => PieChartData(entry.key, entry.value)).toList();
    final bool hasData = chartData.any((data) => data.value > 0);

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: hasData ? SfCircularChart(
          legend: const Legend(isVisible: true, overflowMode: LegendItemOverflowMode.wrap),
          series: <CircularSeries>[
            DoughnutSeries<PieChartData, String>(
              dataSource: chartData,
              xValueMapper: (PieChartData data, _) => data.category,
              yValueMapper: (PieChartData data, _) => data.value,
              dataLabelSettings: const DataLabelSettings(isVisible: true),
              enableTooltip: true,
            )
          ],
        ) : const Center(child: Text("No sales data for this period.")),
      ),
    );
  }
}

class SalesData {
  SalesData(this.label, this.sales);
  final String label;
  final double sales;
}

class SalesChart extends StatelessWidget {
  const SalesChart({super.key, required this.orders, required this.timeFrame});
  final List<Order> orders;
  final TimeFrame timeFrame;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final chartData = _getChartData();
    final double maxValue = chartData.fold(0.0, (maxVal, element) => max(maxVal, element.sales));

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: SfCartesianChart(
          plotAreaBorderWidth: 0,
          primaryXAxis: const CategoryAxis(
            majorGridLines: MajorGridLines(width: 0),
            axisLine: AxisLine(width: 0),
            majorTickLines: MajorTickLines(size: 0),
          ),
          primaryYAxis: NumericAxis(
            isVisible: true,
            numberFormat: NumberFormat.compactCurrency(locale: 'en_UG', symbol: 'UGX'),
            majorGridLines: const MajorGridLines(width: 0),
            axisLine: const AxisLine(width: 0),
            majorTickLines: const MajorTickLines(size: 0),
            maximum: maxValue > 0 ? (maxValue * 1.2) : null,
          ),
          tooltipBehavior: TooltipBehavior(enable: true, header: ''),
          series: <CartesianSeries<SalesData, String>>[
            ColumnSeries<SalesData, String>(
              dataSource: chartData,
              xValueMapper: (SalesData sales, _) => sales.label,
              yValueMapper: (SalesData sales, _) => sales.sales,
              name: 'Sales',
              color: primaryColor,
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              isTrackVisible: true,
              trackColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
              trackBorderColor: Colors.transparent,
            )
          ],
        ),
      ),
    );
  }

  // Processes order data to be displayed in the bar chart
  List<SalesData> _getChartData() {
    if (orders.isEmpty) {
      return [];
    }

    switch (timeFrame) {
      case TimeFrame.daily:
        final dailySales = {"Morning": 0.0, "Afternoon": 0.0, "Evening": 0.0, "Night": 0.0};
        for (var order in orders) {
          final hour = order.createdAt.hour;
          if (hour >= 6 && hour < 12) {
            dailySales["Morning"] = (dailySales["Morning"] ?? 0) + (order.total ?? 0);
          } else if (hour >= 12 && hour < 17) {
            dailySales["Afternoon"] = (dailySales["Afternoon"] ?? 0) + (order.total ?? 0);
          } else if (hour >= 17 && hour < 21) {
            dailySales["Evening"] = (dailySales["Evening"] ?? 0) + (order.total ?? 0);
          } else {
            dailySales["Night"] = (dailySales["Night"] ?? 0) + (order.total ?? 0);
          }
        }
        return dailySales.entries.map((e) => SalesData(e.key, e.value)).toList();
      
      case TimeFrame.weekly:
        final weeklySales = {"Mon": 0.0, "Tue": 0.0, "Wed": 0.0, "Thu": 0.0, "Fri": 0.0, "Sat": 0.0, "Sun": 0.0};
        for (var order in orders) {
          final day = DateFormat.E().format(order.createdAt);
          weeklySales[day] = (weeklySales[day] ?? 0) + (order.total ?? 0);
        }
        return weeklySales.entries.map((e) => SalesData(e.key, e.value)).toList();

      case TimeFrame.monthly:
        final monthlySales = {"Wk1": 0.0, "Wk2": 0.0, "Wk3": 0.0, "Wk4": 0.0};
        for (var order in orders) {
          final dayOfMonth = order.createdAt.day;
          if (dayOfMonth <= 7) {
            monthlySales["Wk1"] = (monthlySales["Wk1"] ?? 0) + (order.total ?? 0);
          } else if (dayOfMonth <= 14) {
            monthlySales["Wk2"] = (monthlySales["Wk2"] ?? 0) + (order.total ?? 0);
          } else if (dayOfMonth <= 21) {
            monthlySales["Wk3"] = (monthlySales["Wk3"] ?? 0) + (order.total ?? 0);
          } else {
            monthlySales["Wk4"] = (monthlySales["Wk4"] ?? 0) + (order.total ?? 0);
          }
        }
        return monthlySales.entries.map((e) => SalesData(e.key, e.value)).toList();
      
      case TimeFrame.yearly:
        final yearlySales = Map.fromEntries(List.generate(12, (i) => MapEntry(i + 1, 0.0)));
        for (var order in orders) {
          yearlySales[order.createdAt.month] = (yearlySales[order.createdAt.month] ?? 0) + (order.total ?? 0);
        }
        return yearlySales.entries.map((e) => SalesData(DateFormat.MMM().format(DateTime(0, e.key)), e.value)).toList();

      case TimeFrame.allTime:
        final Map<int, double> allTimeSales = {};
        for (var order in orders) {
          allTimeSales[order.createdAt.year] = (allTimeSales[order.createdAt.year] ?? 0) + (order.total ?? 0);
        }
        var sortedYears = allTimeSales.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
        return sortedYears.map((e) => SalesData(e.key.toString(), e.value)).toList();
    }
  }
}