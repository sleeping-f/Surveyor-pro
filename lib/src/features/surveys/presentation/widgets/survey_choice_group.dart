import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class SurveyChoiceOption<T> {
  const SurveyChoiceOption({
    required this.value,
    required this.label,
    this.icon,
  });

  final T value;
  final String label;
  final IconData? icon;
}

class SurveyChoiceGroup<T> extends FormField<T> {
  SurveyChoiceGroup({
    required String label,
    required List<SurveyChoiceOption<T>> options,
    required ValueChanged<T?> onChanged,
    super.initialValue,
    super.validator,
    super.key,
  }) : super(
          builder: (field) {
            final context = field.context;
            final colorScheme = Theme.of(context).colorScheme;
            final errorText = field.errorText;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columnCount =
                        constraints.maxWidth < 340 ? 1 : options.length;
                    final spacing = columnCount == 1
                        ? 0
                        : AppSpacing.sm * (columnCount - 1);
                    final itemWidth =
                        (constraints.maxWidth - spacing) / columnCount;

                    return Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        for (final option in options)
                          SizedBox(
                            width: itemWidth,
                            child: _SurveyChoiceTile<T>(
                              option: option,
                              selected: field.value == option.value,
                              hasError: errorText != null,
                              onTap: () {
                                field.didChange(option.value);
                                onChanged(option.value);
                              },
                            ),
                          ),
                      ],
                    );
                  },
                ),
                if (errorText != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    errorText,
                    style: AppTextStyles.muted(context).copyWith(
                      color: colorScheme.error,
                    ),
                  ),
                ],
              ],
            );
          },
        );
}

class _SurveyChoiceTile<T> extends StatelessWidget {
  const _SurveyChoiceTile({
    required this.option,
    required this.selected,
    required this.hasError,
    required this.onTap,
  });

  final SurveyChoiceOption<T> option;
  final bool selected;
  final bool hasError;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foregroundColor =
        selected ? colorScheme.onPrimaryContainer : colorScheme.onSurface;
    final borderColor = hasError
        ? colorScheme.error
        : selected
            ? colorScheme.primary
            : colorScheme.outlineVariant;

    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected
            ? colorScheme.primaryContainer
            : colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.radius,
          side: BorderSide(
            color: borderColor,
            width: selected ? 1.4 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: 56,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (option.icon != null) ...[
                    Icon(
                      option.icon,
                      size: 20,
                      color: foregroundColor,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                  ],
                  Flexible(
                    child: Text(
                      option.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                            color: foregroundColor,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
