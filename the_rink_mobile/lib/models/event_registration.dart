import 'dart:convert';

List<EventRegistration> eventRegistrationFromJson(String str) => List<EventRegistration>.from(json.decode(str).map((x) => EventRegistration.fromJson(x)));

String eventRegistrationToJson(List<EventRegistration> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class EventRegistration {
    String model;
    int pk;
    Fields fields;

    EventRegistration({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory EventRegistration.fromJson(Map<String, dynamic> json) => EventRegistration(
        model: json["model"],
        pk: json["pk"],
        fields: Fields.fromJson(json["fields"]),
    );

    Map<String, dynamic> toJson() => {
        "model": model,
        "pk": pk,
        "fields": fields.toJson(),
    };
}

class Fields {
    int event; // ForeignKey stores the ID of the Event
    int user;  // ForeignKey stores the ID of the User
    DateTime registeredAt;
    bool attended;
    String? notes; // Nullable TextField

    Fields({
        required this.event,
        required this.user,
        required this.registeredAt,
        required this.attended,
        this.notes,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        event: json["event"],
        user: json["user"],
        registeredAt: DateTime.parse(json["registered_at"]),
        attended: json["attended"],
        notes: json["notes"],
    );

    Map<String, dynamic> toJson() => {
        "event": event,
        "user": user,
        "registered_at": registeredAt.toIso8601String(),
        "attended": attended,
        "notes": notes,
    };
}