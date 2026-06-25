class ApiException implements Exception {
  const ApiException(this.message, {this.fieldErrors = const {}});

  final String message;
  final Map<String, List<String>> fieldErrors;

  @override
  String toString() => message;
}
