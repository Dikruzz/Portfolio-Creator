import 'package:flutter/material.dart';

import '../responsive/responsive_layout.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class PremiumScaffold extends StatelessWidget {
  const PremiumScaffold({
    required this.child,
    this.title,
    this.actions = const [],
    super.key,
  });

  final Widget child;
  final String? title;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: title == null
          ? null
          : AppBar(
              title: Text(title!),
              actions: actions,
            ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.1,
            colors: [Color(0x332C5BFF), AppColors.ink],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: MaxWidthContainer(child: child),
          ),
        ),
      ),
    );
  }
}
