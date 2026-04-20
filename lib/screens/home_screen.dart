import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../utils/app_theme.dart';
import '../widgets/gradient_card.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final firstName = user?.displayName?.split(' ').first ?? 'Student';
    final firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, $firstName 👋',
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 15,
                            ),
                          ),
                          const Text(
                            'Campus Connect',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Profile Avatar
                    GestureDetector(
                      onTap: () => _showProfileSheet(context),
                      child: Hero(
                        tag: 'profile',
                        child: Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppTheme.primary, AppTheme.secondary],
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: user?.photoURL != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.network(user!.photoURL!,
                                      fit: BoxFit.cover),
                                )
                              : Center(
                                  child: Text(
                                    (firstName.isNotEmpty
                                        ? firstName[0].toUpperCase()
                                        : 'S'),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Hero Banner
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                child: Container(
                  height: 160,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primary, Color(0xFF4A42CC)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.35),
                        blurRadius: 25,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Decorative circles
                      Positioned(
                        right: -20,
                        top: -20,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.07),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 30,
                        bottom: -40,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              '📚 Your Academic Hub',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Library chatbot + GATE resources\nall in one place',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Section title
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(24, 32, 24, 16),
                child: Text(
                  'Quick Access',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            // Main Feature Cards
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.9,
                ),
                delegate: SliverChildListDelegate([
                  GradientCard(
                    title: 'Library\nChatbot',
                    subtitle: 'Ask about books & journals',
                    icon: Icons.chat_bubble_rounded,
                    gradient: const LinearGradient(
                      colors: [AppTheme.primary, Color(0xFF9C8FFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    badgeText: 'AI Powered',
                    onTap: () => _navigate(context, 1),
                  ),
                  GradientCard(
                    title: 'GATE &\nExams',
                    subtitle: 'Branch-wise info & dates',
                    icon: Icons.school_rounded,
                    gradient: const LinearGradient(
                      colors: [AppTheme.secondary, Color(0xFF00B388)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    badgeText: '6 Branches',
                    onTap: () => _navigate(context, 2),
                  ),
                  GradientCard(
                    title: 'Saved\nItems',
                    subtitle: 'Bookmarked books & exams',
                    icon: Icons.bookmark_rounded,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    badgeText: 'Local',
                    onTap: () => _navigate(context, 3),
                  ),
                  GradientCard(
                    title: 'Quick\nSearch',
                    subtitle: 'Find any book or exam',
                    icon: Icons.search_rounded,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD93D), Color(0xFFFF9F43)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    badgeText: 'All-in-one',
                    onTap: () => _showSearchDialog(context),
                  ),
                ]),
              ),
            ),

            // Stats Row
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                child: Row(
                  children: [
                    _StatChip(label: '10+ Books', icon: Icons.menu_book_rounded),
                    const SizedBox(width: 12),
                    _StatChip(label: '6 Branches', icon: Icons.account_tree_rounded),
                    const SizedBox(width: 12),
                    _StatChip(label: 'AI Chat', icon: Icons.auto_awesome_rounded),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  void _navigate(BuildContext context, int index) {
    // Access main navigator and switch tab
    final navigatorState = context.findAncestorStateOfType<State>();
    if (navigatorState != null) {
      // Using callback pattern
    }
    // Simple approach - just rebuild with tab index
    Navigator.of(context).pushNamed('/$index');
  }

  void _showSearchDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.bgCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => const _SearchSheet(),
    );
  }

  void _showProfileSheet(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.secondary]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  (user?.displayName?.isNotEmpty == true
                      ? user!.displayName![0].toUpperCase()
                      : 'S'),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user?.displayName ?? 'Student',
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(user?.email ?? '',
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 14)),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await ctx.read<AuthService>().signOut();
                  if (ctx.mounted) {
                    Navigator.of(ctx).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (_) => false,
                    );
                  }
                },
                icon: const Icon(Icons.logout_rounded, color: AppTheme.accent),
                label: const Text('Sign Out',
                    style: TextStyle(color: AppTheme.accent, fontSize: 16)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.accent),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _StatChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primary, size: 22),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchSheet extends StatefulWidget {
  const _SearchSheet();

  @override
  State<_SearchSheet> createState() => __SearchSheetState();
}

class __SearchSheetState extends State<_SearchSheet> {
  final _searchCtrl = TextEditingController();
  final _firestoreService = FirestoreService();
  List results = [];
  bool _loading = false;

  Future<void> _search(String query) async {
    if (query.isEmpty) {
      setState(() => results = []);
      return;
    }
    setState(() => _loading = true);
    final books = await _firestoreService.searchBooks(query);
    setState(() {
      results = books;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _searchCtrl,
            autofocus: true,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: InputDecoration(
              hintText: 'Search books, GATE info...',
              prefixIcon:
                  const Icon(Icons.search_rounded, color: AppTheme.primary),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            onChanged: _search,
          ),
          const SizedBox(height: 16),
          if (_loading)
            const CircularProgressIndicator()
          else if (results.isNotEmpty)
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: results.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (ctx, i) {
                  final book = results[i];
                  return ListTile(
                    title: Text(book.title,
                        style:
                            const TextStyle(color: AppTheme.textPrimary)),
                    subtitle: Text(book.author,
                        style: const TextStyle(color: AppTheme.textSecondary)),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: book.isAvailable
                            ? AppTheme.secondary.withOpacity(0.15)
                            : AppTheme.accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        book.isAvailable ? 'Available' : 'Checked Out',
                        style: TextStyle(
                          color: book.isAvailable
                              ? AppTheme.secondary
                              : AppTheme.accent,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          else if (_searchCtrl.text.isNotEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text('No books found',
                  style: TextStyle(color: AppTheme.textMuted)),
            ),
        ],
      ),
    );
  }
}
