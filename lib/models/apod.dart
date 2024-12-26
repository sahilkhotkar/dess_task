class ApodModel {
  final String copyright;
  final String date;
  final String explanation;
  final String hdurl;
  final String mediaType;
  final String serviceVersion;
  final String title;
  final String url;

  ApodModel({
    required this.copyright,
    required this.date,
    required this.explanation,
    required this.hdurl,
    required this.mediaType,
    required this.serviceVersion,
    required this.title,
    required this.url,
  });

  factory ApodModel.fromJson(Map<String, dynamic> json) {
    return ApodModel(
      copyright: json['copyright'] ?? "Unknown",
      date: json['date'] ?? "",
      explanation: json['explanation'] ?? "",
      hdurl: json['hdurl'] ?? "",
      mediaType: json['media_type'] ?? "",
      serviceVersion: json['service_version'] ?? "",
      title: json['title'] ?? "",
      url: json['url'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'copyright': copyright,
      'date': date,
      'explanation': explanation,
      'hdurl': hdurl,
      'media_type': mediaType,
      'service_version': serviceVersion,
      'title': title,
      'url': url,
    };
  }
}
