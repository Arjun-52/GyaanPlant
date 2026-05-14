class Report {
  final String title;
  final String subtitle;
  final String icon;
  final bool isPrimary; // for NAAC main card

  Report({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.isPrimary = false,
  });
}
