class Pet {
  String? petId;
  String? userId;
  String? petName;
  String? petType;
  String? category;
  String? description;
  String? imagePaths;
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
    this.imagePaths,
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
    imagePaths = json['image_paths'];
    lat = json['lat'];
    lng = json['lng'];
    createdAt = json['created_at'];
  }
}
