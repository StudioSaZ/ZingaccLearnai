// universal_html_stub_fake.dart
// Dummy classes for non-web platforms to avoid compilation errors

class FormElement {
  String? action;
  String? method;
  void append(dynamic child) {}
  void submit() {}
  void remove() {}
}

class InputElement {
  String? type;
  String? name;
  String? value;
}

class document {
  static var body = _Body();
}

class _Body {
  void append(dynamic element) {}
}