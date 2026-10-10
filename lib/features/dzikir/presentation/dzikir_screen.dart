import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../data/dzikir_data.dart';
import '../providers/dzikir_provider.dart';

class DzikirScreen extends ConsumerStatefulWidget {
  const DzikirScreen({super.key});

  @override
  ConsumerState<DzikirScreen> createState() => _DzikirScreenState();
}

class _DzikirScreenState extends ConsumerState<DzikirScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    // Pilih tab berdasarkan waktu saat ini
    final hour = DateTime.now().hour;
    final initialIndex = (hour >= 15) ? 1 : 0; // >= 15:00 → petang
    _tab = TabController(length: 2, vsync: this, initialIndex: initialIndex);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(dzikirProgressProvider);
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Hitung total selesai masing-masing sesi
    int pagiDone = 0;
    for (final item in dzikirPagi) {
      if ((progress.progress[item.id] ?? 0) >= item.count) pagiDone++;
    }
    int petangDone = 0;
    for (final item in dzikirPetang) {
      if ((progress.progress[item.id] ?? 0) >= item.count) petangDone++;
    }

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 110,
            pinned: true,
            forceElevated: innerBoxIsScrolled,
            centerTitle: true,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            title: Text(
              'Dzikir',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -14,
                      bottom: -26,
                      child: Transform.scale(
                        scaleX: -1,
                        child: Icon(
                          Icons.self_improvement_rounded,
                          size: 160,
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 24,
                      bottom: 12,
                      child: Icon(
                        Icons.menu_book_outlined,
                        size: 44,
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                tooltip: 'Tasbih Digital',
                icon: const Icon(Icons.grain_rounded),
                onPressed: () => context.push('/tasbih'),
              ),
              const SizedBox(width: 8),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                color: AppColors.primary,
                child: TabBar(
                  controller: _tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white60,
                  indicatorColor: Colors.white,
                  indicatorWeight: 3,
                  labelStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  tabs: [
                    Tab(
                      text:
                          'Pagi ($pagiDone/${dzikirPagi.length})',
                    ),
                    Tab(
                      text:
                          'Petang ($petangDone/${dzikirPetang.length})',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tab,
          children: [
            _DzikirList(
              items: dzikirPagi,
              progress: progress,
              isDark: isDark,
              scheme: scheme,
            ),
            _DzikirList(
              items: dzikirPetang,
              progress: progress,
              isDark: isDark,
              scheme: scheme,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── List dzikir ──────────────────────────────────────────────────────────────
class _DzikirList extends ConsumerWidget {
  final List<DzikirItem> items;
  final DzikirProgressState progress;
  final bool isDark;
  final ColorScheme scheme;

  const _DzikirList({
    required this.items,
    required this.progress,
    required this.isDark,
    required this.scheme,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int done = 0;
    for (final item in items) {
      if ((progress.progress[item.id] ?? 0) >= item.count) done++;
    }
    final pct = items.isEmpty ? 0.0 : done / items.length;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: items.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _ProgressHeader(
              done: done, total: items.length, pct: pct, isDark: isDark);
        }
        final item = items[index - 1];
        final current = progress.progress[item.id] ?? 0;
        final isDone = current >= item.count;
        return _DzikirCard(
          item: item,
          current: current,
          isDone: isDone,
          isDark: isDark,
          scheme: scheme,
          onTap: () => ref.read(dzikirProgressProvider.notifier).tap(item.id),
          onReset: () =>
              ref.read(dzikirProgressProvider.notifier).reset(item.id),
        );
      },
    );
  }
}

// ─── Progress header ──────────────────────────────────────────────────────────
class _ProgressHeader extends StatelessWidget {
  final int done;
  final int total;
  final double pct;
  final bool isDark;

  const _ProgressHeader({
    required this.done,
    required this.total,
    required this.pct,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                done == total && total > 0
                    ? '✅ Semua dzikir selesai!'
                    : 'Progress Hari Ini',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: done == total && total > 0
                      ? AppColors.primary
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                '$done / $total',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 8,
              backgroundColor: isDark
                  ? AppColors.primarySoftDark
                  : AppColors.primarySoft,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Kartu per item dzikir ────────────────────────────────────────────────────
class _DzikirCard extends StatefulWidget {
  final DzikirItem item;
  final int current;
  final bool isDone;
  final bool isDark;
  final ColorScheme scheme;
  final VoidCallback onTap;
  final VoidCallback onReset;

  const _DzikirCard({
    required this.item,
    required this.current,
    required this.isDone,
    required this.isDark,
    required this.scheme,
    required this.onTap,
    required this.onReset,
  });

  @override
  State<_DzikirCard> createState() => _DzikirCardState();
}

class _DzikirCardState extends State<_DzikirCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final scheme = widget.scheme;
    final isDone = widget.isDone;
    final item = widget.item;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDone
            ? (widget.isDark ? AppColors.primarySoftDark : AppColors.primarySoft)
            : scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: isDone
            ? Border.all(color: AppColors.primary.withValues(alpha: 0.3))
            : null,
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: widget.isDark ? 0.3 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Arab text
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
            child: Text(
              item.arabic,
              style: GoogleFonts.scheherazadeNew(
                fontSize: 26,
                height: 2.0,
                color: isDone
                    ? AppColors.primary
                    : scheme.onSurface,
              ),
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
            ),
          ),

          // Latin / terjemahan expandable
          if (_expanded) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
              child: Text(
                item.latin,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: scheme.onSurfaceVariant,
                  height: 1.6,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
              child: Text(
                item.translation,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: scheme.onSurface,
                  height: 1.6,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.goldSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.star_rounded,
                        color: AppColors.gold, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item.fadhilah,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: const Color(0xFF7D5A00),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Footer: expand toggle, counter, tombol hitung
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              children: [
                // Toggle terjemahan
                InkWell(
                  onTap: () => setState(() => _expanded = !_expanded),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Row(
                      children: [
                        Icon(
                          _expanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          size: 18,
                          color: scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          _expanded ? 'Sembunyikan' : 'Terjemahan',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),

                // Reset
                if (widget.current > 0 && !isDone)
                  InkWell(
                    onTap: widget.onReset,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Icon(Icons.refresh_rounded,
                          size: 18, color: scheme.onSurfaceVariant),
                    ),
                  ),

                const SizedBox(width: 4),

                // Counter display + tombol
                GestureDetector(
                  onTap: isDone ? null : widget.onTap,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDone ? AppColors.primary : AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isDone)
                          const Icon(Icons.check_rounded,
                              color: Colors.white, size: 16)
                        else
                          Icon(Icons.add_rounded,
                              color: AppColors.primary, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          isDone
                              ? 'Selesai'
                              : '${widget.current}/${item.count}x',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDone ? Colors.white : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
