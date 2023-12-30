// Import statement for Flutter material components.
import 'package:flutter/material.dart';

// Future function to display a dialog for creating a shift plan.
Future<Map<String, dynamic>?> showShiftPlanDialog(BuildContext context) async {
  // GlobalKey to identify the Form widget and interact with its state.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Variables to store user inputs from the form fields.
  int startRestPeriod = 0;
  int endRestPeriod = 0;
  int numberOfShifts = 1;
  int overlapMinutes = 0;

  // showDialog function to display the AlertDialog.
  return showDialog<Map<String, dynamic>>(
    context: context,
    builder: (BuildContext context) {
      // The AlertDialog widget.
      return AlertDialog(
        title: Text('Create Shift Plan'),
        // Form widget to manage form state and validation.
        content: Form(
          key: _formKey,
          // SingleChildScrollView to allow for scrolling if the content overflows.
          child: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                // TextFormField for start rest period input.
                TextFormField(
                  decoration: InputDecoration(
                      labelText: 'Start Rest Period from now (in minutes)'),
                  initialValue: startRestPeriod.toString(),
                  keyboardType: TextInputType.number,
                  onSaved: (value) {
                    // Parsing and saving the input value.
                    startRestPeriod = int.tryParse(value ?? '0') ?? 0;
                  },
                  // Validator for the input field.
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a value';
                    }
                    return null;
                  },
                ),
                // TextFormField for end rest period input.
                TextFormField(
                  decoration: InputDecoration(
                      labelText: 'End Rest Period before landing (in minutes)'),
                  initialValue: endRestPeriod.toString(),
                  keyboardType: TextInputType.number,
                  onSaved: (value) {
                    // Parsing and saving the input value.
                    endRestPeriod = int.tryParse(value ?? '0') ?? 0;
                  },
                  // Validator for the input field.
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a value';
                    }
                    return null;
                  },
                ),
                // TextFormField for number of shifts input.
                TextFormField(
                  decoration: InputDecoration(labelText: 'Number of Shifts'),
                  initialValue: numberOfShifts.toString(),
                  keyboardType: TextInputType.number,
                  onSaved: (value) {
                    // Parsing and saving the input value.
                    numberOfShifts = int.tryParse(value ?? '1') ?? 1;
                  },
                  // Validator for the input field.
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a value';
                    }
                    if (int.tryParse(value) == null || int.parse(value) <= 0) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                // TextFormField for overlap minutes input.
                TextFormField(
                  decoration: InputDecoration(labelText: 'Overlap Minutes'),
                  initialValue: overlapMinutes.toString(),
                  keyboardType: TextInputType.number,
                  onSaved: (value) {
                    // Parsing and saving the input value.
                    overlapMinutes = int.tryParse(value ?? '0') ?? 0;
                  },
                  // Validator for the input field.
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a value';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        // Action buttons for the dialog.
        actions: <Widget>[
          // Button to cancel and close the dialog.
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          // Button to create the shift plan based on the inputs.
          TextButton(
            child: Text('Create'),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // Saving the form state if all fields are valid.
                _formKey.currentState!.save();

                // Returning the shift plan data and closing the dialog.
                Navigator.of(context).pop({
                  'startRestPeriod': startRestPeriod,
                  'endRestPeriod': endRestPeriod,
                  'numberOfShifts': numberOfShifts,
                  'overlapMinutes': overlapMinutes,
                });
              }
            },
          ),
        ],
      );
    },
  );
}
