import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  final String id;
  final String title;
  final String author;
  final String subject;
  final String libraryStatus; // 'available', 'checked_out', 'reference_only'
  final String location;
  final String onlineLink;
  final int coverColor;
  final String edition;
  final List<String> tags;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.subject,
    required this.libraryStatus,
    required this.location,
    required this.onlineLink,
    required this.coverColor,
    required this.edition,
    required this.tags,
  });

  factory Book.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Book(
      id: doc.id,
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      subject: data['subject'] ?? '',
      libraryStatus: data['libraryStatus'] ?? 'unknown',
      location: data['location'] ?? 'N/A',
      onlineLink: data['onlineLink'] ?? '',
      coverColor: data['coverColor'] ?? 0xFF6C63FF,
      edition: data['edition'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'author': author,
        'subject': subject,
        'libraryStatus': libraryStatus,
        'location': location,
        'onlineLink': onlineLink,
        'coverColor': coverColor,
        'edition': edition,
        'tags': tags,
      };

  bool get isAvailable => libraryStatus == 'available';
  bool get isCheckedOut => libraryStatus == 'checked_out';
  bool get isReferenceOnly => libraryStatus == 'reference_only';
}
