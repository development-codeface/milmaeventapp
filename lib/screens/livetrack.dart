import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:milma_group/const.dart';
import 'package:milma_group/model/reportmodel.dart';
import 'package:milma_group/webservice/webservice.dart';
import 'package:shimmer/shimmer.dart';

class Livetrack extends StatefulWidget {
  final int eventid;
  const Livetrack({super.key, required this.eventid});

  @override
  State<Livetrack> createState() => _LivetrackState();
}

class _LivetrackState extends State<Livetrack> {
  List<District> districtList = [];
  List<PA> paList = [];
  final ScrollController _scrollController = ScrollController();

  ReportData reportData = ReportData.empty();
  String? selectedDistrict = "ALL";
  String? selectedPA = "ALL";
  bool isLoading = true;
  bool isLoadingdrop = true;
  String? errorMessage;
  bool _shouldScrollToCurrentTime = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _timer = Timer.periodic(const Duration(minutes: 30), (timer) {
      _loadReport();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCurrentTime() {
    if (reportData.lineChart.xAxis.isEmpty) {
      return;
    }

    final now = DateTime.now();
    final currentHour = now.hour;
    final currentMinute = now.minute;
    final currentTotalMinutes = currentHour * 60 + currentMinute;

    print("Current time: $currentHour:$currentMinute");

    final xAxis = reportData.lineChart.xAxis;
    int closestIndex = -1;
    int smallestDifference = 1440;

    for (int i = 0; i < xAxis.length; i++) {
      final timeStr = xAxis[i];
      try {
        final parsedTime = DateFormat('hh:mm a').parse(timeStr);
        final totalMinutes = parsedTime.hour * 60 + parsedTime.minute;

        final diff = (totalMinutes - currentTotalMinutes).abs();
        if (diff < smallestDifference) {
          smallestDifference = diff;
          closestIndex = i;
        }
      } catch (e) {
        print("Error parsing time: $timeStr, error: $e");
      }
    }
    if (closestIndex != -1) {
      final double targetPosition = closestIndex * 60.0;

      final viewportWidth = MediaQuery.of(context).size.width;
      final centerOffset = viewportWidth / 2 - 30;

      Future.delayed(const Duration(milliseconds: 500), () {
        _scrollController.animateTo(
          (targetPosition - centerOffset).clamp(
            0.0,
            _scrollController.position.maxScrollExtent,
          ),
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeInOut,
        );
      });
    } else {
      _scrollController.jumpTo(0);
    }
  }

  Future<void> _loadInitialData() async {
    try {
      final districts = await Webservice.getDistricts();
      final pas = await Webservice.getPA();

      setState(() {
        districtList = [District(id: "ALL", districtName: "All District")]
          ..addAll(districts.map((d) => District.fromJson(d)));
        paList = [PA(id: "ALL", paName: "All P&L")]
          ..addAll(pas.map((p) => PA.fromJson(p)));
      });

      await _loadReport();
    } catch (e) {
      setState(() {
        errorMessage = "Failed to load initial data: $e";
        isLoadingdrop = false;
      });
    }
  }

  Future<void> _loadReport() async {
    setState(() {
      isLoadingdrop = false;
      isLoading = true;
      errorMessage = null;
      _shouldScrollToCurrentTime = true;
    });

    try {
      final report = await Webservice.getReport(
        eventId: widget.eventid.toString(),
        district: selectedDistrict,
        pa: selectedPA,
      );

      setState(() {
        reportData = ReportData.fromJson(report);
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToCurrentTime();
      });
    } catch (e) {
      setState(() {
        errorMessage = "Failed to load report: $e";
        reportData = ReportData.empty();
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_shouldScrollToCurrentTime &&
        !isLoading &&
        reportData.lineChart.xAxis.isNotEmpty) {
      _shouldScrollToCurrentTime = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 300), () {
          _scrollToCurrentTime();
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          "LIVE",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            borderRadius: BorderRadius.circular(100),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey, width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.arrow_back_ios_rounded,
                size: 17,
                weight: 5,
                color: primaryColor,
              ),
            ),
          ),
        ),
      ),
      body: isLoadingdrop
          ? _buildShimmerLoader()
          : errorMessage != null
          ? Center(child: Text(errorMessage!))
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _loadReport,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildFilters(),
            const SizedBox(height: 20),
            isLoading
                ? _buildShimmerLoader()
                : Text(
                    'ONBOARDING TREND',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0,
                    ),
                  ),
            const SizedBox(height: 15),
            isLoading ? _buildShimmerLoader() : _buildBarChart(),
            const SizedBox(height: 60),
            isLoading
                ? _buildShimmerLoader()
                : Text(
                    'SNAPSHOT',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0,
                    ),
                  ),
            const SizedBox(height: 15),
            isLoading ? _buildShimmerLoader() : _buildPieChart(),

            const SizedBox(height: 60),
            isLoading
                ? _buildShimmerLoader()
                : Text(
                    'TIMELINE',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0,
                    ),
                  ),
            const SizedBox(height: 15),
            isLoading ? _buildShimmerLoader() : _buildLineChart(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 200,
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10),
              child: DropdownButtonFormField<String>(
                value: selectedDistrict,

                decoration: InputDecoration(
                  labelText: 'District',
                  helperStyle: TextStyle(letterSpacing: 0),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                items: districtList.map((district) {
                  return DropdownMenuItem(
                    value: district.id,
                    child: Text(district.districtName),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => selectedDistrict = value);
                },
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10),
              child: DropdownButtonFormField<String>(
                value: selectedPA,
                decoration: InputDecoration(
                  labelText: 'P&L',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                items: paList.map((pa) {
                  return DropdownMenuItem(value: pa.id, child: Text(pa.paName));
                }).toList(),
                onChanged: (value) {
                  setState(() => selectedPA = value);
                },
              ),
            ),
          ),

          Align(
            alignment: Alignment.topRight,
            child: SizedBox(
              width: 100,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1c27b8),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _loadReport,
                child: const Text(
                  "Filter",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    if (reportData.barChart.titles.isEmpty) {
      return _buildEmptyChart('Bar Chart');
    }

    return Card(
      elevation: 0,

      color: Color(0xFFfff0ef),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              //  alignment: WrapAlignment.center,
              children: List.generate(reportData.barChart.titles.length, (
                index,
              ) {
                final colors = [
                  Color(0xFF214bb9),

                  Color(0xFFe01e05),
                  Color(0xFF33c25b),
                ];
                return Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: _buildLegendDot(
                    colors[index % colors.length],
                    reportData.barChart.titles[index],
                    reportData.barChart.values[index].toStringAsFixed(0),
                  ),
                );
              }),
            ),

            const SizedBox(height: 16),

            const SizedBox(height: 25),
            SizedBox(
              height: 350,
              child: BarChart(
                BarChartData(
                  barTouchData: BarTouchData(
                    enabled: false,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipPadding: EdgeInsets.only(bottom: 10),
                      tooltipMargin: 0,
                      tooltipRoundedRadius: 0,
                      getTooltipColor: (group) => Colors.transparent,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          rod.toY.toInt() == 0
                              ? ''
                              : rod.toY.toInt().toString(),
                          const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),

                  alignment: BarChartAlignment.spaceAround,
                  maxY: 1000,
                  barGroups: reportData.barChart.titles.asMap().entries.map((
                    entry,
                  ) {
                    final colors = [
                      Color(0xFF214bb9),

                      Color(0xFFe01e05),
                      Color(0xFF33c25b),
                    ];
                    final index = entry.key;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: reportData.barChart.values[index].toDouble(),
                          color: colors[index],
                          width: 16,
                        ),
                      ],
                      showingTooltipIndicators: [0],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 &&
                              index < reportData.barChart.titles.length) {
                            final title = reportData.barChart.titles[index];
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                title.contains(" ")
                                    ? title.replaceFirst(" ", "\n")
                                    : title,
                                style: const TextStyle(fontSize: 10),
                                textAlign: TextAlign.center,
                                softWrap: true,
                                maxLines: 2,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),

                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 100,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    drawHorizontalLine: true,
                    drawVerticalLine: false,
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      left: BorderSide(color: Colors.black),
                      bottom: BorderSide(color: Colors.black),
                    ),
                  ),
                ),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeInOut,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendDot(Color color, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text("$label : ${value}", style: TextStyle(fontSize: 13)),
      ],
    );
  }

  Widget _buildPieChart() {
    if (reportData.pieChart.titles.isEmpty) {
      return _buildEmptyChart('Pie Chart');
    }

    final total = reportData.pieChart.values.fold<double>(0.0, (a, b) => a + b);

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              children: List.generate(reportData.pieChart.titles.length, (
                index,
              ) {
                final title = reportData.pieChart.titles[index];
                final value = reportData.pieChart.values[index].toStringAsFixed(
                  0,
                );
                return Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: _buildLegendDot002(
                    _getColorForIndex(index),
                    "$title",
                    "$value",
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),

            SizedBox(
              height: 300,
              child: PieChart(
                PieChartData(
                  sections: total == 0
                      ? [
                          PieChartSectionData(
                            value: 100,
                            title: '',
                            color: primaryColor,
                            radius: 80,
                          ),
                        ]
                      : reportData.pieChart.titles.asMap().entries.map((entry) {
                          final index = entry.key;
                          final value = reportData.pieChart.values[index];
                          return PieChartSectionData(
                            value: value.toDouble(),
                            title: value.toStringAsFixed(0),
                            color: _getColorForIndex(index),
                            radius: 80,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        }).toList(),
                ),
                duration: const Duration(milliseconds: 1200),
                curve: Curves.easeInOutCubic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart() {
    if (reportData.lineChart.xAxis.isEmpty ||
        reportData.lineChart.yAxis.isEmpty) {
      return _buildEmptyChart('Line Chart');
    }

    final now = DateTime.now();
    final currentHour = now.hour;
    final currentMinute = now.minute;
    final currentTotalMinutes = currentHour * 60 + currentMinute;

    final xAxis = reportData.lineChart.xAxis;
    final yAxis = reportData.lineChart.yAxis.map((e) => e.toDouble()).toList();

    int closestIndex = 0;
    int lastPastIndex = 0;
    int smallestDifference = 1440;
    List<int> validIndices = [];

    for (int i = 0; i < xAxis.length; i++) {
      final timeStr = xAxis[i];
      try {
        final parsedTime = DateFormat('hh:mm a').parse(timeStr);
        final totalMinutes = parsedTime.hour * 60 + parsedTime.minute;
        final diff = totalMinutes - currentTotalMinutes;

        validIndices.add(i);

        if (diff <= 0) {
          lastPastIndex = i;
        }

        if (diff >= 0 && diff.abs() < smallestDifference) {
          smallestDifference = diff.abs();
          closestIndex = i;
        }
      } catch (e) {
        print("Error parsing time: $timeStr, error: $e");
      }
    }

    if (validIndices.isEmpty) {
      closestIndex = 0;
    }

    double rawMaxY = yAxis.reduce((a, b) => a > b ? a : b);

    double maxY;
    double interval;

    if (rawMaxY <= 50) {
      maxY = 50;
      interval = 10;
    } else if (rawMaxY <= 100) {
      maxY = 100;
      interval = 10;
    } else if (rawMaxY <= 150) {
      maxY = 150;
      interval = 10;
    } else {
      maxY = 400;
      interval = 20;
    }

    final chartHeight = 340.0;
    final chartTopPadding = 10.0;
    final dotRadius = 3.0;
    final tooltipOffset = 1.0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        final viewportWidth = MediaQuery.of(context).size.width;
        final centerOffset = viewportWidth / 2 - 30;

        final targetOffset = (closestIndex * 60.0 - centerOffset).clamp(
          0.0,
          _scrollController.position.maxScrollExtent,
        );

        Future.delayed(const Duration(milliseconds: 300), () {
          _scrollController.animateTo(
            targetOffset,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          );
        });
      }
    });

    return Card(
      elevation: 0,
      color: Color(0xFFfff0ef),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            SizedBox(
              height: 400,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 40,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 40.0),
                      child: LineChart(
                        LineChartData(
                          minY: 0,
                          maxY: maxY,
                          lineBarsData: [],
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 35,
                                interval: interval,
                                getTitlesWidget: (value, meta) {
                                  if (value % interval == 0) {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        right: 8.0,
                                      ),
                                      child: Text(
                                        value.toInt().toString(),
                                        style: const TextStyle(fontSize: 10),
                                        textAlign: TextAlign.right,
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          gridData: FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      controller: _scrollController,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 30, right: 40),
                        child: SizedBox(
                          width: xAxis.length * 60.0,
                          child: Stack(
                            children: [
                              LineChart(
                                LineChartData(
                                  minY: 0,
                                  maxY: maxY,
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: xAxis.asMap().entries.map((entry) {
                                        final index = entry.key;
                                        return FlSpot(
                                          index.toDouble(),
                                          yAxis[index],
                                        );
                                      }).toList(),
                                      isCurved: false,
                                      curveSmoothness: 0.3,
                                      dotData: FlDotData(show: true),
                                      color: Colors.blue,
                                    ),
                                  ],
                                  lineTouchData: LineTouchData(enabled: false),
                                  titlesData: FlTitlesData(
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 35,
                                        getTitlesWidget: (value, meta) {
                                          final index = value.toInt();
                                          if (index >= 0 &&
                                              index < xAxis.length) {
                                            final isPastClosest =
                                                index == lastPastIndex;

                                            String label = xAxis[index];
                                            if (index == 0) {
                                              label = 'Before\n$label';
                                            }
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                top: 8.0,
                                              ),
                                              child: Text(
                                                label,
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: isPastClosest
                                                      ? Colors.red
                                                      : Colors.black,
                                                  fontWeight: isPastClosest
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            );
                                          }
                                          return const SizedBox.shrink();
                                        },
                                        interval: 1,
                                      ),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    topTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    rightTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                  ),
                                  gridData: FlGridData(
                                    drawHorizontalLine: true,
                                    drawVerticalLine: true,
                                    show: true,
                                    horizontalInterval: interval / 2,
                                    getDrawingHorizontalLine: (value) {
                                      if (value % interval == 0) {
                                        return FlLine(
                                          color: Colors.grey.withOpacity(0.5),
                                          strokeWidth: 1,
                                        );
                                      }
                                      return FlLine(
                                        color: Colors.grey.withOpacity(0.1),
                                        strokeWidth: 1,
                                      );
                                    },
                                  ),
                                  borderData: FlBorderData(
                                    show: true,
                                    border: Border(
                                      bottom: BorderSide(color: Colors.black),
                                      right: BorderSide(
                                        color: Colors.transparent,
                                      ),
                                      left: BorderSide(
                                        color: Colors.transparent,
                                      ),
                                    ),
                                  ),
                                ),
                                duration: const Duration(milliseconds: 1000),
                                curve: Curves.easeInOutCubic,
                              ),

                              ...xAxis.asMap().entries.map((entry) {
                                final index = entry.key;
                                final value = yAxis[index];
                                if (value == 0) return const SizedBox.shrink();

                                final xPosition = index * 60.0 + 30;

                                final yPosition =
                                    chartTopPadding +
                                    (chartHeight -
                                        (value / maxY * chartHeight)) -
                                    tooltipOffset -
                                    dotRadius;

                                return Positioned(
                                  left: xPosition - 3,
                                  top: yPosition,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 2,
                                    ),
                                    child: Text(
                                      value.toInt().toString(),
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        backgroundColor: Colors.transparent,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyChart(String title) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('No data available', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Color _getColorForIndex(int index) {
    final colors = [Color(0xFFe01e05), Color(0xFF214bb9)];
    return colors[index % colors.length];
  }

  Widget _buildLegendDot002(Color color, String label, String percentage) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text("$label : ${percentage}", style: TextStyle(fontSize: 13)),
      ],
    );
  }

  Widget _buildShimmerLoader() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(5, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(
                height: index == 2 ? 300 : 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
