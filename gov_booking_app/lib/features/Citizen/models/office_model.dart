class Office {
  final String id;
  final String name;
  final String location;
  final String? description;
  final bool isActive;
  final String openTime;
  final String closeTime;
  final int capacityPerSlot;

  Office({
    required this.id,
    required this.name,
    this.location = "",
    this.description,
    this.isActive = true,
    this.openTime = "09:00",
    this.closeTime = "17:00",
    this.capacityPerSlot = 10,
  });

  factory Office.fromJson(Map<String, dynamic> json) {
    return Office(
      id: json["_id"]?.toString() ?? "",
      name: json["name"]?.toString() ?? "",
      location: json["location"]?.toString() ?? "",
      description: json["description"]?.toString(),
      isActive: json["isActive"] ?? true,
      openTime: json["openTime"]?.toString() ?? "09:00",
      closeTime: json["closeTime"]?.toString() ?? "17:00",
      capacityPerSlot: json["defaultCapacityPerSlot"] ?? 10,
    );
  }
}


