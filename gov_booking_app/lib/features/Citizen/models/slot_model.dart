class TimeSlot {
  final String id;
  final String startTime;
  final String endTime;
  final int capacity;
  final int bookedCount;
  final String status;

  TimeSlot({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.capacity,
    required this.bookedCount,
    required this.status,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      id: json["_id"]?.toString() ?? "",
      startTime: json["startTime"]?.toString() ?? "",
      endTime: json["endTime"]?.toString() ?? "",
      capacity: (json["capacity"] ?? 0) as int,
      bookedCount: (json["bookedCount"] ?? 0) as int,
      status: json["status"]?.toString() ?? "open",
    );
  }

  bool get isFull => bookedCount >= capacity;
  String get time => "$startTime - $endTime";
}
