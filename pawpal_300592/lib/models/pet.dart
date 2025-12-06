class Pet {
  String? petId;
  String? userId;
  String? petName;
  String? petType;
  String? category;
  String? description;
  String? lat;
  String? lng;
  List<String> imagePaths;

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

  factory Pet.fromJson(Map<String, dynamic> json) {
    List<String> images = [];

    // Handle case where database stores JSON string of array
    if (json["images"] != null) {
      try {
        images = List<String>.from(json["images"]);
      } catch (_) {
        // If accidentally stored as comma-separated string:
        images = json["images"].toString().split(",");
      }
    }

    return Pet(
      petId: json["pet_id"],
      userId: json["user_id"],
      petName: json["pet_name"],
      petType: json["pet_type"],
      category: json["category"],
      description: json["description"],
      lat: json["lat"],
      lng: json["lng"],
      imagePaths: images,
    );
  }
}
