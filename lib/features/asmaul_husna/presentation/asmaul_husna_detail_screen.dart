import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/empty_view.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../providers/asmaul_husna_provider.dart';

class AsmaulHusnaDetailScreen extends ConsumerWidget {
  final int index;

  const AsmaulHusnaDetailScreen({super.key, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asmaulHusna = ref.watch(asmaulHusnaProvider);

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
              'Detail Asmaul Husna',
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
                          Icons.spa_rounded,
                          size: 160,
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 24,
                      bottom: 12,
                      child: Icon(
                        Icons.star_rounded,
                        size: 44,
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ...asmaulHusna.when(
            loading: () => [
              const SliverFillRemaining(
                child: LoadingView(message: 'Memuat detail...'),
              ),
            ],
            error: (error, stackTrace) => [
              SliverFillRemaining(
                child: ErrorView(
                  message: 'Gagal memuat data. Periksa koneksi internet Anda.',
                  onRetry: () => ref.invalidate(asmaulHusnaProvider),
                ),
              ),
            ],
            data: (list) {
              if (list.isEmpty || index >= list.length) {
                return [
                  const SliverFillRemaining(
                    child: EmptyView(
                      message: 'Data tidak ditemukan',
                      icon: Icons.spa_rounded,
                    ),
                  ),
                ];
              }
              final asma = list[index];
              final prevIndex = index - 1;
              final nextIndex = index + 1;
              final hasPrev = prevIndex >= 0;
              final hasNext = nextIndex < list.length;

              return [
                SliverPadding(
                  padding: const EdgeInsets.all(24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _NumberCircle(number: asma.number),
                      const SizedBox(height: 28),
                      Text(
                        asma.arabic,
                        style: GoogleFonts.scheherazadeNew(
                          fontSize: 52,
                          fontWeight: FontWeight.w600,
                          color: context.primaryAccent,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        asma.name,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _MeaningCard(meaning: asma.meaning),
                      const SizedBox(height: 14),
                      const _HadithCard(),
                      if (hasPrev || hasNext) ...[
                        const SizedBox(height: 20),
                        _PaginationBar(
                          hasPrev: hasPrev,
                          hasNext: hasNext,
                          currentNumber: asma.number,
                          total: list.length,
                          onPrev: () => context.pushReplacement(
                            '/asmaul-husna/$prevIndex',
                          ),
                          onNext: () => context.pushReplacement(
                            '/asmaul-husna/$nextIndex',
                          ),
                        ),
                      ],
                    ]),
                  ),
                ),
              ];
            },
          ),
        ],
      ),
    );
  }
}

class _NumberCircle extends StatelessWidget {
  final int number;
  const _NumberCircle({required this.number});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '$number',
          style: GoogleFonts.poppins(
            fontSize: 34,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _MeaningCard extends StatelessWidget {
  final String meaning;
  const _MeaningCard({required this.meaning});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.translate_rounded,
                  color: scheme.onPrimaryContainer, size: 18),
              const SizedBox(width: 6),
              Text(
                'Arti Nama',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: scheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            meaning,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 17,
              height: 1.5,
              color: scheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _HadithCard extends StatelessWidget {
  const _HadithCard();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.format_quote_rounded,
                  color: scheme.onSecondaryContainer, size: 18),
              const SizedBox(width: 6),
              Text(
                'Keutamaan',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: scheme.onSecondaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '"Barangsiapa menghafal Asmaul Husna, maka ia akan masuk surga."',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              height: 1.5,
              color: scheme.onSurface,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'HR. Bukhari',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaginationBar extends StatelessWidget {
  final bool hasPrev;
  final bool hasNext;
  final int currentNumber;
  final int total;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _PaginationBar({
    required this.hasPrev,
    required this.hasNext,
    required this.currentNumber,
    required this.total,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        OutlinedButton(
          onPressed: hasPrev ? onPrev : null,
          style: OutlinedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(12),
            minimumSize: const Size(48, 48),
          ),
          child: const Icon(Icons.chevron_left_rounded),
        ),
        Text(
          '$currentNumber dari $total',
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        OutlinedButton(
          onPressed: hasNext ? onNext : null,
          style: OutlinedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(12),
            minimumSize: const Size(48, 48),
          ),
          child: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    );
  }
}
