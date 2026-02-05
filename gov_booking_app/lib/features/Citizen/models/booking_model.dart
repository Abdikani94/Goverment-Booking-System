class Booking {
  final String id;
  final String bookingCode;
  final String status;
  final String date;
  final String officeId;
  final String serviceId;
  final String timeSlotId;
  final String serviceName;
  final String officeName;
  final String slot;
  final String? rejectionReason;

  Booking({
    required this.id,
    required this.bookingCode,
    required this.status,
    required this.date,
    required this.officeId,
    required this.serviceId,
    required this.timeSlotId,
    required this.serviceName,
    required this.officeName,
    required this.slot,
    this.rejectionReason,
  });

  String get timeSlot => slot;

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json["_id"]?.toString() ?? "",
      bookingCode: json["bookingCode"]?.toString() ?? "",
      status: json["status"]?.toString() ?? "pending",
      date: json["date"]?.toString() ?? "",
      officeId: json["officeId"] is Map ? json["officeId"]["_id"] : json["officeId"]?.toString() ?? "",
      serviceId: json["serviceId"] is Map ? json["serviceId"]["_id"] : json["serviceId"]?.toString() ?? "",
      timeSlotId: json["timeSlotId"] is Map ? json["timeSlotId"]["_id"] : json["timeSlotId"]?.toString() ?? "",
      serviceName: json["serviceId"] is Map ? json["serviceId"]["name"] : "Service",
      officeName: json["officeId"] is Map ? json["officeId"]["name"] : "Office",
      slot: json["timeSlotId"] is Map ? (json["timeSlotId"]["startTime"] ?? "") : "",
      rejectionReason: json["rejectionReason"],
    );
  }
}
