class UserModel {
  final String id;
  final String fullName;
  final String phone;
  final String nationalId;
  final String role;
  final bool isActive;
  final String? officeId;

  UserModel({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.nationalId,
    required this.role,
    required this.isActive,
    this.officeId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json["_id"]?.toString() ?? "",
      fullName: json["fullName"]?.toString() ?? "",
      phone: json["phone"]?.toString() ?? "",
      nationalId: json["nationalId"]?.toString() ?? "",
      role: json["role"]?.toString() ?? "citizen",
      isActive: json["isActive"] ?? true,
      officeId: json["officeId"]?.toString(),
    );
  }
}
