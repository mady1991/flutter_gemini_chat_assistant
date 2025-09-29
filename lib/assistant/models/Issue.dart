class Issue {
  final String id;
  final String category;
  final String title;
  final String scenario;
  final String rootCause;
  final String solution;
  final List<String> keywords;
  final List<String>? imageList;
  final String? action;


  Issue({
    required this.id,
    required this.category,
    required this.title,
    required this.scenario,
    required this.rootCause,
    required this.solution,
    required this.keywords,
    required this.imageList,
    required this.action,
  });
}

Map<String, List<Issue>> groupIssuesByCategory(List<Issue> issues) {
  final Map<String, List<Issue>> grouped = {};

  for (var issue in issues) {
    if (!grouped.containsKey(issue.category)) {
      grouped[issue.category] = [];
    }
    grouped[issue.category]!.add(issue);
  }

  return grouped;
}