// data.dart

class Seat {
  int number;
  bool removed;

  Seat({required this.number, this.removed = false});

  Map<String, dynamic> toJson() => {'number': number, 'removed': removed};
}
