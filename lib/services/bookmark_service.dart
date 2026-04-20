import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class BookmarkedItem {
  final String id;
  final String type; // 'book' or 'gate'
  final String title;
  final String subtitle;
  final String? link;
  final int colorHex;
  final DateTime savedAt;

  BookmarkedItem({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    this.link,
    required this.colorHex,
    required this.savedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'title': title,
        'subtitle': subtitle,
        'link': link,
        'colorHex': colorHex,
        'savedAt': savedAt.toIso8601String(),
      };

  factory BookmarkedItem.fromJson(Map<String, dynamic> json) => BookmarkedItem(
        id: json['id'],
        type: json['type'],
        title: json['title'],
        subtitle: json['subtitle'],
        link: json['link'],
        colorHex: json['colorHex'],
        savedAt: DateTime.parse(json['savedAt']),
      );
}

class BookmarkService extends ChangeNotifier {
  static const _key = 'campus_bookmarks';
  List<BookmarkedItem> _bookmarks = [];

  List<BookmarkedItem> get bookmarks => _bookmarks;

  BookmarkService() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      final List decoded = json.decode(raw);
      _bookmarks = decoded.map((e) => BookmarkedItem.fromJson(e)).toList();
      notifyListeners();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, json.encode(_bookmarks.map((b) => b.toJson()).toList()));
  }

  bool isBookmarked(String id) => _bookmarks.any((b) => b.id == id);

  Future<void> addBookmark(BookmarkedItem item) async {
    if (!isBookmarked(item.id)) {
      _bookmarks.insert(0, item);
      notifyListeners();
      await _save();
    }
  }

  Future<void> removeBookmark(String id) async {
    _bookmarks.removeWhere((b) => b.id == id);
    notifyListeners();
    await _save();
  }

  Future<void> toggleBookmark(BookmarkedItem item) async {
    if (isBookmarked(item.id)) {
      await removeBookmark(item.id);
    } else {
      await addBookmark(item);
    }
  }
}
