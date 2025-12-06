import 'dart:convert'; // 🏆 REQUIRED: Import this for jsonDecode()

class Pet {
  String? petId;
  String? userId;
  String? petName;
  String? petType;
  String? category;
  String? description;
  String? lat;
  String? lng;
  // 💡 Note: If you have date/userName fields like your friend, add them here.

  // This field is initialized as an empty list
  List<String> imagePaths = [];

  // --- Constructor (used if you create a Pet object manually) ---
  Pet({
    this.petId,
    this.userId,
    this.petName,
    this.petType,
    this.category,
    this.description,
    this.lat,
    this.lng,
    required this.imagePaths,
  });

  // --- Factory Constructor to create Pet object from JSON (Map) ---
  Pet.fromJson(Map<String, dynamic> json) {
    petId = json["pet_id"]?.toString();
    userId = json["user_id"]?.toString();
    petName = json["pet_name"];
    petType = json["pet_type"];
    category = json["category"];
    description = json["description"];
    lat = json["lat"]?.toString();
    lng = json["lng"]?.toString();

    // 🏆 THE FIX: Using the same robust logic as your friend
    String? pathsString = json['image_paths'];

    imagePaths = (pathsString != null && pathsString.isNotEmpty)
        ? List<String>.from(jsonDecode(pathsString))
        : [];
  }

  // You may want to add a toJson method if you send this object back to the server
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['pet_id'] = petId;
    data['user_id'] = userId;
    data['pet_name'] = petName;
    data['pet_type'] = petType;
    data['category'] = category;
    data['description'] = description;
    data['lat'] = lat;
    data['lng'] = lng;
    // Note: When sending back to server, you may need to jsonEncode this list again
    data['image_paths'] = imagePaths;
    return data;
  }
}
