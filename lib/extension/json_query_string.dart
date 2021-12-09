extension JsonQueryString on String? {
  String queryReplace() => (this ?? "").replaceAll("\"", "'").replaceAll("'", "\\'");
}