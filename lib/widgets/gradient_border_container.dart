import 'package:flutter/material.dart';
import '../theme/theme.dart';

class GradientBorderContainer extends StatelessWidget {
  final Widget child;
  final double borderWidth;
  final double borderRadius;

  const GradientBorderContainer({
    super.key,
    required this.child,
    this.borderWidth = 1.6,
    this.borderRadius = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(borderWidth),
      decoration: BoxDecoration(
        gradient: AppGradients.primary,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(borderRadius - borderWidth),
        ),
        child: child,
      ),
    );
  }
}
