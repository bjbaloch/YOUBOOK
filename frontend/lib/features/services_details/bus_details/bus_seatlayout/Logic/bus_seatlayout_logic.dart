// logic.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:youbook/core/theme/app_colors.dart';
import 'package:youbook/features/services_details/bus_details/bus_detail_page/UI/bus_detail_ui.dart';
import '../Data/bus_seatlayout_data.dart';

class SeatLayoutLogic {
  int rows = 0;
  int columns = 0;
  int lastRowColumns = 0;
  bool useLastRowOverride = true;
  String driverSide = 'Right';
  String numberingMode = 'Auto';
  List<Seat> seats = [];

  int getTotalSeats() {
    if (rows <= 0 || columns <= 0) return 0;
    if (useLastRowOverride && lastRowColumns > 0 && rows > 1) {
      return (rows - 1) * columns + lastRowColumns;
    } else {
      return rows * columns;
    }
  }

  void createSeatPlan(BuildContext context, VoidCallback updateUI) {
    if (rows <= 0 || columns <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Please set the rows and columns to create seat plan.',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          backgroundColor: AppColors.error.withOpacity(0.8),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final total = getTotalSeats();
    seats = List.generate(total, (i) => Seat(number: i + 1));
    updateUI();
  }

  void deleteAllSeats(VoidCallback updateUI) {
    seats = [];
    updateUI();
  }

  void toggleSeatRemoved(int index, VoidCallback updateUI) {
    if (index < 0 || index >= seats.length) return;
    seats[index].removed = !seats[index].removed;
    updateUI();
  }

  void removeSingleSeat(int index, VoidCallback updateUI) {
    if (index < 0 || index >= seats.length) return;
    seats[index].removed = true;
    updateUI();
  }

  void saveSeatLayout(BuildContext context) {
    if (seats.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No seat layout to save.'),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final layout = {
      'rows': rows,
      'columns': columns,
      'useLastRowOverride': useLastRowOverride,
      'lastRowColumns': useLastRowOverride ? lastRowColumns : null,
      'driverSide': driverSide,
      'numberingMode': numberingMode,
      'totalSeats': seats.length,
      'seats': seats.map((s) => s.toJson()).toList(),
    };

    final jsonStr = const JsonEncoder.withIndent('  ').convert(layout);
    debugPrint(jsonStr);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Seat layout saved successfully!'),
        backgroundColor: AppColors.accentOrange,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(milliseconds: 600), () {
      Navigator.pop(context, layout); // Return layout data
    });
  }

  void incRows(VoidCallback updateUI) => rows = (rows + 1).clamp(0, 100);
  void decRows(VoidCallback updateUI) => rows = (rows - 1).clamp(0, 100);
  void incColumns(VoidCallback updateUI) => columns = (columns + 1).clamp(0, 10);
  void decColumns(VoidCallback updateUI) => columns = (columns - 1).clamp(0, 10);
  void incLastRow(VoidCallback updateUI) => lastRowColumns = (lastRowColumns + 1).clamp(0, 5);
  void decLastRow(VoidCallback updateUI) => lastRowColumns = (lastRowColumns - 1).clamp(0, 5);
}
