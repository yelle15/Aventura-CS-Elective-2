import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.quantity,
    required this.max,
    required this.onChanged,
    this.min = 1,
  });

  final int quantity;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.isDark(context)
            ? AppTheme.backgroundSecondary
            : AppTheme.lightPanel,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppTheme.outline(context)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(
            tooltip: 'Decrease quantity',
            icon: Icons.remove_rounded,
            filled: false,
            onPressed: quantity > min ? () => onChanged(quantity - 1) : null,
          ),
          SizedBox(
            width: 34,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
            ),
          ),
          _StepButton(
            tooltip: 'Increase quantity',
            icon: Icons.add_rounded,
            filled: true,
            onPressed: quantity < max ? () => onChanged(quantity + 1) : null,
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.tooltip,
    required this.icon,
    required this.filled,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final bool filled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      style: IconButton.styleFrom(
        fixedSize: const Size(34, 34),
        minimumSize: const Size(34, 34),
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        backgroundColor: filled ? AppTheme.red : AppTheme.panel(context),
        foregroundColor: filled ? Colors.white : onSurface,
        disabledBackgroundColor:
            filled ? AppTheme.red.withAlpha(60) : AppTheme.panel(context),
        disabledForegroundColor: onSurface.withAlpha(90),
        side: filled ? null : BorderSide(color: AppTheme.outline(context)),
      ),
    );
  }
}
