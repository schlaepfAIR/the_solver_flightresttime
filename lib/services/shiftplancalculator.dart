class ShiftPlanCalculator {
  static DateTime? parseUtcTime(String? utcString) {
    if (utcString == null) return null;
    return DateTime.tryParse(utcString);
  }

  static Duration calculateNettoShiftDuration(DateTime? startTime,
      DateTime? endTime, int startRestPeriod, int endRestPeriod) {
    if (startTime != null && endTime != null) {
      DateTime startTotalRestperiodTime =
          startTime.add(Duration(minutes: startRestPeriod));
      DateTime endTotalRestperiodTime =
          endTime.subtract(Duration(minutes: endRestPeriod));
      return endTotalRestperiodTime.difference(startTotalRestperiodTime);
    }
    return Duration();
  }

  static List<DateTime> calculateShiftSchedule(
      DateTime? startTotalRestperiodTime,
      Duration nettoShiftDuration,
      int numberOfShifts,
      int overlapMinutes) {
    List<DateTime> shiftSchedule = [];
    if (startTotalRestperiodTime != null && nettoShiftDuration.inMinutes > 0) {
      Duration shiftDurationWithOverlap = nettoShiftDuration ~/ numberOfShifts;
      Duration overlapDuration = Duration(minutes: overlapMinutes);
      Duration actualShiftDuration = shiftDurationWithOverlap - overlapDuration;

      DateTime currentShiftStart = startTotalRestperiodTime;
      for (int i = 0; i < numberOfShifts; i++) {
        shiftSchedule.add(currentShiftStart);
        currentShiftStart = currentShiftStart.add(shiftDurationWithOverlap);
      }
    }
    return shiftSchedule;
  }
}
