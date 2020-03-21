class EscapeSequences {
  var newline = '\n';
  var dollar = '$';
  final escapedDollar = "\$";
  final backslash = '\\';
  final bothSlashes = const ['/', '\\'];
  final stringWithBackslashes = "I\ can\ escape\ spaces";

  stringInterpolation() {
    var id = '${item['id']}';
  }
}