// ui.dart
import 'package:flutter/material.dart';
import 'package:youbook/core/theme/app_colors.dart';
import 'package:youbook/features/services_details/bus_details/bus_seatlayout/Logic/bus_seatlayout_logic.dart';

class SeatLayoutConfigPage extends StatefulWidget {
  const SeatLayoutConfigPage({super.key});

  @override
  State<SeatLayoutConfigPage> createState() => _SeatLayoutConfigPageState();
}

class _SeatLayoutConfigPageState extends State<SeatLayoutConfigPage> {
  final SeatLayoutLogic logic = SeatLayoutLogic();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    void updateUI() => setState(() {});

    Widget _numberControl(int value, VoidCallback dec, VoidCallback inc,
        {bool enabled = true}) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: enabled ? () { dec(); updateUI(); } : null,
            icon: Icon(Icons.remove_circle_outline, color: cs.primary),
          ),
          Container(
            width: 44,
            alignment: Alignment.center,
            child: Text(
              value.toString(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
          ),
          IconButton(
            onPressed: enabled ? () { inc(); updateUI(); } : null,
            icon: Icon(Icons.add_circle_outline, color: cs.primary),
          ),
        ],
      );
    }

    Widget buildSeatTile(int index) {
      final seat = logic.seats[index];
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            GestureDetector(
              onTap: () => logic.toggleSeatRemoved(index, updateUI),
              child: Container(
                width: 56,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: seat.removed ? cs.surfaceVariant : cs.surface,
                  border: Border.all(
                    color: seat.removed ? cs.outlineVariant : cs.primary,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  seat.number.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: seat.removed
                        ? cs.onSurface.withOpacity(0.5)
                        : cs.onSurface,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: InkWell(
                onTap: () => logic.removeSingleSeat(index, updateUI),
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 12,
                    color: AppColors.textWhite,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget buildSeatGridPreview() {
      final List<Widget> rowWidgets = [];
      int seatIndex = 0;
      for (int r = 0; r < logic.rows; r++) {
        final bool isLastRow = (logic.useLastRowOverride && r == logic.rows - 1);
        final int currentCols = isLastRow && logic.lastRowColumns > 0
            ? logic.lastRowColumns
            : logic.columns;

        final List<Widget> seatRow = [];
        for (int c = currentCols - 1; c >= 0; c--) {
          if (seatIndex >= logic.seats.length) break;
          seatRow.add(buildSeatTile(seatIndex));
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

      // Driver seat
      rowWidgets.insert(
        0,
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            mainAxisAlignment: logic.driverSide == 'Left'
                ? MainAxisAlignment.start
                : MainAxisAlignment.end,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: logic.driverSide == 'Left' ? 35 : 0,
                  right: logic.driverSide == 'Right' ? 35 : 0,
                ),
                child: Icon(Icons.event_seat, color: cs.primary, size: 40),
              ),
            ],
          ),
        ),
      );

      return Column(crossAxisAlignment: CrossAxisAlignment.center, children: rowWidgets);
    }

    void showSeatPreviewPopup() {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: const EdgeInsets.all(16),
          content: SingleChildScrollView(child: buildSeatGridPreview()),
        ),
      );
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(45),
        child: AppBar(
          elevation: 0,
          centerTitle: true,
          backgroundColor: cs.primary,
          title: Text(
            'Seat Layout Configuration',
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top config card
              Card(
                color: cs.surface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Define total number of seats:  ${logic.getTotalSeats()}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text('Numbering:', style: TextStyle(color: cs.onSurface)),
                          const SizedBox(width: 8),
                          DropdownButton<String>(
                            value: logic.numberingMode,
                            underline: const SizedBox(),
                            dropdownColor: cs.surface,
                            items: const [
                              DropdownMenuItem(value: 'Auto', child: Text('Auto Numbering')),
                              DropdownMenuItem(value: 'Manual', child: Text('Manual Numbering')),
                            ],
                            onChanged: (v) {
                              setState(() => logic.numberingMode = v ?? 'Auto');
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text('Rows:', style: TextStyle(color: cs.onSurface)),
                          const SizedBox(width: 8),
                          _numberControl(logic.rows, () => logic.decRows(updateUI), () => logic.incRows(updateUI)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text('Columns:', style: TextStyle(color: cs.onSurface)),
                          const SizedBox(width: 8),
                          _numberControl(logic.columns, () => logic.decColumns(updateUI), () => logic.incColumns(updateUI)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text('Last row:', style: TextStyle(color: cs.onSurface)),
                          const SizedBox(width: 8),
                          _numberControl(
                            logic.lastRowColumns,
                            () => logic.decLastRow(updateUI),
                            () => logic.incLastRow(updateUI),
                            enabled: logic.useLastRowOverride,
                          ),
                          const SizedBox(width: 10),
                          Checkbox(
                            value: logic.useLastRowOverride,
                            onChanged: (v) => setState(() {
                              logic.useLastRowOverride = v ?? false;
                              if (!logic.useLastRowOverride) logic.lastRowColumns = 0;
                              if (logic.useLastRowOverride && logic.lastRowColumns == 0) {
                                logic.lastRowColumns = logic.columns.clamp(0, 5);
                              }
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text('Driver seat:', style: TextStyle(color: cs.onSurface)),
                          const SizedBox(width: 12),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: cs.outlineVariant, width: 1),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: DropdownButton<String>(
                              value: logic.driverSide,
                              borderRadius: BorderRadius.circular(10),
                              underline: const SizedBox(),
                              dropdownColor: cs.surface,
                              items: const [
                                DropdownMenuItem(value: 'Right', child: Text('Right')),
                                DropdownMenuItem(value: 'Left', child: Text('Left')),
                              ],
                              onChanged: (v) => setState(() => logic.driverSide = v ?? 'Right'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => logic.createSeatPlan(context, updateUI),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentOrange,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Create Seat Plan'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Seat grid preview
              Card(
                color: cs.surface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Seat Grid Preview', style: TextStyle(fontWeight: FontWeight.bold, color: cs.onSurface)),
                          TextButton(
                            onPressed: logic.seats.isNotEmpty ? showSeatPreviewPopup : null,
                            child: const Text('Preview'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Column(
                          children: [
                            buildSeatGridPreview(),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.error,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  onPressed: logic.seats.isNotEmpty ? () => logic.deleteAllSeats(updateUI) : null,
                                  child: const Text('Delete All'),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: logic.seats.isNotEmpty ? () => logic.saveSeatLayout(context) : null,
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  child: const Text('Save seat layout'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
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
}
