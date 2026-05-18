class ProjectImageAsset {
  const ProjectImageAsset({
    required this.id,
    required this.name,
    required this.path,
    this.mimeType,
  });

  final String id;
  final String name;
  final String path;
  final String? mimeType;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'mimeType': mimeType,
    };
  }

  factory ProjectImageAsset.fromJson(Map<String, Object?> json) {
    return ProjectImageAsset(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Untitled image',
      path: json['path'] as String? ?? '',
      mimeType: json['mimeType'] as String?,
    );
  }
}

class PortfolioProjectDraft {
  const PortfolioProjectDraft({
    this.id,
    this.name = '',
    this.shortDescription = '',
    this.bulletPoints = const [],
    this.images = const [],
    this.tools = const [],
    this.tags = const [],
    this.behanceUrl = '',
    this.figmaUrl = '',
    this.dribbbleUrl = '',
    this.clientName = '',
    this.createdAt,
    this.updatedAt,
  });

  final String? id;
  final String name;
  final String shortDescription;
  final List<String> bulletPoints;
  final List<ProjectImageAsset> images;
  final List<String> tools;
  final List<String> tags;
  final String behanceUrl;
  final String figmaUrl;
  final String dribbbleUrl;
  final String clientName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get hasLinks => behanceUrl.isNotEmpty || figmaUrl.isNotEmpty || dribbbleUrl.isNotEmpty;

  PortfolioProjectDraft copyWith({
    String? id,
    String? name,
    String? shortDescription,
    List<String>? bulletPoints,
    List<ProjectImageAsset>? images,
    List<String>? tools,
    List<String>? tags,
    String? behanceUrl,
    String? figmaUrl,
    String? dribbbleUrl,
    String? clientName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PortfolioProjectDraft(
      id: id ?? this.id,
      name: name ?? this.name,
      shortDescription: shortDescription ?? this.shortDescription,
      bulletPoints: bulletPoints ?? this.bulletPoints,
      images: images ?? this.images,
      tools: tools ?? this.tools,
      tags: tags ?? this.tags,
      behanceUrl: behanceUrl ?? this.behanceUrl,
      figmaUrl: figmaUrl ?? this.figmaUrl,
      dribbbleUrl: dribbbleUrl ?? this.dribbbleUrl,
      clientName: clientName ?? this.clientName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'name': name,
      'shortDescription': shortDescription,
      'bulletPoints': bulletPoints,
      'images': images.map((image) => image.toJson()).toList(),
      'tools': tools,
      'tags': tags,
      'behanceUrl': behanceUrl,
      'figmaUrl': figmaUrl,
      'dribbbleUrl': dribbbleUrl,
      'clientName': clientName,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory PortfolioProjectDraft.fromJson(Map<String, Object?> json) {
    return PortfolioProjectDraft(
      id: json['id'] as String?,
      name: json['name'] as String? ?? '',
      shortDescription: json['shortDescription'] as String? ?? '',
      bulletPoints: _stringList(json['bulletPoints']),
      images: (json['images'] as List<dynamic>? ?? [])
          .whereType<Map>()
          .map((image) => ProjectImageAsset.fromJson(image.cast<String, Object?>()))
          .toList(),
      tools: _stringList(json['tools']),
      tags: _stringList(json['tags']),
      behanceUrl: json['behanceUrl'] as String? ?? '',
      figmaUrl: json['figmaUrl'] as String? ?? '',
      dribbbleUrl: json['dribbbleUrl'] as String? ?? '',
      clientName: json['clientName'] as String? ?? '',
      createdAt: _date(json['createdAt']),
      updatedAt: _date(json['updatedAt']),
    );
  }

  static List<String> _stringList(Object? value) {
    return (value as List<dynamic>? ?? []).whereType<String>().toList();
  }

  static DateTime? _date(Object? value) {
    if (value is! String) return null;
    return DateTime.tryParse(value);
  }
}

class GeneratedPortfolioSection {
  const GeneratedPortfolioSection({
    required this.id,
    required this.title,
    required this.body,
    required this.kind,
  });

  final String id;
  final String title;
  final String body;
  final String kind;

  Map<String, Object?> toJson() {
    return {'id': id, 'title': title, 'body': body, 'kind': kind};
  }
}

class PortfolioData {
  const PortfolioData({
    required this.ownerName,
    required this.projects,
    this.generatedSections = const [],
  });

  final String ownerName;
  final List<PortfolioProjectDraft> projects;
  final List<GeneratedPortfolioSection> generatedSections;

  Map<String, Object?> toJson() {
    return {
      'ownerName': ownerName,
      'projects': projects.map((project) => project.toJson()).toList(),
      'generatedSections': generatedSections.map((section) => section.toJson()).toList(),
    };
  }
}

class AiProjectPromptPayload {
  const AiProjectPromptPayload({
    required this.project,
    required this.intent,
    required this.tone,
  });

  final PortfolioProjectDraft project;
  final String intent;
  final String tone;

  Map<String, Object?> toJson() {
    return {
      'intent': intent,
      'tone': tone,
      'project': project.toJson(),
      'imageCount': project.images.length,
      'proofPoints': project.bulletPoints,
      'tools': project.tools,
      'tags': project.tags,
    };
  }
}
