import 'package:flutter/material.dart';
import 'package:milma_group/model/eventmodel.dart';
import 'package:milma_group/model/insightmodel.dart';
import 'package:milma_group/model/loginmodel.dart';
import '../webservice/webservice.dart';

class CommonViewModel extends ChangeNotifier {
  bool loginload = false;
  bool isEventLoading = false;
  bool isInsightLoading = false;
  String? eventError;
  String? insightError;

   LoginResponse? responsedata;
  late Map<String, dynamic> logresp;

  List<EventModel> eventlist = [];


  List<InsightModel> insightlist = [];
  List<InsightModel> filteredinsights = [];

  // LOGIN
  Future<Map<String, dynamic>> login(String email, String password) async {
    loginload = true;
    notifyListeners();

    logresp = await Webservice().login(email, password);
   // Only assign if the API gave valid data
if (logresp['responsedata'] != null) {
  responsedata = logresp['responsedata'];
} else {
  responsedata = null;
}

    loginload = false;
    notifyListeners();
    return logresp;
  }

  // FETCH EVENTS
  Future<void> getallevents() async {
    try {
      isEventLoading = true;
      eventError = null;
      notifyListeners();

      final response = await Webservice().getallevents();
      eventlist = response['eventlistdata'];
    
    } catch (e) {
      eventError = "Failed to load events";
    } finally {
      isEventLoading = false;
      notifyListeners();
    }
  }

 
  // Insights data
  Future<void> getinsights(int id) async {
    try {
      isInsightLoading = true;
      insightError = null;
      notifyListeners();

      final response = await Webservice().getinsights(id);
      insightlist = response['insightlistdata'];
      filteredinsights = List.from(insightlist);
    } catch (e) {
      insightError = "Failed to load insights";
    } finally {
      isInsightLoading = false;
      notifyListeners();
    }
  }

  // SEARCH INSIGHTS
  void searchinsights(String query) {
  if (query.isEmpty) {
    filteredinsights = List.from(insightlist);
  } else {
    final lowerQuery = query.toLowerCase();
    filteredinsights = insightlist.where((e) {
      final name = (e.name ?? '').toLowerCase();
      final mobile = (e.mobile ?? '').toLowerCase();
      return name.contains(lowerQuery) || mobile.contains(lowerQuery);
    }).toList();
  }
  notifyListeners();
}

}
