class AnalysisResult {
  final String id;
  final String userId;
  final String fileName;
  final String fileType;
  final String analysisResult;
  final double confidenceScore;
  final DateTime createdAt;

  AnalysisResult({
    required this.id,
    required this.userId,
    required this.fileName,
    required this.fileType,
    required this.analysisResult,
    required this.confidenceScore,
    required this.createdAt,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      id: json['id'].toString(),
      userId: json['user_id'],
      fileName: json['file_name'],
      fileType: json['file_type'],
      analysisResult: json['analysis_result'],
      confidenceScore: (json['confidence_score'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'file_name': fileName,
      'file_type': fileType,
      'analysis_result': analysisResult,
      'confidence_score': confidenceScore,
      'created_at': createdAt.toIso8601String(),
    };
  }
} 