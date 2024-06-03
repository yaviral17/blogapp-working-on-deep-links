class Blog {
  String id;
  String title;
  String summary;
  String imageurl;
  String source;
  String author;
  DateTime date;

  Blog(
      {required this.id,
      required this.title,
      required this.summary,
      required this.imageurl,
      required this.source,
      required this.author,
      required this.date});

  factory Blog.fromJson(Map<String, dynamic> json) {
    return Blog(
      id: json['id'],
      title: json['title'],
      summary: json['summary'],
      imageurl: json['imageurl'],
      source: json['source'],
      author: json['author'],
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'imageurl': imageurl,
      'source': source,
      'author': author,
      'date': date.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Blog{id: $id,title: $title, summary: $summary, imageurl: $imageurl, source: $source, author: $author, date: $date}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Blog &&
          id == other.id &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          summary == other.summary &&
          imageurl == other.imageurl &&
          source == other.source &&
          author == other.author &&
          date == other.date;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      summary.hashCode ^
      imageurl.hashCode ^
      source.hashCode ^
      author.hashCode ^
      date.hashCode;

  Blog copyWith({
    String? id,
    String? title,
    String? summary,
    String? imageurl,
    String? source,
    String? author,
    DateTime? date,
  }) {
    return Blog(
      id: id ?? this.id,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      imageurl: imageurl ?? this.imageurl,
      source: source ?? this.source,
      author: author ?? this.author,
      date: date ?? this.date,
    );
  }
}
