import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/book_model.dart';
import '../services/firestore_service.dart';
import '../services/bookmark_service.dart';
import '../utils/app_theme.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final _service = FirestoreService();
  String _filter = 'all'; // 'all', 'available', 'online'
  final _filters = ['all', 'available', 'checked_out'];
  final _filterLabels = {'all': 'All Books', 'available': 'Available', 'checked_out': 'Checked Out'};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Library Catalog',
                      style: TextStyle(
                          color: AppTheme.textPrimary, fontSize: 28, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  const Text('Browse and find books',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                  const SizedBox(height: 16),
                  // Filter chips
                  SizedBox(
                    height: 38,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: _filters.map((f) {
                        final selected = _filter == f;
                        return GestureDetector(
                          onTap: () => setState(() => _filter = f),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                            decoration: BoxDecoration(
                              color: selected ? AppTheme.primary : AppTheme.bgCard,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: selected ? AppTheme.primary : AppTheme.divider,
                              ),
                            ),
                            child: Text(
                              _filterLabels[f]!,
                              style: TextStyle(
                                color: selected ? Colors.white : AppTheme.textSecondary,
                                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<List<Book>>(
                stream: _service.getBooksStream(),
                builder: (ctx, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
                  }
                  if (snap.hasError) {
                    return const Center(
                        child: Text('Error loading books', style: TextStyle(color: AppTheme.accent)));
                  }
                  var books = snap.data ?? [];
                  if (_filter != 'all') {
                    books = books.where((b) => b.libraryStatus == _filter).toList();
                  }
                  if (books.isEmpty) {
                    return Center(
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Icon(Icons.menu_book_outlined, color: AppTheme.textMuted, size: 48),
                        const SizedBox(height: 16),
                        Text('No books found', style: TextStyle(color: AppTheme.textSecondary)),
                      ]),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: books.length,
                    itemBuilder: (ctx, i) => _BookCard(book: books[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  final Book book;
  const _BookCard({required this.book});

  @override
  Widget build(BuildContext context) {
    final color = Color(book.coverColor);
    final bookmarkService = context.watch<BookmarkService>();
    final isBookmarked = bookmarkService.isBookmarked(book.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.divider),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _showBookDetail(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Book cover
              Container(
                width: 56,
                height: 72,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(book.title,
                        style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(book.author,
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _StatusBadge(book: book),
                        const SizedBox(width: 8),
                        if (book.onlineLink.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('🔗 Online',
                                style: TextStyle(color: AppTheme.primary, fontSize: 10, fontWeight: FontWeight.w600)),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline,
                  color: isBookmarked ? color : AppTheme.textMuted,
                ),
                onPressed: () => bookmarkService.toggleBookmark(BookmarkedItem(
                  id: book.id,
                  type: 'book',
                  title: book.title,
                  subtitle: book.author,
                  link: book.onlineLink,
                  colorHex: book.coverColor,
                  savedAt: DateTime.now(),
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBookDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.bgCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => _BookDetailSheet(book: book),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final Book book;
  const _StatusBadge({required this.book});

  @override
  Widget build(BuildContext context) {
    final Color c;
    final String label;
    if (book.isAvailable) {
      c = AppTheme.secondary;
      label = '✅ Available';
    } else if (book.isCheckedOut) {
      c = AppTheme.accent;
      label = '📤 Checked Out';
    } else {
      c = AppTheme.warning;
      label = '📖 Reference';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: c.withOpacity(0.13), borderRadius: BorderRadius.circular(8)),
      child: Text(label,
          style: TextStyle(color: c, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }
}

class _BookDetailSheet extends StatelessWidget {
  final Book book;
  const _BookDetailSheet({required this.book});

  @override
  Widget build(BuildContext context) {
    final color = Color(book.coverColor);
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.92,
      builder: (_, ctrl) => SingleChildScrollView(
        controller: ctrl,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: AppTheme.divider, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 72, height: 90,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [color, color.withOpacity(0.6)]),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 36),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(book.title,
                            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(book.author, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text(book.edition, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                        const SizedBox(height: 8),
                        _StatusBadge(book: book),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (book.isAvailable) ...[
                _InfoRow(icon: Icons.location_on_outlined, label: 'Location', value: book.location, color: color),
                const SizedBox(height: 12),
              ],
              _InfoRow(icon: Icons.category_outlined, label: 'Subject', value: book.subject, color: color),
              const SizedBox(height: 20),
              if (book.tags.isNotEmpty) ...[
                const Text('Tags', style: TextStyle(color: AppTheme.textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8, runSpacing: 6,
                  children: book.tags.map((t) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                    child: Text(t, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
                  )).toList(),
                ),
                const SizedBox(height: 20),
              ],
              if (book.onlineLink.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final uri = Uri.parse(book.onlineLink);
                      if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
                    },
                    icon: const Icon(Icons.open_in_new_rounded),
                    label: const Text('Read Online (Free)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const _InfoRow({required this.icon, required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
            Text(value, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}
