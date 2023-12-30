// ShiftPlanCalculator class definition.
class ShiftPlanCalculator {

  // Static method to parse a UTC time string into a DateTime object.
  static DateTime? parseUtcTime(String? utcString) {
    if (utcString == null) return null; // Returns null if the string is null.
    return DateTime.tryParse(utcString); // Tries to parse the string into a DateTime object.
  }

  // Static method to calculate the net shift duration.
  static Duration calculateNettoShiftDuration(DateTime? startTime,
      DateTime? endTime, int startRestPeriod, int endRestPeriod) {
    if (startTime != null && endTime != null) {
      // Calculating the start and end times of the total rest period.
      DateTime startTotalRestperiodTime =
          startTime.add(Duration(minutes: startRestPeriod));
      DateTime endTotalRestperiodTime =
          endTime.subtract(Duration(minutes: endRestPeriod));

      // Returning the duration between the start and end of the rest period.
      return endTotalRestperiodTime.difference(startTotalRestperiodTime);
    }
    return Duration(); // Returns a zero duration if start or end time is null.
  }

  // Static method to calculate the shift schedule.
  static List<DateTime> calculateShiftSchedule(
      DateTime? startTotalRestperiodTime,
      Duration nettoShiftDuration,
      int numberOfShifts,
      int overlapMinutes) {
    List<DateTime> shiftSchedule = []; // List to hold the shift schedule.

    if (startTotalRestperiodTime != null && nettoShiftDuration.inMinutes > 0) {
      // Calculating the duration of each shift including the overlap.
      Duration shiftDurationWithOverlap = nettoShiftDuration ~/ numberOfShifts;
      Duration overlapDuration = Duration(minutes: overlapMinutes);

      // Calculating the actual duration of each shift without the overlap.
      Duration actualShiftDuration = shiftDurationWithOverlap - overlapDuration;

      DateTime currentShiftStart = startTotalRestperiodTime;
      // Loop to calculate the start time of each shift.
      for (int i = 0; i < numberOfShifts; i++) {
        shiftSchedule.add(currentShiftStart); // Adding the start time to the schedule.
        // Calculating the start time of the next shift.
        currentShiftStart = currentShiftStart.add(shiftDurationWithOverlap);
      }
    }
    return shiftSchedule; // Returning the calculated shift schedule.
  }
}
