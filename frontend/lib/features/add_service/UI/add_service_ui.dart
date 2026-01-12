import 'package:flutter/material.dart';
import 'package:youbook/features/add_service/Data/add_service_data.dart';
import 'package:youbook/features/add_service/Logic/add_service_logic.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return WillPopScope(
      onWillPop: () => ServicesLogic.onWillPop(context),
      child: Scaffold(
        backgroundColor: cs.background,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(45),
          child: AppBar(
            toolbarHeight: 45,
            backgroundColor: cs.primary,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: cs.onPrimary),
              onPressed: () => ServicesLogic.goBack(context),
            ),
            title: Text(
              "Services",
              style: TextStyle(color: cs.onPrimary, fontSize: 20),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 1),

                /// -------------------- Added Services Section --------------------
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    "See and Edit the added services.",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: cs.onSurface.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                ServicesData.serviceTile(
                  context,
                  "Added services",
                  Icons.list_alt_rounded,
                  () => ServicesLogic.openAddedServices(context),
                ),

                const SizedBox(height: 16),

                /// -------------------- Add New Services Section --------------------
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    "Select a service to add its details.",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: cs.onSurface.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                ServicesData.serviceTile(
                  context,
                  "Add Bus details",
                  Icons.directions_bus_filled,
                  () => ServicesLogic.openBusDetails(context),
                ),

                ServicesData.serviceTile(
                  context,
                  "Add Van details",
                  Icons.airport_shuttle,
                  () => ServicesLogic.openVanDetails(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
