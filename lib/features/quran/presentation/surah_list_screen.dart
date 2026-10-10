import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/models/surah_model.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/uswah_refresh_indicator.dart';
import '../providers/quran_provider.dart';

class SurahListScreen extends ConsumerWidget {
  const SurahListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surahList = ref.watch(surahListProvider);

    return Scaffold(
      body: UswahRefreshIndicator(
        onRefresh: () async {
          await ref.refresh(surahListProvider.future).then((_) {});
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            SliverAppBar(
              expandedHeight: 110,
              pinned: true,
              centerTitle: true,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              title: Text(
                'Al-Quran',
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
                            Icons.menu_book_rounded,
                            size: 160,
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 24,
                        bottom: 12,
                        child: Icon(
                          Icons.auto_stories_rounded,
                          size: 44,
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ...surahList.when(
              skipLoadingOnRefresh: false,
              loading: () => [
                const SliverToBoxAdapter(child: _SurahListSkeleton()),
              ],
              error: (error, stackTrace) => [
                SliverFillRemaining(
                  child: ErrorView(
                    message: 'Gagal memuat data. Periksa koneksi internet Anda.',
                    onRetry: () => ref.invalidate(surahListProvider),
                  ),
                ),
              ],
              data: (surahs) => [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index == 0) {
                          return _QuranHeaderCard(
                            surahs: surahs.cast<SurahModel>(),
                          );
                        }
                        final surah = surahs[index - 1];
                        final isMeccan = surah.revelationType == 'Meccan';
                        return _SurahTile(
                          surah: surah,
                          isMeccan: isMeccan,
                          isLast: index == surahs.length,
                        );
                      },
                      childCount: surahs.length + 1,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuranHeaderCard extends StatelessWidget {
  final List<SurahModel> surahs;

  const _QuranHeaderCard({required this.surahs});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalAyah = surahs.fold<int>(
      0,
      (sum, s) => sum + s.numberOfAyahs,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: isDark ? 0.45 : 0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -16,
            bottom: -26,
            child: Icon(
              Icons.menu_book_rounded,
              size: 156,
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.auto_stories_rounded,
                      color: AppColors.secondaryBright,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Al-Quran Al-Karim',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Baca, dengarkan & pelajari firman Allah',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    _HeaderStat(
                      value: '${surahs.length}',
                      label: 'Surah',
                    ),
                    _headerDivider(),
                    _HeaderStat(value: '$totalAyah', label: 'Ayat'),
                    _headerDivider(),
                    const _HeaderStat(
                      value: '30',
                      label: 'Juz',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerDivider() {
    return Container(
      width: 1,
      height: 30,
      color: Colors.white.withValues(alpha: 0.25),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  final String value;
  final String label;

  const _HeaderStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              color: AppColors.secondaryBright,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _SurahTile extends StatelessWidget {
  final dynamic surah;
  final bool isMeccan;
  final bool isLast;

  const _SurahTile({
    required this.surah,
    required this.isMeccan,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chipColor = isMeccan
        ? (isDark ? AppColors.primarySoftDark : AppColors.primarySoft)
        : (isDark ? AppColors.secondarySoftDark : AppColors.secondarySoft);
    final chipText = isMeccan
        ? (isDark ? AppColors.primaryBright : AppColors.primary)
        : (isDark ? AppColors.secondaryBright : AppColors.secondary);

    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 10),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.push(
            '/quran/${surah.number}?name=${Uri.encodeQueryComponent(surah.englishName)}&arabic=${Uri.encodeQueryComponent(surah.name)}',
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                _SurahNumberBadge(number: surah.number),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        surah.englishName,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              surah.englishNameTranslation,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: chipColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isMeccan ? 'Makkiyah' : 'Madaniyah',
                              style: GoogleFonts.poppins(
                                fontSize: 9,
                                color: chipText,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${surah.numberOfAyahs} Ayat',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: scheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  surah.name,
                  style: GoogleFonts.scheherazadeNew(
                    fontSize: 26,
                    color: context.primaryAccent,
                    fontWeight: FontWeight.w600,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.chevron_right_rounded,
                  color: scheme.outline,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SurahNumberBadge extends StatelessWidget {
  final int number;
  const _SurahNumberBadge({required this.number});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '$number',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _SurahListSkeleton extends StatelessWidget {
  const _SurahListSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        const _ShimmerBox(height: 168, radius: 24),
        const SizedBox(height: 18),
        for (var i = 0; i < 9; i++) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              children: [
                _ShimmerBox(width: 40, height: 40, radius: 20),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ShimmerBox(height: 15, radius: 8),
                      SizedBox(height: 8),
                      _ShimmerBox(width: 110, height: 11, radius: 8),
                    ],
                  ),
                ),
                SizedBox(width: 10),
                _ShimmerBox(width: 44, height: 26, radius: 8),
                SizedBox(width: 6),
                Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

/// Kotak gradient yang beranimasi menyerupai efek shimmer.
class _ShimmerBox extends StatefulWidget {
  final double? width;
  final double height;
  final double radius;

  const _ShimmerBox({this.width, required this.height, required this.radius});

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final base = scheme.surfaceContainerHighest;
    final highlight = scheme.surfaceContainerHigh.withValues(alpha: 0.9);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(-1.5 + 3 * t, 0),
              end: Alignment(-0.5 + 3 * t, 0),
              colors: [base, highlight, base],
              stops: const [0.2, 0.5, 0.8],
            ),
          ),
        );
      },
    );
  }
}
