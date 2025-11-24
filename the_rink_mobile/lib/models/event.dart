class Event {
  final String id;
  final String title;
  final String description;
  final String date;
  final String imageIcon;
  final bool isFeatured;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.imageIcon,
    this.isFeatured = false,
  });
}
