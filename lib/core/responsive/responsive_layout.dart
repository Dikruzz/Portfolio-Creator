import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import 'breakpoints.dart';

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    required this.mobile,
    this.tablet,
    this.desktop,
    super.key,
  });

  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  @override
  Widget build(BuildContext context) {
    return switch (Breakpoints.of(context)) {
      DeviceClass.desktop => desktop ?? tablet ?? mobile,
      DeviceClass.tablet => tablet ?? mobile,
      DeviceClass.mobile => mobile,
    };
  }
}

class MaxWidthContainer extends StatelessWidget {
  const MaxWidthContainer({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
        child: child,
      ),
    );
  }
}
