class ProblemModel {
  final String id;
  final String title;
  final String description;
  final String difficulty;
  final int points;
  final int totalTestCases;
  final bool solved;
  final List<String> tags;
  final String slug;

  ProblemModel({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.points,
    required this.totalTestCases,
    required this.solved,
    required this.tags,
    required this.slug,
  });

  factory ProblemModel.fromJson(Map<String, dynamic> json) => ProblemModel(
        id: json['_id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        difficulty: json['difficulty']?.toString() ?? 'easy',
        points: json['points'] as int? ?? 0,
        totalTestCases: json['totalTestCases'] as int? ?? 0,
        solved: json['solved'] as bool? ?? false,
        tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        slug: json['slug']?.toString() ?? '',
      );
}

class ProblemPaginationModel {
  final int total;
  final int page;
  final int pages;
  final int limit;

  ProblemPaginationModel({
    required this.total,
    required this.page,
    required this.pages,
    required this.limit,
  });

  factory ProblemPaginationModel.fromJson(Map<String, dynamic> json) => ProblemPaginationModel(
        total: json['total'] as int? ?? 0,
        page: json['page'] as int? ?? 1,
        pages: json['pages'] as int? ?? 1,
        limit: json['limit'] as int? ?? 10,
      );
}

class ProblemResponseModel {
  final List<ProblemModel> problems;
  final ProblemPaginationModel pagination;

  ProblemResponseModel({
    required this.problems,
    required this.pagination,
  });
}

class ProblemDetailModel {
  final String id;
  final String title;
  final String difficulty;
  final String description;
  final List<String> constraints;
  final List<ProblemExampleModel> examples;
  final StarterCodeModel starterCode;
  final int points;
  final List<String> tags;
  final int timeLimit; // in ms
  final int memoryLimit; // in MB

  ProblemDetailModel({
    required this.id,
    required this.title,
    required this.difficulty,
    required this.description,
    required this.constraints,
    required this.examples,
    required this.starterCode,
    required this.points,
    required this.tags,
    required this.timeLimit,
    required this.memoryLimit,
  });

  factory ProblemDetailModel.fromJson(Map<String, dynamic> json) {
    // Treat the input directly as the data map. If a 'data' key exists, we can still fall back.
    final data = json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : json;

    // Handle constraints null-safely, supporting String (e.g. from backend) and List
    List<String> constraintsList = [];
    final rawConstraints = data['constraints'];
    if (rawConstraints is List) {
      constraintsList = rawConstraints.map((e) => e.toString()).toList();
    } else if (rawConstraints is String && rawConstraints.trim().isNotEmpty) {
      constraintsList = [rawConstraints.trim()];
    }

    // Defensive parsing for numbers
    final pointsVal = int.tryParse(data['points']?.toString() ?? '') ?? (data['points'] as num?)?.toInt() ?? 0;
    final timeLimitVal = int.tryParse(data['timeLimit']?.toString() ?? '') ?? (data['timeLimit'] as num?)?.toInt() ?? 1000;
    final memoryLimitVal = int.tryParse(data['memoryLimit']?.toString() ?? '') ?? (data['memoryLimit'] as num?)?.toInt() ?? 256;

    return ProblemDetailModel(
      id: data['_id']?.toString() ?? '',
      title: data['title']?.toString() ?? '',
      difficulty: data['difficulty']?.toString() ?? 'easy',
      description: data['description']?.toString() ?? '',
      constraints: constraintsList,
      examples: (data['examples'] as List<dynamic>?)
              ?.map((e) => ProblemExampleModel.fromJson(e as Map<String, dynamic>))
              .toList() ?? [],
      starterCode: StarterCodeModel.fromJson(data['starterCode'] as Map<String, dynamic>? ?? {}),
      points: pointsVal,
      tags: (data['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      timeLimit: timeLimitVal,
      memoryLimit: memoryLimitVal,
    );
  }
}

class ProblemExampleModel {
  final String input;
  final String output;
  final String? explanation;

  ProblemExampleModel({
    required this.input,
    required this.output,
    this.explanation,
  });

  factory ProblemExampleModel.fromJson(Map<String, dynamic> json) => ProblemExampleModel(
        input: json['input']?.toString() ?? '',
        output: json['output']?.toString() ?? '',
        explanation: json['explanation']?.toString(),
      );
}

class StarterCodeModel {
  final String javascript;
  final String python;
  final String java;

  StarterCodeModel({
    required this.javascript,
    required this.python,
    required this.java,
  });

  factory StarterCodeModel.fromJson(Map<String, dynamic> json) => StarterCodeModel(
        javascript: json['javascript']?.toString() ?? json['js']?.toString() ?? json['javascriptStarterCode']?.toString() ?? '',
        python: json['python']?.toString() ?? json['pythonStarterCode']?.toString() ?? '',
        java: json['java']?.toString() ?? json['javaStarterCode']?.toString() ?? '',
      );
}
