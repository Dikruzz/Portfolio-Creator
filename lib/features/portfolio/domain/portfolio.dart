class PortfolioProject {
  const PortfolioProject({
    required this.title,
    required this.role,
    required this.summary,
    required this.impact,
  });

  final String title;
  final String role;
  final String summary;
  final String impact;
}

class PortfolioProfile {
  const PortfolioProfile({
    required this.name,
    required this.positioning,
    required this.projects,
    required this.skills,
  });

  final String name;
  final String positioning;
  final List<PortfolioProject> projects;
  final List<String> skills;
}
