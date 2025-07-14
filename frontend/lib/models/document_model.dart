class Document {
  final String name;
  final String category;
  final String filePath;
  final DateTime uploadedAt;
  final String? user;
  final DateTime? expiryDate;
  final String? groupId;

  Document({
    required this.name,
    required this.category,
    required this.filePath,
    required this.uploadedAt,
    this.user,
    this.expiryDate,
    this.groupId,
  });

  bool get isExpired => expiryDate != null && expiryDate!.isBefore(DateTime.now());
  
  bool get isExpiringSoon => expiryDate != null && 
      expiryDate!.isAfter(DateTime.now()) &&
      expiryDate!.isBefore(DateTime.now().add(const Duration(days: 30)));

  String get fileExtension => filePath.split('.').last.toUpperCase();
}