import 'package:flutter/material.dart';
import 'package:youbook/core/theme/app_colors.dart';
import 'package:youbook/features/services_details/bus_details/bus_seatlayout/Logic/bus_seatlayout_logic.dart';
import '../Data/bus_seatlayout_data.dart';

class BusSeatLayoutViewScreen extends StatefulWidget {
  const BusSeatLayoutViewScreen({super.key});

  @override
  State<BusSeatLayoutViewScreen> createState() =>
      _BusSeatLayoutViewScreenState();
}

class _BusSeatLayoutViewScreenState extends State<BusSeatLayoutViewScreen> {
  final SeatLayoutLogic _logic = SeatLayoutLogic();

  @override
  void initState() {
    super.initState();
    // Create a default layout for viewing
    _logic.rows = 4;
    _logic.columns = 8; // Reduced columns to prevent overflow
    _logic.useLastRowOverride = false;
    _logic.driverSide = 'Right';
    _logic.numberingMode = 'Auto';
    _logic.createSeatPlan(context, () => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(45),
        child: AppBar(
          elevation: 0,
          centerTitle: true,
          backgroundColor: cs.primary,
          title: Text(
            'Bus Seat Layout',
            style: TextStyle(color: cs.onPrimary, fontSize: 20),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: cs.onPrimary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Legend
              Card(
                color: cs.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Legend',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _legendItem(
                            cs,
                            cs.surface,
                            cs.primary,
                            'Available Seat',
                          ),
                          const SizedBox(width: 16),
                          _legendItem(
                            cs,
                            AppColors.error.withOpacity(0.2),
                            AppColors.error,
                            'Removed Seat',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Seat Layout
              Card(
                color: cs.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Seat Layout',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: cs.onSurface,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: cs.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${_logic.getTotalSeats()} seats',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: cs.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: _buildSeatLayout(cs),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Layout Info
              Card(
                color: cs.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Layout Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _infoRow(
                        'Total Seats',
                        _logic.getTotalSeats().toString(),
                      ),
                      _infoRow('Rows', _logic.rows.toString()),
                      _infoRow('Columns', _logic.columns.toString()),
                      if (_logic.useLastRowOverride)
                        _infoRow(
                          'Last Row Columns',
                          _logic.lastRowColumns.toString(),
                        ),
                      _infoRow('Driver Side', _logic.driverSide),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _legendItem(
    ColorScheme cs,
    Color bgColor,
    Color borderColor,
    String label,
  ) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(color: borderColor, width: 2),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(fontSize: 14, color: cs.onSurface)),
      ],
    );
  }

  Widget _buildSeatLayout(ColorScheme cs) {
    final List<Widget> rowWidgets = [];
    int seatIndex = 0;

    // Driver seat
    rowWidgets.add(
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          mainAxisAlignment: _logic.driverSide == 'Left'
              ? MainAxisAlignment.start
              : MainAxisAlignment.end,
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: _logic.driverSide == 'Left' ? 35 : 0,
                right: _logic.driverSide == 'Right' ? 35 : 0,
              ),
              child: Icon(Icons.event_seat, color: cs.primary, size: 30),
            ),
          ],
        ),
      ),
    );

    // Seat rows
    for (int r = 0; r < _logic.rows; r++) {
      final bool isLastRow =
          (_logic.useLastRowOverride && r == _logic.rows - 1);
      final int currentCols = isLastRow && _logic.lastRowColumns > 0
          ? _logic.lastRowColumns
          : _logic.columns;

      final List<Widget> seatRow = [];
      for (int c = currentCols - 1; c >= 0; c--) {
        if (seatIndex >= _logic.seats.length) break;
        seatRow.add(_buildSeatTile(_logic.seats[seatIndex], cs));
        seatIndex++;
      }

      rowWidgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: seatRow,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: rowWidgets,
    );
  }

  Widget _buildSeatTile(Seat seat, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Container(
        width: 36,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: seat.removed ? AppColors.error.withOpacity(0.2) : cs.surface,
          border: Border.all(
            color: seat.removed ? AppColors.error : cs.primary,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          seat.number.toString(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: seat.removed ? AppColors.error : cs.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
