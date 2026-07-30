class Notice {
  final String id;
  final String title;
  final String body;
  final String? contentHtml;
  final DateTime publishedAt;
  final bool isPublished;

  const Notice({
    required this.id,
    required this.title,
    required this.body,
    this.contentHtml,
    required this.publishedAt,
    this.isPublished = true,
  });

  factory Notice.fromJson(Map<String, dynamic> json, {String? id}) {
    return Notice(
      id: id ?? json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      contentHtml: json['content_html'] as String?,
      publishedAt: DateTime.parse(json['published_at'] as String).toLocal(),
      isPublished: json['is_published'] as bool? ?? true,
    );
  }
}
