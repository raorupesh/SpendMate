class ChorePlan {
  final String id; // Document ID for Firebase
  final String userId; // ID of the user who created this plan
  final String choreName;
  final List<String> participants;
  final Map<String, Map<String, String>> directAssignments;
  final Map<String, dynamic> finalSchedule;

  ChorePlan({
    required this.choreName,
    required this.participants,
    required this.directAssignments,
    required this.finalSchedule,
    required this.userId,
    this.id = '',
  });

  // Convert to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'choreName': choreName,
      'participants': participants,
      'directAssignments': convertNestedMapToJson(directAssignments),
      'finalSchedule': finalSchedule,
    };
  }

  // Create ChorePlan from Firebase document
  factory ChorePlan.fromMap(String docId, Map<String, dynamic> data) {
    return ChorePlan(
      id: docId,
      userId: data['userId'] ?? '',
      choreName: data['choreName'] ?? '',
      participants: List<String>.from(data['participants'] ?? []),
      directAssignments: convertJsonToNestedMap(data['directAssignments'] ?? {}),
      finalSchedule: data['finalSchedule'] ?? {},
    );
  }

  // Helper methods to handle nested maps in Firestore
  static Map<String, dynamic> convertNestedMapToJson(Map<String, Map<String, String>> nestedMap) {
    Map<String, dynamic> result = {};
    nestedMap.forEach((key, value) {
      result[key] = value;
    });
    return result;
  }

  static Map<String, Map<String, String>> convertJsonToNestedMap(Map<String, dynamic> json) {
    Map<String, Map<String, String>> result = {};
    json.forEach((key, value) {
      if (value is Map) {
        Map<String, String> innerMap = {};
        value.forEach((innerKey, innerValue) {
          innerMap[innerKey.toString()] = innerValue.toString();
        });
        result[key] = innerMap;
      }
    });
    return result;
  }
}