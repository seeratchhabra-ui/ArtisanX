enum UserRoleType { artisan, customer }

class ArtisanProfileModel {
  final String fullName;
  final String? bio;
  final String craftType;
  final int? experienceYears;
  final String? state;
  final String? district;
  final String? village;
  final String? profileImage;

  ArtisanProfileModel({
    required this.fullName,
    this.bio,
    required this.craftType,
    this.experienceYears,
    this.state,
    this.district,
    this.village,
    this.profileImage,
  });

  factory ArtisanProfileModel.fromJson(Map<String, dynamic> json) {
    return ArtisanProfileModel(
      fullName: json['full_name'] ?? 'Asha Devi',
      bio: json['bio'],
      craftType: json['craft_type'] ?? 'Pottery',
      experienceYears: json['experience_years'],
      state: json['state'] ?? 'Rajasthan',
      district: json['district'] ?? 'Jaipur',
      village: json['village'],
      profileImage: json['profile_image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'bio': bio,
      'craft_type': craftType,
      'experience_years': experienceYears,
      'state': state,
      'district': district,
      'village': village,
      'profile_image': profileImage,
    };
  }
}

class UserModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final UserRoleType role;
  final ArtisanProfileModel? artisanProfile;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.artisanProfile,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 1,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] == 'artisan'
          ? UserRoleType.artisan
          : UserRoleType.customer,
      artisanProfile: json['artisan_profile'] != null
          ? ArtisanProfileModel.fromJson(json['artisan_profile'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role == UserRoleType.artisan ? 'artisan' : 'customer',
      'artisan_profile': artisanProfile?.toJson(),
    };
  }
}
