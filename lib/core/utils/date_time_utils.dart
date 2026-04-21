import 'package:intl/intl.dart';

class DateTimeUtils {
  static String timeAgo(DateTime date) {
    final difference = DateTime.now().difference(date);
    if (difference.inSeconds < 60) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return DateFormat('d MMM').format(date);
  }

  static String format(DateTime date, String pattern) {
    return DateFormat(pattern).format(date);
  }
}
