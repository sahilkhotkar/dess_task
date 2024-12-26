class MarsPhoto {
  final int id;
  final int sol;
  final Camera camera;
  final String imgSrc;
  final String earthDate;
  final Rover rover;

  MarsPhoto({
    required this.id,
    required this.sol,
    required this.camera,
    required this.imgSrc,
    required this.earthDate,
    required this.rover,
  });

  factory MarsPhoto.fromJson(Map<String, dynamic> json) {
    return MarsPhoto(
      id: json['id'] ?? 0,
      sol: json['sol'] ?? 0,
      camera: Camera.fromJson(json['camera']),
      imgSrc: json['img_src'] ?? '',
      earthDate: json['earth_date'] ?? '',
      rover: Rover.fromJson(json['rover']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sol': sol,
      'camera': camera.toJson(),
      'img_src': imgSrc,
      'earth_date': earthDate,
      'rover': rover.toJson(),
    };
  }
}

class Camera {
  final int id;
  final String name;
  final int roverId;
  final String fullName;

  Camera({
    required this.id,
    required this.name,
    required this.roverId,
    required this.fullName,
  });

  factory Camera.fromJson(Map<String, dynamic> json) {
    return Camera(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      roverId: json['rover_id'] ?? 0,
      fullName: json['full_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'rover_id': roverId,
      'full_name': fullName,
    };
  }
}

class Rover {
  final int id;
  final String name;
  final String landingDate;
  final String launchDate;
  final String status;
  final int maxSol;
  final String maxDate;
  final int totalPhotos;
  final List<CameraInfo> cameras;

  Rover({
    required this.id,
    required this.name,
    required this.landingDate,
    required this.launchDate,
    required this.status,
    required this.maxSol,
    required this.maxDate,
    required this.totalPhotos,
    required this.cameras,
  });

  factory Rover.fromJson(Map<String, dynamic> json) {
    return Rover(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      landingDate: json['landing_date'] ?? '',
      launchDate: json['launch_date'] ?? '',
      status: json['status'] ?? '',
      maxSol: json['max_sol'] ?? 0,
      maxDate: json['max_date'] ?? '',
      totalPhotos: json['total_photos'] ?? 0,
      cameras: (json['cameras'] as List<dynamic>?)
              ?.map((cameraJson) => CameraInfo.fromJson(cameraJson))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'landing_date': landingDate,
      'launch_date': launchDate,
      'status': status,
      'max_sol': maxSol,
      'max_date': maxDate,
      'total_photos': totalPhotos,
      'cameras': cameras.map((camera) => camera.toJson()).toList(),
    };
  }
}

class CameraInfo {
  final String name;
  final String fullName;

  CameraInfo({
    required this.name,
    required this.fullName,
  });

  factory CameraInfo.fromJson(Map<String, dynamic> json) {
    return CameraInfo(
      name: json['name'] ?? '',
      fullName: json['full_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'full_name': fullName,
    };
  }
}
