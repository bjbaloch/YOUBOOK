// ui.dart
import 'package:flutter/material.dart';
import 'package:youbook/core/theme/app_colors.dart';
import 'package:youbook/features/services_details/van_details/van_details_page/UI/van_detail_ui.dart';
import 'package:youbook/features/services_details/van_details/van_seatlayout/logic/van_seatlayout_logic.dart';

class VanSeatLayoutFromImagePage extends StatefulWidget {
  const VanSeatLayoutFromImagePage({super.key});

  @override
  State<VanSeatLayoutFromImagePage> createState() =>
      _VanSeatLayoutFromImagePageState();
}

class _VanSeatLayoutFromImagePageState
    extends State<VanSeatLayoutFromImagePage> {
  final VanSeatLayoutController controller = VanSeatLayoutController();

  @override
  void initState() {
    super.initState();
    controller.createFixedSeatPlan();
  }

  void saveSeatLayout() {
    if (!controller.isValidLayout()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid seat layout. Please reset.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    debugPrint(controller.getSeatLayoutJson());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Van seat layout saved successfully!'),
        backgroundColor: AppColors.lightSeaGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );

    Future.delayed(const Duration(milliseconds: 600), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AddVanDetailsScreen()),
      );
    });
  }

  Widget buildSeatTile(
    int index, {
    double width = 48,
    double height = 40,
    double spacing = 6,
    bool isWide = false,
  }) {
    if (index < 0 || index >= controller.seats.length) {
      return SizedBox(width: width + spacing * 2, height: height + spacing * 2);
    }

    final seat = controller.seats[index];
    final double tileWidth = isWide ? (width * 2 + spacing * 2) : width;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.all(spacing),
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          GestureDetector(
            onTap: () {
              if (controller.numberingMode == 'Manual') {
                _showManualNumberDialog(seat);
              } else {
                setState(() => controller.toggleSeatRemoved(index));
              }
            },
            onLongPress: () =>
                setState(() => controller.toggleSeatRemoved(index)),
            child: Container(
              width: tileWidth,
              height: height,
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
              onTap: () => setState(() => controller.removeSingleSeat(index)),
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: seat.removed ? cs.outlineVariant : AppColors.error,
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

  void _showManualNumberDialog(dynamic seat) {
    final controllerText = TextEditingController(
      text: seat.number == 0 ? '' : seat.number.toString(),
    );
    bool showError = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Set seat number'),
            content: TextField(
              controller: controllerText,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter number',
                errorText: showError ? 'Please enter a number' : null,
              ),
            ),
            actions: [
              OutlinedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  final val = int.tryParse(controllerText.text.trim());
                  if (val == null) {
                    setStateDialog(() => showError = true);
                    return;
                  }
                  setState(() => seat.number = val);
                  Navigator.pop(ctx);
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildVanLayout({
    double seatWidth = 48,
    double seatHeight = 40,
    double spacing = 6,
    bool isPopup = false,
  }) {
    final cs = Theme.of(context).colorScheme;
    if (controller.seats.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          'No seat plan. Please reset.',
          style: TextStyle(color: cs.onSurface.withOpacity(0.7)),
        ),
      );
    }

    if (isPopup) {
      seatWidth = 40;
      seatHeight = 32;
      spacing = 4;
    }
    final double aisleWidth = seatWidth * 0.8;
    Widget emptySeat = SizedBox(
      width: seatWidth + spacing * 2,
      height: seatHeight + spacing * 2,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 10, right: seatWidth / 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'ڈرائیور',
                style: TextStyle(fontSize: seatHeight * 0.5, color: cs.primary),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildSeatTile(
              0,
              width: seatWidth,
              height: seatHeight,
              spacing: spacing,
            ),
            buildSeatTile(
              1,
              width: seatWidth,
              height: seatHeight,
              spacing: spacing,
            ),
            SizedBox(width: aisleWidth),
            buildSeatTile(
              3,
              width: seatWidth,
              height: seatHeight,
              spacing: spacing,
            ),
            buildSeatTile(
              4,
              width: seatWidth,
              height: seatHeight,
              spacing: spacing,
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildSeatTile(
              2,
              width: seatWidth,
              height: seatHeight,
              spacing: spacing,
              isWide: true,
            ),
            SizedBox(width: aisleWidth),
            buildSeatTile(
              6,
              width: seatWidth,
              height: seatHeight,
              spacing: spacing,
            ),
            buildSeatTile(
              7,
              width: seatWidth,
              height: seatHeight,
              spacing: spacing,
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildSeatTile(
              5,
              width: seatWidth,
              height: seatHeight,
              spacing: spacing,
              isWide: true,
            ),
            SizedBox(width: aisleWidth),
            buildSeatTile(
              9,
              width: seatWidth,
              height: seatHeight,
              spacing: spacing,
            ),
            buildSeatTile(
              10,
              width: seatWidth,
              height: seatHeight,
              spacing: spacing,
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildSeatTile(
              8,
              width: seatWidth,
              height: seatHeight,
              spacing: spacing,
              isWide: true,
            ),
            SizedBox(width: aisleWidth),
            emptySeat,
            emptySeat,
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildSeatTile(
              11,
              width: seatWidth,
              height: seatHeight,
              spacing: spacing,
            ),
            buildSeatTile(
              12,
              width: seatWidth,
              height: seatHeight,
              spacing: spacing,
            ),
            SizedBox(width: aisleWidth),
            buildSeatTile(
              13,
              width: seatWidth,
              height: seatHeight,
              spacing: spacing,
            ),
            buildSeatTile(
              14,
              width: seatWidth,
              height: seatHeight,
              spacing: spacing,
            ),
          ],
        ),
      ],
    );
  }

  void showSeatPreviewPopup() {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Seat Preview',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              _buildVanLayout(isPopup: true),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: cs.primary,
        centerTitle: true,
        title: Text(
          'Van Seat Layout (15-Seater)',
          style: TextStyle(color: cs.onPrimary),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: cs.onPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: cs.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Text('Numbering:', style: TextStyle(color: cs.onSurface)),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: controller.numberingMode,
                      items: const [
                        DropdownMenuItem(
                          value: 'Auto',
                          child: Text('Auto (1-15)'),
                        ),
                        DropdownMenuItem(
                          value: 'Manual',
                          child: Text('Manual (Tap to set)'),
                        ),
                      ],
                      onChanged: (v) => setState(() {
                        controller.numberingMode = v ?? 'Auto';
                        controller.createFixedSeatPlan();
                      }),
                    ),
                    const Spacer(),
                    OutlinedButton.icon(
                      onPressed: () => setState(controller.createFixedSeatPlan),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reset'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              color: cs.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Seat Grid Preview',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: cs.onSurface,
                          ),
                        ),
                        TextButton(
                          onPressed: controller.seats.isNotEmpty
                              ? showSeatPreviewPopup
                              : null,
                          child: const Text('Preview'),
                        ),
                      ],
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Column(
                        children: [
                          _buildVanLayout(),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: controller.seats.isNotEmpty
                                    ? () => setState(controller.removeAllSeats)
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.error,
                                ),
                                child: const Text('Remove All'),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: controller.seats.isNotEmpty
                                    ? saveSeatLayout
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accentOrange,
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
    );
  }
}
