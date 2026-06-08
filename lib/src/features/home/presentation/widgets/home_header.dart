import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/surveyor_logo.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SurveyorLogo(
          layout: SurveyorLogoLayout.full,
          height: 34,
          iconHeight: 40,
          gap: AppSpacing.sm,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Road survey workspace for field engineers',
          style: AppTextStyles.muted(context),
        ),
      ],
    );
  }
}
