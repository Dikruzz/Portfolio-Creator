import 'package:flutter/material.dart';

class OnboardingPageData {
  const OnboardingPageData({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.icon,
    required this.gradient,
  });

  final String eyebrow;
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradient;
}

class SelectionOption {
  const SelectionOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
}

const cinematicOnboardingPages = [
  OnboardingPageData(
    eyebrow: 'Act I · Positioning',
    title: 'Build a portfolio that feels like a private studio.',
    description: 'Portique starts by understanding your craft, audience, and ambition before shaping every page.',
    icon: Icons.auto_awesome_rounded,
    gradient: [Color(0xFF7C5CFF), Color(0xFFD9B56D)],
  ),
  OnboardingPageData(
    eyebrow: 'Act II · Narrative',
    title: 'Turn scattered wins into a cinematic career story.',
    description: 'Move step by step through prompts that transform projects into crisp case studies and proof points.',
    icon: Icons.movie_filter_rounded,
    gradient: [Color(0xFF38D6A3), Color(0xFF7C5CFF)],
  ),
  OnboardingPageData(
    eyebrow: 'Act III · Launch',
    title: 'Leave with a premium portfolio system ready to evolve.',
    description: 'Your choices tune the dashboard, AI prompts, and visual defaults so Portique feels made for you.',
    icon: Icons.rocket_launch_rounded,
    gradient: [Color(0xFFFF6B9A), Color(0xFFD9B56D)],
  ),
];

const professionOptions = [
  SelectionOption(
    id: 'designer',
    title: 'Designer',
    subtitle: 'Brand, product, UX, or visual systems.',
    icon: Icons.palette_rounded,
  ),
  SelectionOption(
    id: 'developer',
    title: 'Developer',
    subtitle: 'Apps, platforms, prototypes, and tools.',
    icon: Icons.code_rounded,
  ),
  SelectionOption(
    id: 'marketer',
    title: 'Marketer',
    subtitle: 'Campaigns, growth stories, and content.',
    icon: Icons.campaign_rounded,
  ),
  SelectionOption(
    id: 'founder',
    title: 'Founder',
    subtitle: 'Ventures, launches, traction, and vision.',
    icon: Icons.diamond_rounded,
  ),
];

const styleOptions = [
  SelectionOption(
    id: 'editorial',
    title: 'Editorial',
    subtitle: 'Refined layouts, sharp typography, quiet luxury.',
    icon: Icons.article_rounded,
  ),
  SelectionOption(
    id: 'bold',
    title: 'Bold',
    subtitle: 'High contrast, strong motion, memorable moments.',
    icon: Icons.bolt_rounded,
  ),
  SelectionOption(
    id: 'minimal',
    title: 'Minimal',
    subtitle: 'Whitespace, clarity, and a focused reading path.',
    icon: Icons.blur_on_rounded,
  ),
  SelectionOption(
    id: 'cinematic',
    title: 'Cinematic',
    subtitle: 'Atmospheric gradients with story-led reveals.',
    icon: Icons.local_movies_rounded,
  ),
];
