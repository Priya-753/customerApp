import 'package:jiffy/jiffy.dart';

class DateUtilities {
  static const String day = "d";
  static const String abbrWeekday = "E";
  static const String weekday = "EEEE";
  static const String abbrStandaloneMonth = "LLL";
  static const String standaloneMonth = "LLLL";
  static const String numMonth = "M";
  static const String numMonthDay = "Md";
  static const String numMonthWeekdayDay = "MEd";
  static const String abbrMonth = "MMM";
  static const String abbrMonthDay = "MMMd";
  static const String abbrMonthWeekdayDay = "MMMEd";
  static const String month = "MMMM";
  static const String monthDay = "MMMMd";
  static const String monthWeekdayDay = "MMMMEEEEd";
  static const String abbrQuarter = "QQQ";
  static const String quarter = "QQQQ";
  static const String year = "y";
  static const String yearNumMonth = "yM";
  static const String yearNumMonthDay = "yMd";
  static const String yearNumMonthWeekdayDay = "yMEd";
  static const String yearAbbrMonth = "yMMM";
  static const String yearAbbrMonthDay = "yMMMd";
  static const String yearAbbrMonthWeekdayDay = "yMMMEd";
  static const String yearMonth = "yMMMM";
  static const String yearMonthDay = "yMMMMd";
  static const String yearMonthWeekdayDay = "yMMMMEEEEd";
  static const String yearAbbrQuarter = "yQQQ";
  static const String yearQuarter = "yQQQQ";
  static const String hour24 = "H";
  static const String hour24Minute = "Hm";
  static const String hour24MinuteSecond = "Hms";
  static const String hour = "j";
  static const String hourMinute = "jm";
  static const String hourMinuteSecond = "jms";
  static const String minute = "m";
  static const String minuteSecond = "ms";
  static const String second = "s";

  static String getFormattedDate(Jiffy date, String dateFormat) {
    return date.format(dateFormat);
  }

  static Jiffy getJiffyFromString(String dateString, String dateFormat) {
    return Jiffy(dateString, dateFormat);
  }

  static Jiffy getJiffyFromMillis(int millisecondsSinceEpoch) {
    return Jiffy.unixFromMillisecondsSinceEpoch(millisecondsSinceEpoch);
  }

  static Jiffy getJiffyFromDateTime(DateTime dateTime) {
    return Jiffy(dateTime);
  }

  static num difference(Jiffy fromDate, Jiffy toDate, Units units) {
    return Jiffy(fromDate).diff(toDate, units);
  }
}
