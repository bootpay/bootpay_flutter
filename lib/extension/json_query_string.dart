extension JsonQueryString on String? {
  String queryReplace() {
    if (this == null) return "";

    // Properly escape for JavaScript strings
    return this!
        .replaceAll("\\", "\\\\")  // Escape backslashes first
        .replaceAll("'", "\\'")     // Escape single quotes
        .replaceAll("\"", "\\\"")   // Escape double quotes
        .replaceAll("\n", "\\n")    // Escape newlines
        .replaceAll("\r", "\\r")    // Escape carriage returns
        .replaceAll("\t", "\\t");   // Escape tabs
  }
}