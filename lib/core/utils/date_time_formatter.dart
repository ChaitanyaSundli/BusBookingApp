import 'package:intl/intl.dart';

String formatTravelDateTime(String raw, {String fallback = '--'}) {
  try {
    final dt = DateTime.parse(raw).toLocal();
    return DateFormat('EEE, dd MMM • hh:mm a').format(dt);
  } catch (_) {
    return raw.isEmpty ? fallback : raw;
  }
}

String formatTravelTime(String raw, {String fallback = '--'}) {
  try {
    final dt = DateTime.parse(raw);
    return DateFormat('hh:mm a').format(dt);
  } catch (_) {
    return raw.isEmpty ? fallback : raw;
  }
}
