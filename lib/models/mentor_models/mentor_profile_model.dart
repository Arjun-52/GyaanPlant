class Mentor {
  final String name;
  final String role;
  final double rating;
  final int sessions;
  final List<String> expertise;
  final Map<String, List<String>> availability;

  Mentor({
    required this.name,
    required this.role,
    required this.rating,
    required this.sessions,
    required this.expertise,
    required this.availability,
  });
}
