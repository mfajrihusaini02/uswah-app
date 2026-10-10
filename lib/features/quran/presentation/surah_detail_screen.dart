import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/empty_view.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../data/quran_repository.dart';

class SurahDetailScreen extends ConsumerStatefulWidget {
  final int surahNumber;
  final String? surahName;
  final String? surahArabic;

  const SurahDetailScreen({
    super.key,
    required this.surahNumber,
    this.surahName,
    this.surahArabic,
  });

  @override
  ConsumerState<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends ConsumerState<SurahDetailScreen> {
  late final QuranRepository _repository;
  late Future<List<dynamic>> _ayahsFuture;

  @override
  void initState() {
    super.initState();
    _repository = QuranRepository(Dio());
    _ayahsFuture = _repository.getSurahDetail(widget.surahNumber);
  }

  @override
  Widget build(BuildContext context) {
    final surahTitle = widget.surahName ?? 'Surah ${widget.surahNumber}';

    return Scaffold(
      body: CustomScrollView(
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
              surahTitle,
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
                    if (widget.surahArabic != null &&
                        widget.surahArabic!.isNotEmpty)
                      Positioned(
                        right: 12,
                        bottom: -6,
                        child: Text(
                          widget.surahArabic!,
                          style: GoogleFonts.scheherazadeNew(
                            fontSize: 72,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withValues(alpha: 0.18),
                            height: 1.0,
                          ),
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                        ),
                      )
                    else
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
                        Icons.menu_book_outlined,
                        size: 44,
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          FutureBuilder<List<dynamic>>(
            future: _ayahsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: LoadingView(message: 'Memuat ayat...'),
                );
              }

              if (snapshot.hasError) {
                return SliverFillRemaining(
                  child: ErrorView(
                    message: 'Gagal memuat ayat-ayat. Periksa koneksi internet.',
                    onRetry: () {
                      setState(() {
                        _ayahsFuture = _repository
                            .getSurahDetail(widget.surahNumber);
                      });
                    },
                  ),
                );
              }

              final ayahs = snapshot.data ?? [];
              if (ayahs.isEmpty) {
                return const SliverFillRemaining(
                  child: EmptyView(
                    message: 'Ayat tidak ditemukan',
                    icon: Icons.menu_book_rounded,
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final ayah = ayahs[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _AyahCard(
                          number: index + 1,
                          text: ayah.text,
                          juz: ayah.juz,
                          page: ayah.page,
                        ),
                      );
                    },
                    childCount: ayahs.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AyahCard extends StatelessWidget {
  final int number;
  final String text;
  final int juz;
  final int page;

  const _AyahCard({
    required this.number,
    required this.text,
    required this.juz,
    required this.page,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: isDark ? 0.35 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _AyahNumberBadge(number: number),
              Text(
                'Juz $juz • Hal. $page',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            text,
            style: GoogleFonts.scheherazadeNew(
              fontSize: 28,
              height: 1.9,
              color: scheme.onSurface,
            ),
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }
}

class _AyahNumberBadge extends StatelessWidget {
  final int number;
  const _AyahNumberBadge({required this.number});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
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
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
