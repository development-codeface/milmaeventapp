
import 'dart:convert';

InsightResponse insightResponseFromJson(String str) => InsightResponse.fromJson(json.decode(str));

String insightResponseToJson(InsightResponse data) => json.encode(data.toJson());

class InsightResponse {
    bool? status;
    List<InsightModel>? insights;

    InsightResponse({
        this.status,
        this.insights,
    });

    factory InsightResponse.fromJson(Map<String, dynamic> json) => InsightResponse(
        status: json["status"],
        insights: json["data"] == null ? [] : List<InsightModel>.from(json["data"]!.map((x) => InsightModel.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "data": insights == null ? [] : List<dynamic>.from(insights!.map((x) => x.toJson())),
    };
}

class InsightModel {
    int? id;
    String? name;
    dynamic mobile;
    DateTime? loginDate;

    InsightModel({
        this.id,
        this.name,
        this.mobile,
        this.loginDate,
    });

    factory InsightModel.fromJson(Map<String, dynamic> json) => InsightModel(
        id: json["id"],
        name: json["name"],
        mobile: json["mobile"],
        loginDate: json["login_date"] == null ? null : DateTime.parse(json["login_date"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "mobile": mobile,
        "login_date": loginDate?.toIso8601String(),
    };
}
