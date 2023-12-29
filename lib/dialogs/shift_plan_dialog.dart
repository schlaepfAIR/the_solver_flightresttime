import 'package:flutter/material.dart';

Future<Map<String, dynamic>?> showShiftPlanDialog(BuildContext context) async {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int startRestPeriod = 0;
  int endRestPeriod = 0;
  int numberOfShifts = 1;
  int overlapMinutes = 0;

  return showDialog<Map<String, dynamic>>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Create Shift Plan'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(
                      labelText: 'Start Rest Period from now (in minutes)'),
                  initialValue: startRestPeriod.toString(),
                  keyboardType: TextInputType.number,
                  onSaved: (value) {
                    startRestPeriod = int.tryParse(value ?? '0') ?? 0;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a value';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(
                      labelText: 'End Rest Period before landing (in minutes)'),
                  initialValue: endRestPeriod.toString(),
                  keyboardType: TextInputType.number,
                  onSaved: (value) {
                    endRestPeriod = int.tryParse(value ?? '0') ?? 0;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a value';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Number of Shifts'),
                  initialValue: numberOfShifts.toString(),
                  keyboardType: TextInputType.number,
                  onSaved: (value) {
                    numberOfShifts = int.tryParse(value ?? '1') ?? 1;
                  },
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
                TextFormField(
                  decoration: InputDecoration(labelText: 'Overlap Minutes'),
                  initialValue: overlapMinutes.toString(),
                  keyboardType: TextInputType.number,
                  onSaved: (value) {
                    overlapMinutes = int.tryParse(value ?? '0') ?? 0;
                  },
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
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('Create'),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();

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
