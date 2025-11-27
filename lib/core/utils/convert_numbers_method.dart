String replaceToEnglishNumber(String input) {
  const arabic  = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩', '٫'];
  const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '.'];

  for (int i = 0; i < arabic.length; i++) {
    input = input.replaceAll(arabic[i], english[i]);
  }

  return input;
}
String replaceToArabicNumber(String input) {
  const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '.'];
  const arabic  = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩', '٫'];

  for (int i = 0; i < english.length; i++) {
    input = input.replaceAll(english[i], arabic[i]);
  }

  return input;
}

String replaceToArabicDate(String input) {
  List<String> date = input.toString().substring(0, 10).split("-");
  List<String> newDate = [];
  for (int i = date.length - 1; i >= 0; i--) {
    newDate.add(date[i]);
  }
  var dateAr = StringBuffer();
  for (var element in newDate) {
    dateAr.write("${replaceToArabicNumber(element)}"
        "${element.length != 4 ? " - " : ""}");
  }
  return dateAr.toString();
}
