String? formatDate(String? dateTimeStr) {
  if (dateTimeStr == null || dateTimeStr.isEmpty) {
    return null;
  }
  final dateTime = DateTime.parse(dateTimeStr);
  return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
}

String? formatTime(String? dateTimeStr) {
  if (dateTimeStr == null || dateTimeStr.isEmpty) {
    return null;
  }
  final dateTime = DateTime.parse(dateTimeStr);
  int hour = dateTime.hour;
  final minute = dateTime.minute.toString().padLeft(2, '0');
  final period = hour >= 12 ? 'pm' : 'am';
  hour = hour % 12 == 0 ? 12 : hour % 12;
  return '$hour:$minute $period';
}
