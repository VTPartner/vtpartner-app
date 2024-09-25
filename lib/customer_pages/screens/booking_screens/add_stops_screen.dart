import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:vt_partner/infoHandler/app_info.dart';
import 'package:vt_partner/models/directions.dart';
import 'package:vt_partner/utils/app_styles.dart';

class AddStopsScreen extends StatefulWidget {
  const AddStopsScreen({super.key});

  @override
  _AddStopsScreenState createState() => _AddStopsScreenState();
}

class _AddStopsScreenState extends State<AddStopsScreen> {
  List<TextEditingController> _controllers = [];

  @override
  Widget build(BuildContext context) {
    var appInfo = Provider.of<AppInfo>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        toolbarHeight: 0,
      ),
      body: Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            itemCount: appInfo.destinations.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width - 80,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: TextField(
                      controller: _controllers[index],
                      textInputAction: TextInputAction.done,
                      style: nunitoSansStyle.copyWith(
                        fontSize: 12.0,
                        color: Colors.grey[900],
                      ),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 15),
                        border: const OutlineInputBorder(
                          borderSide: BorderSide(width: 0.1),
                        ),
                        labelText: 'Stop ${index + 1}',
                        hintText: 'Enter stop location',
                        suffixIcon: IconButton(
                          icon: Icon(
                            Icons.close,
                            color: Colors.red,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              appInfo.removeDestination(index);
                              _controllers.removeAt(index);
                            });
                          },
                        ),
                      ),
                      onChanged: (value) {
                        Directions updatedStop = Directions(
                          humanReadableAddress: value,
                          locationName: value,
                          locationId: appInfo.destinations[index].locationId,
                          locationLatitude:
                              appInfo.destinations[index].locationLatitude,
                          locationLongitude:
                              appInfo.destinations[index].locationLongitude,
                        );
                        appInfo.updateDestination(index, updatedStop);
                      },
                    ),
                  ),
                ),
              );
            },
          ),
          if (appInfo.destinations.length < 3)
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle_outline),
                  SizedBox(width: 5.0),
                  TextButton(
                    onPressed: () {
                      if (_controllers.length < 3) {
                        setState(() {
                          _controllers.add(TextEditingController());
                          // Add an empty Directions object to the list
                          appInfo.addDestination(Directions());
                        });
                      }
                    },
                    child: Text('ADD STOP'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
