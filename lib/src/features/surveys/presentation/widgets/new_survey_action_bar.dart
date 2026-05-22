import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';

class NewSurveyActionBar extends StatelessWidget {
  const NewSurveyActionBar({
    required this.onReset,
    required this.onSubmit,
    this.isSaving = false,
    super.key,
  });

  final VoidCallback onReset;
  final VoidCallback onSubmit;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final submitIcon = isSaving
        ? SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colorScheme.onPrimary,
            ),
          )
        : const Icon(Icons.check);

    return Material(
      color: colorScheme.surface,
      elevation: 3,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.72),
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          minimum: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isSaving ? null : onReset,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: isSaving ? null : onSubmit,
                  icon: submitIcon,
                  label: Text(isSaving ? 'Saving...' : 'Save survey'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
