/// -------------------- MODELS --------------------
class District {
  final String id;
  final String districtName;

  District({required this.id, required this.districtName});

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      id: json['id']?.toString() ?? '',
      districtName: json['districtname']?.toString() ?? '',
    );
  }
}

class PA {
  final String id;
  final String paName;

  PA({required this.id, required this.paName});

  factory PA.fromJson(Map<String, dynamic> json) {
    return PA(
      id: json['id']?.toString() ?? '',
      paName: json['panme']?.toString() ?? '',
    );
  }
}

class ChartData {
  final List<String> titles;
  final List<double> values;

  ChartData({required this.titles, required this.values});

  factory ChartData.fromJson(Map<String, dynamic> json) {
    return ChartData(
      titles: List<String>.from((json['titles'] as List?)?.map((e) => e?.toString() ?? '') ?? []),
      values: List<double>.from((json['values'] as List?)?.map((e) => (e is num ? e.toDouble() : 0.0)) ?? []),
    );
  }

  factory ChartData.empty() {
    return ChartData(titles: [], values: []);
  }
}

// Rename your custom class to avoid conflict
class LineChartReportData {
  final List<String> xAxis;
  final List<double> yAxis;

  LineChartReportData({required this.xAxis, required this.yAxis});

  factory LineChartReportData.fromJson(Map<String, dynamic> json) {
    return LineChartReportData(
      xAxis: List<String>.from((json['xAxis'] as List?)?.map((e) => e?.toString() ?? '') ?? []),
      yAxis: List<double>.from((json['yAxis'] as List?)?.map((e) => (e is num ? e.toDouble() : 0.0)) ?? []),
    );
  }

  factory LineChartReportData.empty() {
    return LineChartReportData(xAxis: [], yAxis: []);
  }
}

class ReportData {
  final ChartData barChart;
  final ChartData pieChart;
  final LineChartReportData lineChart; // Use the renamed class

  ReportData({
    required this.barChart,
    required this.pieChart,
    required this.lineChart,
  });

  factory ReportData.fromJson(Map<String, dynamic> json) {
    return ReportData(
      barChart: json['barChart'] != null 
          ? ChartData.fromJson(json['barChart']) 
          : ChartData.empty(),
      pieChart: json['pieChart'] != null 
          ? ChartData.fromJson(json['pieChart']) 
          : ChartData.empty(),
      lineChart: json['lineChart'] != null 
          ? LineChartReportData.fromJson(json['lineChart']) 
          : LineChartReportData.empty(),
    );
  }

  factory ReportData.empty() {
    return ReportData(
      barChart: ChartData.empty(),
      pieChart: ChartData.empty(),
      lineChart: LineChartReportData.empty(),
    );
  }
}
