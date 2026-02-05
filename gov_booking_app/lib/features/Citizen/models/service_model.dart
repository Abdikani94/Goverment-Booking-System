class GovernmentService {
  final String id;
  final String name;
  final String? description;
  final String? officeId;
  final double fee;
  final List<String> requiredDocuments;

  GovernmentService({
    required this.id, 
    required this.name, 
    this.description,
    this.officeId,
    this.fee = 0.0,
    this.requiredDocuments = const [],
  });

  factory GovernmentService.fromJson(Map<String, dynamic> json) {
    return GovernmentService(
      id: json["_id"]?.toString() ?? "",
      name: json["name"]?.toString() ?? "",
      description: json["description"]?.toString(),
      officeId: json["officeId"] is Map ? json["officeId"]["_id"] : json["officeId"]?.toString(),
      fee: (json["fee"] is num) ? (json["fee"] as num).toDouble() : 0.0,
      requiredDocuments: ((json["requiredDocuments"] ?? json["requiredDocs"]) as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}



