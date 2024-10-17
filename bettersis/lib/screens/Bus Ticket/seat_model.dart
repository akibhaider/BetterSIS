class Seat {
  final String id;
  bool isAvailable;
  bool isSelected;
  bool isOccupied;

  Seat({
    required this.id,
    this.isAvailable = true,
    this.isSelected = false,
    this.isOccupied = false,
  });
}
