import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

class SeatingLayoutDisplay extends StatelessWidget {
  final Map<String, dynamic>? seatLayoutData;
  final int capacity;

  const SeatingLayoutDisplay({
    super.key,
    required this.seatLayoutData,
    required this.capacity,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (seatLayoutData == null || seatLayoutData!['seats'] == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: cs.outline.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(Icons.event_seat, color: cs.primary, size: 48),
            const SizedBox(height: 8),
            Text(
              'No seating layout configured',
              style: TextStyle(
                fontSize: 16,
                color: cs.onSurface.withOpacity(0.6),
              ),
            ),
            Text(
              'Capacity: $capacity seats',
              style: TextStyle(
                fontSize: 14,
                color: cs.onSurface.withOpacity(0.8),
              ),
            ),
          ],
        ),
      );
    }

    final seats = seatLayoutData!['seats'] as List<dynamic>;
    final rows = seatLayoutData!['rows'] as int? ?? 5;
    final columns = seatLayoutData!['columns'] as int? ?? 4;
    final driverSide = seatLayoutData!['driverSide'] as String? ?? 'Right';

    final List<Widget> rowWidgets = [];

    // Driver seat
    rowWidgets.add(
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          mainAxisAlignment: driverSide == 'Left'
              ? MainAxisAlignment.start
              : MainAxisAlignment.end,
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: driverSide == 'Left' ? 35 : 0,
                right: driverSide == 'Right' ? 35 : 0,
              ),
              child: Icon(Icons.event_seat, color: cs.primary, size: 40),
            ),
          ],
        ),
      ),
    );

    int seatIndex = 0;
    for (int r = 0; r < rows; r++) {
      final List<Widget> seatRow = [];
      final currentCols = columns; // Simplified - assuming uniform rows

      for (int c = currentCols - 1; c >= 0; c--) {
        if (seatIndex >= seats.length) break;

        final seat = seats[seatIndex] as Map<String, dynamic>;
        final number = seat['number'] as int? ?? 0;
        final removed = seat['removed'] as bool? ?? false;

        seatRow.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Container(
              width: 40,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: removed ? cs.surfaceVariant : cs.surface,
                border: Border.all(
                  color: removed ? cs.outlineVariant : cs.primary,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                number.toString(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: removed
                      ? cs.onSurface.withOpacity(0.5)
                      : cs.onSurface,
                ),
              ),
            ),
          ),
        );
        seatIndex++;
      }

      rowWidgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: seatRow,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.outline.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.event_seat, color: cs.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                'Seating Layout',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Total Seats: ${seats.where((s) => !(s['removed'] as bool? ?? false)).length}',
            style: TextStyle(
              fontSize: 14,
              color: cs.onSurface.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              children: rowWidgets,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: cs.surface,
                  border: Border.all(color: cs.primary),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'Available',
                style: TextStyle(
                  fontSize: 12,
                  color: cs.onSurface.withOpacity(0.8),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: cs.surfaceVariant,
                  border: Border.all(color: cs.outlineVariant),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'Removed',
                style: TextStyle(
                  fontSize: 12,
                  color: cs.onSurface.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
