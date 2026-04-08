import 'package:intl/intl.dart';

String formatTravelDateTime(String raw, {String fallback = '--'}) {
  try {
    final dt = DateTime.parse(raw).toLocal();
    return DateFormat('EEE, dd MMM • hh:mm a').format(dt);
  } catch (_) {
    return raw.isEmpty ? fallback : raw;
  }
}

String formatTravelTime(String? raw) {
  if (raw == null) return '--';
  try {
    final dt = DateTime.parse(raw).toLocal();
    return DateFormat('hh:mm a').format(dt);
  } catch (_) {
    return raw;
  }
}


String calculateDuration(String departure, String arrival) {
  try {
    final dep = DateTime.parse(departure);
    final arr = DateTime.parse(arrival);
    final diff = arr.difference(dep);
    final hours = diff.inHours;
    final minutes = diff.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  } catch (_) {
    return '--';
  }
}