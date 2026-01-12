import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../Data/seat_selection_data.dart';
import '../Logic/seat_selection_logic.dart';
import '../../../core/models/booking.dart';

class SeatSelectionUI extends StatefulWidget {
  final SeatSelectionData initialData;
  final double baseFare;

  const SeatSelectionUI({
    super.key,
    required this.initialData,
    required this.baseFare,
  });

  @override
  State<SeatSelectionUI> createState() => _SeatSelectionUIState();
}

class _SeatSelectionUIState extends State<SeatSelectionUI> {
  late SeatSelectionData _data;

  @override
  void initState() {
    super.initState();
    _data = widget.initialData;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return WillPopScope(
      onWillPop: () => _handleBackPress(context),
      child: Scaffold(
        backgroundColor: cs.background,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(45),
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: cs.primary,
            elevation: 0,
            centerTitle: true,
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarIconBrightness: Brightness.light,
              statusBarBrightness: Brightness.dark,
            ),
            title: Text(
              "Select Seats",
              style: TextStyle(
                color: cs.onPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: cs.onPrimary),
              onPressed: () => _handleBackPress(context),
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              _legendAndSummary(cs),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: _data.vehicleType == VehicleType.bus
                      ? _buildBusLayout(cs)
                      : _buildVanLayout(cs),
                ),
              ),
              _bottomBar(cs),
            ],
          ),
        ),
      ),
    );
  }

  Widget _legendAndSummary(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: cs.surface,
      child: Column(
        children: [
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendItem(cs, Colors.green.shade200, Colors.green, 'Available'),
              const SizedBox(width: 16),
              _legendItem(cs, Colors.red.shade200, Colors.red, 'Booked'),
              const SizedBox(width: 16),
              _legendItem(cs, cs.primary, cs.primary, 'Selected'),
            ],
          ),
          const SizedBox(height: 8),
          // Selection summary
          Text(
            SeatSelectionLogic.getSelectionSummary(_data),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendItem(ColorScheme cs, Color bgColor, Color borderColor, String label) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: cs.onSurface.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildBusLayout(ColorScheme cs) {
    // Simple grid layout for bus (4 rows x 10 columns)
    final rows = 4;
    final cols = 10;

    return Column(
      children: [
        // Driver seat
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.event_seat, color: cs.primary, size: 40),
              const SizedBox(width: 8),
              Text(
                'Driver',
                style: TextStyle(
                  color: cs.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        // Seat grid
        ...List.generate(rows, (rowIndex) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(cols, (colIndex) {
                final seatIndex = rowIndex * cols + colIndex;
                if (seatIndex >= _data.seats.length) {
                  return const SizedBox(width: 56, height: 44);
                }
                return _buildSeatTile(_data.seats[seatIndex], cs);
              }),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildVanLayout(ColorScheme cs) {
    // Van has fixed 15-seater layout
    final seatWidth = 48.0;
    final seatHeight = 40.0;
    final spacing = 6.0;
    final aisleWidth = seatWidth * 0.8;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Driver seat
        Padding(
          padding: EdgeInsets.only(bottom: 10, right: seatWidth / 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Driver',
                style: TextStyle(
                  fontSize: seatHeight * 0.5,
                  color: cs.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: spacing),
              Icon(
                Icons.event_seat_outlined,
                color: cs.primary,
                size: seatHeight * 1.2,
              ),
            ],
          ),
        ),
        // Row 1: seats 1,2 | aisle | 4,5
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildVanSeatTile(0, cs, seatWidth, seatHeight, spacing),
            _buildVanSeatTile(1, cs, seatWidth, seatHeight, spacing),
            SizedBox(width: aisleWidth),
            _buildVanSeatTile(3, cs, seatWidth, seatHeight, spacing),
            _buildVanSeatTile(4, cs, seatWidth, seatHeight, spacing),
          ],
        ),
        // Row 2: seat 3 (wide) | aisle | 6,7
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildVanSeatTile(2, cs, seatWidth, seatHeight, spacing, isWide: true),
            SizedBox(width: aisleWidth),
            _buildVanSeatTile(6, cs, seatWidth, seatHeight, spacing),
            _buildVanSeatTile(7, cs, seatWidth, seatHeight, spacing),
          ],
        ),
        // Row 3: seat 5 (wide) | aisle | 9,10
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildVanSeatTile(5, cs, seatWidth, seatHeight, spacing, isWide: true),
            SizedBox(width: aisleWidth),
            _buildVanSeatTile(9, cs, seatWidth, seatHeight, spacing),
            _buildVanSeatTile(10, cs, seatWidth, seatHeight, spacing),
          ],
        ),
        // Row 4: seat 8 (wide) | aisle | empty, empty
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildVanSeatTile(8, cs, seatWidth, seatHeight, spacing, isWide: true),
            SizedBox(width: aisleWidth),
            SizedBox(width: seatWidth + spacing * 2, height: seatHeight + spacing * 2),
            SizedBox(width: seatWidth + spacing * 2, height: seatHeight + spacing * 2),
          ],
        ),
        // Row 5: seats 11,12 | aisle | 13,14
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildVanSeatTile(11, cs, seatWidth, seatHeight, spacing),
            _buildVanSeatTile(12, cs, seatWidth, seatHeight, spacing),
            SizedBox(width: aisleWidth),
            _buildVanSeatTile(13, cs, seatWidth, seatHeight, spacing),
            _buildVanSeatTile(14, cs, seatWidth, seatHeight, spacing),
          ],
        ),
      ],
    );
  }

  Widget _buildSeatTile(SeatModel seat, ColorScheme cs) {
    final isSelectable = SeatSelectionLogic.isSeatSelectable(seat);

    return Padding(
      padding: const EdgeInsets.all(2),
      child: InkWell(
        onTap: isSelectable
            ? () => setState(() {
                  _data = SeatSelectionLogic.handleSeatTap(_data, seat.number);
                })
            : null,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 56,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: SeatSelectionLogic.getSeatColor(seat, cs),
            border: Border.all(
              color: SeatSelectionLogic.getSeatBorderColor(seat, cs),
              width: seat.isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                seat.number.toString(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: SeatSelectionLogic.getSeatTextColor(seat, cs),
                ),
              ),
              if (SeatSelectionLogic.getGenderIcon(seat.gender) != null)
                Icon(
                  SeatSelectionLogic.getGenderIcon(seat.gender)!,
                  size: 12,
                  color: SeatSelectionLogic.getSeatTextColor(seat, cs),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVanSeatTile(
    int index,
    ColorScheme cs,
    double width,
    double height,
    double spacing, {
    bool isWide = false,
  }) {
    if (index >= _data.seats.length) {
      final tileWidth = isWide ? (width * 2 + spacing * 2) : width;
      return SizedBox(width: tileWidth + spacing * 2, height: height + spacing * 2);
    }

    final seat = _data.seats[index];
    final isSelectable = SeatSelectionLogic.isSeatSelectable(seat);

    return Padding(
      padding: EdgeInsets.all(spacing),
      child: InkWell(
        onTap: isSelectable
            ? () => setState(() {
                  _data = SeatSelectionLogic.handleSeatTap(_data, seat.number);
                })
            : null,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: isWide ? width * 2 : width,
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: SeatSelectionLogic.getSeatColor(seat, cs),
            border: Border.all(
              color: SeatSelectionLogic.getSeatBorderColor(seat, cs),
              width: seat.isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                seat.number.toString(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: SeatSelectionLogic.getSeatTextColor(seat, cs),
                ),
              ),
              if (SeatSelectionLogic.getGenderIcon(seat.gender) != null)
                Icon(
                  SeatSelectionLogic.getGenderIcon(seat.gender)!,
                  size: 12,
                  color: SeatSelectionLogic.getSeatTextColor(seat, cs),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomBar(ColorScheme cs) {
    final totalFare = _data.getTotalFare(widget.baseFare);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: cs.outline.withOpacity(0.3))),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Total: Rs. ${totalFare.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: cs.primary,
                    ),
                  ),
                  Text(
                    '${_data.selectedSeatNumbers.length}/${_data.maxSeatsPerBooking} seats selected',
                    style: TextStyle(
                      fontSize: 12,
                      color: cs.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: _data.isValidSelection
                  ? () => SeatSelectionLogic.proceedToBookingSummary(
                        context,
                        _data,
                        widget.baseFare,
                      )
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _handleBackPress(BuildContext context) async {
    if (_data.selectedSeatNumbers.isNotEmpty) {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Discard Selection?'),
          content: const Text(
            'You have selected seats. Are you sure you want to go back? Your selection will be lost.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Discard'),
            ),
          ],
        ),
      );
      return result ?? false;
    }
    return true;
  }
}
