import 'package:flutter/material.dart';

import '../../../app/app_routes.dart';
import '../../../core/app_info/infrastructure/package_info_app_info_service.dart';
import '../../../core/constants/app_spacing.dart';
import '../application/home_metrics_controller.dart';
import 'widgets/app_info_sheet.dart';
import 'widgets/home_header.dart';
import 'widgets/hero_camera_card.dart';
import 'widgets/photo_stats_bar.dart';
import 'widgets/secondary_action_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.onGalleryPressed,
    super.key,
  });

  final VoidCallback onGalleryPressed;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeMetricsController _metricsController;
  late final PackageInfoAppInfoService _appInfoService;

  @override
  void initState() {
    super.initState();
    _metricsController = HomeMetricsController()..load();
    _appInfoService = PackageInfoAppInfoService();
  }

  @override
  void dispose() {
    _metricsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding =
              AppSpacing.pagePaddingFor(constraints.maxWidth);

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              AppSpacing.lg,
              horizontalPadding,
              AppSpacing.xl,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppSpacing.maxContentWidth,
                ),
                child: AnimatedBuilder(
                  animation: _metricsController,
                  builder: (context, _) {
                    final state = _metricsController.state;
                    // Note: Until HomeMetricsController is simplified, we use storedImages
                    // as the proxy for total photos.
                    final photoCount = state.metrics.storedImages;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const HomeHeader(),
                        const SizedBox(height: AppSpacing.xl),
                        HeroCameraCard(
                          onTap: () => _openQuickCamera(context),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        PhotoStatsBar(photoCount: photoCount),
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          'More',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isWide = constraints.maxWidth >= 600;
                            final children = [
                              SecondaryActionCard(
                                title: 'Photo Gallery',
                                subtitle: 'View your captured photos',
                                icon: Icons.photo_library_outlined,
                                onTap: widget.onGalleryPressed,
                              ),
                              SecondaryActionCard(
                                title: 'About Surveyor Pro',
                                subtitle: 'Version info and details',
                                icon: Icons.info_outline,
                                onTap: () => _showAppInfo(context),
                              ),
                            ];

                            if (isWide) {
                              return Row(
                                children: [
                                  Expanded(child: children[0]),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(child: children[1]),
                                ],
                              );
                            }

                            return Column(
                              children: [
                                children[0],
                                const SizedBox(height: AppSpacing.sm),
                                children[1],
                              ],
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _openQuickCamera(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.quickCamera);
  }

  Future<void> _showAppInfo(BuildContext context) async {
    final appInfo = await _appInfoService.load();

    if (!mounted) {
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => AppInfoSheet(appInfo: appInfo),
    );
  }
}

