import 'dart:convert'; // <— REQUIRED IMPORT

class Pet {
  String? petId;
  String? userId;
  String? petName;
  String? petType;
  String? category;
  String? description;
  List<String> imagePaths = [];
  String? lat;
  String? lng;
  String? createdAt;

  Pet({
    this.petId,
    this.userId,
    this.petName,
    this.petType,
    this.category,
    this.description,
    this.lat,
    this.lng,
    this.createdAt,
  });

  Pet.fromJson(Map<String, dynamic> json) {
    petId = json['pet_id']?.toString();
    userId = json['user_id']?.toString();
    petName = json['pet_name'];
    petType = json['pet_type'];
    category = json['category'];
    description = json['description'];
    lat = json['lat'];
    lng = json['lng'];
    createdAt = json['created_at'];

    // 🏆 THE DECODING LOGIC: Converts the JSON string from PHP into a Dart List
    String? pathsString = json['image_paths'];
    if (pathsString != null && pathsString.isNotEmpty) {
      try {
        List<dynamic> dynamicList = jsonDecode(pathsString);
        imagePaths = dynamicList.map((e) => e.toString()).toList();
      } catch (e) {
        // Fallback for failed decoding
        imagePaths = [];
        print('Error decoding imagePaths for pet: $e');
      }
    }
  }
}
