import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/models/asmaul_husna_model.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/uswah_refresh_indicator.dart';
import '../providers/asmaul_husna_provider.dart';

class AsmaulHusnaScreen extends ConsumerWidget {
  const AsmaulHusnaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asmaulHusna = ref.watch(asmaulHusnaProvider);

    return Scaffold(
      body: UswahRefreshIndicator(
        onRefresh: () async {
          await ref.refresh(asmaulHusnaProvider.future).then((_) {});
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
                'Asmaul Husna',
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
              skipLoadingOnRefresh: false,
              loading: () => [
                const SliverToBoxAdapter(child: _AsmaListSkeleton()),
              ],
              error: (error, stackTrace) => [
                SliverFillRemaining(
                  child: ErrorView(
                    message: 'Gagal memuat data. Pastikan terhubung ke internet.',
                    onRetry: () => ref.invalidate(asmaulHusnaProvider),
                  ),
                ),
              ],
              data: (list) => [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index == 0) {
                          return _AsmaHeaderCard(
                            list: list.cast<AsmaulHusnaModel>(),
                          );
                        }
                        final asma = list[index - 1];
                        return _AsmaTile(
                          asma: asma,
                          isLast: index == list.length,
                        );
                      },
                      childCount: list.length + 1,
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

class _AsmaHeaderCard extends StatelessWidget {
  final List<AsmaulHusnaModel> list;

  const _AsmaHeaderCard({required this.list});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.gold, AppColors.secondaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: isDark ? 0.45 : 0.3),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -14,
            bottom: -28,
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 150,
              color: Colors.white.withValues(alpha: 0.16),
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
                      Icons.spa_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Asmaul Husna',
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
                  '99 nama Allah yang indah & mulia',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withValues(alpha: 0.92),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'الْأَسْمَاءُ الْحُسْنَى',
                  style: GoogleFonts.scheherazadeNew(
                    color: Colors.white,
                    fontSize: 22,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 16),
                _HeaderStat(
                  value: '${list.length}',
                  label: 'Nama Allah',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  final String value;
  final String label;

  const _HeaderStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.92),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _AsmaTile extends StatelessWidget {
  final dynamic asma;
  final bool isLast;

  const _AsmaTile({required this.asma, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
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
          onTap: () => context.push('/asmaul-husna/${asma.number - 1}'),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                _AsmaNumberBadge(number: asma.number),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        asma.name,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        asma.meaning,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  asma.arabic,
                  style: GoogleFonts.scheherazadeNew(
                    fontSize: 24,
                    color: context.secondaryAccent,
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

class _AsmaNumberBadge extends StatelessWidget {
  final int number;
  const _AsmaNumberBadge({required this.number});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [AppColors.gold, AppColors.secondaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.3),
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
            color: AppColors.primaryDark,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _AsmaListSkeleton extends StatelessWidget {
  const _AsmaListSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        const _ShimmerBox(height: 180, radius: 24),
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
                      _ShimmerBox(width: 150, height: 11, radius: 8),
                    ],
                  ),
                ),
                SizedBox(width: 10),
                _ShimmerBox(width: 40, height: 26, radius: 8),
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
