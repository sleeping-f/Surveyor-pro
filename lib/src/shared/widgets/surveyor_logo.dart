import 'package:flutter/material.dart';

enum SurveyorLogoLayout {
  icon,
  wordmark,
  full,
}

class SurveyorLogo extends StatelessWidget {
  const SurveyorLogo({
    this.layout = SurveyorLogoLayout.full,
    this.height = 28.0,
    this.iconHeight,
    this.gap = 10.0,
    super.key,
  });

  final SurveyorLogoLayout layout;
  final double height;
  final double? iconHeight;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final iconAsset = isDark
        ? 'assets/branding/surveyor_mark_dark.png'
        : 'assets/branding/surveyor_mark_light.png';
    final wordmarkAsset = isDark
        ? 'assets/branding/surveyor_wordmark_dark.png'
        : 'assets/branding/surveyor_wordmark_light.png';

    switch (layout) {
      case SurveyorLogoLayout.icon:
        return _LogoImage(
          assetPath: iconAsset,
          height: height,
          semanticLabel: 'Surveyor Pro logo',
        );
      case SurveyorLogoLayout.wordmark:
        return _LogoImage(
          assetPath: wordmarkAsset,
          height: height,
          semanticLabel: 'Surveyor Pro wordmark',
        );
      case SurveyorLogoLayout.full:
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _LogoImage(
              assetPath: iconAsset,
              height: iconHeight ?? height,
              semanticLabel: 'Surveyor Pro logo',
            ),
            SizedBox(width: gap),
            Flexible(
              child: _LogoImage(
                assetPath: wordmarkAsset,
                height: height,
                semanticLabel: 'Surveyor Pro wordmark',
              ),
            ),
          ],
        );
    }
  }
}

class _LogoImage extends StatelessWidget {
  const _LogoImage({
    required this.assetPath,
    required this.height,
    required this.semanticLabel,
  });

  final String assetPath;
  final double height;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      child: Image.asset(
        assetPath,
        height: height,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Text(
            'Surveyor Pro',
            style: Theme.of(context).textTheme.titleMedium,
          );
        },
      ),
    );
  }
}
