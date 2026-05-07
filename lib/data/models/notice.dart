class Notice {
  final String id;
  final String title;
  final String body;
  final DateTime publishedAt;

  const Notice({
    required this.id,
    required this.title,
    required this.body,
    required this.publishedAt,
  });

  factory Notice.fromJson(Map<String, dynamic> json) {
    return Notice(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      publishedAt: DateTime.parse(json['published_at'] as String).toLocal(),
    );
  }
}
