import 'package:flutter/material.dart';
import 'package:youbook/core/theme/app_colors.dart';
import 'package:youbook/features/services_details/van_details/van_seatlayout/logic/van_seatlayout_logic.dart';
import 'package:youbook/features/services_details/van_details/van_seatlayout/Data/van_seatlayout_data.dart';

class VanSeatLayoutViewScreen extends StatefulWidget {
  const VanSeatLayoutViewScreen({super.key});

  @override
  State<VanSeatLayoutViewScreen> createState() => _VanSeatLayoutViewScreenState();
}

class _VanSeatLayoutViewScreenState extends State<VanSeatLayoutViewScreen> {
  final VanSeatLayoutController _controller = VanSeatLayoutController();

  @override
  void initState() {
    super.initState();
    // Create a default layout for viewing
    _controller.createFixedSeatPlan();
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
            'Van Seat Layout',
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
                          _legendItem(cs, cs.surface, cs.primary, 'Available Seat'),
                          const SizedBox(width: 16),
                          _legendItem(cs, AppColors.error.withOpacity(0.2), AppColors.error, 'Removed Seat'),
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
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: cs.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${_controller.seats.length} seats',
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
                        child: _buildVanLayout(cs),
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
                      _infoRow('Total Seats', _controller.seats.length.toString()),
                      _infoRow('Layout Type', '15-Seater Van'),
                      _infoRow('Driver Side', driverSide),
                      _infoRow('Numbering Mode', _controller.numberingMode),
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

  Widget _legendItem(ColorScheme cs, Color bgColor, Color borderColor, String label) {
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
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: cs.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildVanLayout(ColorScheme cs) {
    final double seatWidth = 36;
    final double seatHeight = 28;
    final double spacing = 4;
    final double aisleWidth = seatWidth * 0.8;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Driver seat
        Padding(
          padding: EdgeInsets.only(bottom: 8, right: seatWidth / 2),
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

  Widget _buildVanSeatTile(
    int index,
    ColorScheme cs,
    double width,
    double height,
    double spacing, {
    bool isWide = false,
  }) {
    if (index >= _controller.seats.length) {
      final tileWidth = isWide ? (width * 2 + spacing * 2) : width;
      return SizedBox(width: tileWidth + spacing * 2, height: height + spacing * 2);
    }

    final seat = _controller.seats[index];
    final double tileWidth = isWide ? width * 2 : width;

    return Padding(
      padding: EdgeInsets.all(spacing),
      child: Container(
        width: tileWidth,
        height: height,
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
            color: seat.removed
                ? AppColors.error
                : cs.onSurface,
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
