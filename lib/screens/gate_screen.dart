import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/gate_info_model.dart';
import '../services/firestore_service.dart';
import '../services/bookmark_service.dart';
import '../utils/app_theme.dart';
import 'package:provider/provider.dart';
import '../services/bookmark_service.dart';

class GateScreen extends StatelessWidget {
  const GateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.secondary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppTheme.secondary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'GATE 2026',
                          style: TextStyle(
                            color: AppTheme.secondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'GATE & Exams',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Branch-wise info, dates & syllabus',
                    style: TextStyle(
                        color: AppTheme.textSecondary, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Branch cards list
            Expanded(
              child: StreamBuilder<List<GateInfo>>(
                stream: service.getGateInfoStream(),
                builder: (ctx, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: AppTheme.secondary),
                    );
                  }
                  if (snap.hasError) {
                    return Center(
                      child: Text('Error loading GATE data',
                          style: TextStyle(color: AppTheme.accent)),
                    );
                  }
                  final items = snap.data ?? [];
                  if (items.isEmpty) {
                    return const Center(
                      child: Text('No GATE info available',
                          style:
                              TextStyle(color: AppTheme.textSecondary)),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: items.length,
                    itemBuilder: (ctx, i) => _GateCard(info: items[i]),
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

class _GateCard extends StatelessWidget {
  final GateInfo info;

  const _GateCard({required this.info});

  @override
  Widget build(BuildContext context) {
    final color = Color(info.colorHex);
    final bookmarkService = context.watch<BookmarkService>();
    final isBookmarked = bookmarkService.isBookmarked(info.id);

    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Column(
          children: [
            // Top colored strip
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          IconData(info.iconCode,
                              fontFamily: 'MaterialIcons'),
                          color: color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              info.branchCode,
                              style: TextStyle(
                                color: color,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                              ),
                            ),
                            Text(
                              info.branchName,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => bookmarkService.toggleBookmark(
                          BookmarkedItem(
                            id: info.id,
                            type: 'gate',
                            title: info.branchName,
                            subtitle: info.examName,
                            link: info.officialLink,
                            colorHex: info.colorHex,
                            savedAt: DateTime.now(),
                          ),
                        ),
                        icon: Icon(
                          isBookmarked
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_outline,
                          color: isBookmarked ? color : AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppTheme.divider, height: 1),
                  const SizedBox(height: 14),

                  // Countdown
                  _CountdownRow(info: info, color: color),

                  const SizedBox(height: 14),

                  // Key Topics
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: info.keyTopics
                        .take(4)
                        .map((t) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                t,
                                style: TextStyle(
                                    color: color,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => GateDetailScreen(info: info)),
    );
  }
}

class _CountdownRow extends StatefulWidget {
  final GateInfo info;
  final Color color;

  const _CountdownRow({required this.info, required this.color});

  @override
  State<_CountdownRow> createState() => __CountdownRowState();
}

class __CountdownRowState extends State<_CountdownRow> {
  late Stream<int> _timerStream;

  @override
  void initState() {
    super.initState();
    _timerStream = Stream.periodic(const Duration(seconds: 1), (_) {
      return widget.info.daysToExam;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: _timerStream,
      initialData: widget.info.daysToExam,
      builder: (_, snap) {
        final days = snap.data ?? 0;
        return Row(
          children: [
            _InfoChip(
              icon: Icons.calendar_today_rounded,
              label: days > 0 ? '$days days to exam' : 'Exam passed',
              color: widget.color,
            ),
            const SizedBox(width: 10),
            _InfoChip(
              icon: widget.info.isRegistrationOpen
                  ? Icons.how_to_reg_rounded
                  : Icons.block_rounded,
              label: widget.info.isRegistrationOpen ? 'Reg Open' : 'Reg Closed',
              color: widget.info.isRegistrationOpen
                  ? AppTheme.secondary
                  : AppTheme.accent,
            ),
          ],
        );
      },
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ─── GATE Detail Screen ───────────────────────────────────────────────────────

class GateDetailScreen extends StatelessWidget {
  final GateInfo info;

  const GateDetailScreen({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    final color = Color(info.colorHex);

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppTheme.bgCard,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded,
                  color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 48),
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(
                          IconData(info.iconCode,
                              fontFamily: 'MaterialIcons'),
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        info.branchName,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700),
                      ),
                      Text(
                        info.examName,
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Countdown
                _CountdownCard(info: info, color: color),
                const SizedBox(height: 20),

                // Info Tiles
                _DetailCard(
                    title: 'Eligibility',
                    content: info.eligibility,
                    icon: Icons.verified_user_outlined,
                    color: color),
                const SizedBox(height: 16),
                _DetailCard(
                    title: 'Key Topics',
                    content: info.keyTopics.join(' • '),
                    icon: Icons.topic_outlined,
                    color: color),
                const SizedBox(height: 16),
                _DetailCard(
                    title: 'Average Cutoff',
                    content: '${info.avgCutoff} marks (General)',
                    icon: Icons.bar_chart_rounded,
                    color: color),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            _launchUrl(info.syllabusLink),
                        icon: const Icon(Icons.description_outlined),
                        label: const Text('Syllabus PDF'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _launchUrl(info.officialLink),
                        icon: const Icon(Icons.open_in_new_rounded),
                        label: const Text('Official Site'),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: color),
                          foregroundColor: color,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ],
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }
}

class _CountdownCard extends StatelessWidget {
  final GateInfo info;
  final Color color;

  const _CountdownCard({required this.info, required this.color});

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')} ${_months[d.month - 1]} ${d.year}';

  static const _months = [
    'Jan','Feb','Mar','Apr','May','Jun',
    'Jul','Aug','Sep','Oct','Nov','Dec'
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('📅 Important Dates',
              style: TextStyle(
                  color: color,
                  fontSize: 15,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          _DateRow(label: 'Registration Opens',
              date: _fmt(info.registrationStart), color: color),
          _DateRow(label: 'Registration Closes',
              date: _fmt(info.registrationDeadline), color: color),
          _DateRow(label: 'Exam Date',
              date: _fmt(info.examDate), color: color),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.timer_outlined, color: color, size: 22),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${info.daysToExam > 0 ? info.daysToExam : 0} Days',
                      style: TextStyle(
                          color: color,
                          fontSize: 24,
                          fontWeight: FontWeight.w800),
                    ),
                    const Text('Until Exam',
                        style: TextStyle(
                            color: AppTheme.textMuted, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DateRow extends StatelessWidget {
  final String label, date;
  final Color color;

  const _DateRow(
      {required this.label, required this.date, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 13)),
          Text(date,
              style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final String title, content;
  final IconData icon;
  final Color color;

  const _DetailCard(
      {required this.title,
      required this.content,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(content,
                    style: const TextStyle(
                        color: AppTheme.textPrimary, fontSize: 14, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
