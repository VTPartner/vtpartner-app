import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vt_partner/infoHandler/app_info.dart';
import 'package:vt_partner/models/stops.dart';

class AddStopsDialog extends StatefulWidget {
  @override
  _AddStopsDialogState createState() => _AddStopsDialogState();
}

class _AddStopsDialogState extends State<AddStopsDialog> {
  List<Stop> stops = []; // List to store added stops
  final TextEditingController _addressController = TextEditingController();

  void _addStop() {
    // Assuming you've validated the address and obtained lat/lng
    double lat = 0.0; // Get latitude
    double lng = 0.0; // Get longitude
    String address = _addressController.text;

    if (stops.length < 3) {
      stops.add(Stop(address: address, latitude: lat, longitude: lng));
      _addressController.clear();
      setState(() {});
    } else {
      // Optionally show a message that the limit has been reached
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You can only add up to 3 stops.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Stops'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _addressController,
            decoration: InputDecoration(hintText: 'Enter address'),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: _addStop,
            child: Text('Add Stop'),
          ),
          SizedBox(height: 10),
          // Display list of stops
          for (var stop in stops) Text(stop.address ?? 'Unknown'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            // Save stops to Provider or any state management
            Provider.of<AppInfo>(context, listen: false)
                .updateStopsList(stops); // Update Provider
            Navigator.of(context).pop();
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}
