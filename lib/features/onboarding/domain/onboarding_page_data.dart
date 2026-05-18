class OnboardingPageData {
  const OnboardingPageData({
    required this.title,
    required this.description,
    required this.metric,
  });

  final String title;
  final String description;
  final String metric;
}

const onboardingPages = [
  OnboardingPageData(
    title: 'Craft a portfolio that feels bespoke.',
    description: 'Portique turns your experience, projects, and ambition into a polished narrative.',
    metric: '01 Strategy',
  ),
  OnboardingPageData(
    title: 'Use AI to sharpen every case study.',
    description: 'Generate summaries, impact bullets, and positioning that sound premium and human.',
    metric: '02 Intelligence',
  ),
  OnboardingPageData(
    title: 'Publish a cohesive digital presence.',
    description: 'Organize work, skills, testimonials, and goals from one elegant command center.',
    metric: '03 Launch',
  ),
];
