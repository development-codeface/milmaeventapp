

import 'dart:convert';

EventResponse eventResponseFromJson(String str) =>
    EventResponse.fromJson(json.decode(str));

String eventResponseToJson(EventResponse data) => json.encode(data.toJson());

class EventResponse {
  bool? status;
  List<EventModel>? event;

  EventResponse({this.status, this.event});

  factory EventResponse.fromJson(Map<String, dynamic> json) => EventResponse(
    status: json["status"],
    event: json["data"] == null
        ? []
        : List<EventModel>.from(
            json["data"]!.map((x) => EventModel.fromJson(x)),
          ),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": event == null
        ? []
        : List<dynamic>.from(event!.map((x) => x.toJson())),
  };
}

class EventModel {
  int? id;
  String? title;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? startDate;
  DateTime? endDate;
  String? status;
  dynamic deletedAt;

  EventModel({
    this.id,
    this.title,
    this.createdAt,
    this.updatedAt,
    this.startDate,
    this.endDate,
    this.status,
    this.deletedAt,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) => EventModel(
    id: json["id"],
    title: json["title"],
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null
        ? null
        : DateTime.parse(json["updated_at"]),
    startDate: json["start_date"] == null
        ? null
        : DateTime.parse(json["start_date"]),
    endDate: json["end_date"] == null ? null : DateTime.parse(json["end_date"]),
    status: json["status"],
    deletedAt: json["deleted_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "start_date":
        "${startDate!.year.toString().padLeft(4, '0')}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}",
    "end_date":
        "${endDate!.year.toString().padLeft(4, '0')}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}",
    "status": status,
    "deleted_at": deletedAt,
  };
}
