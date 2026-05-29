class Preprocessor {
  String input;
  int pos = 0;

  Map<String, String> defs = {};

  Preprocessor(this.input);

  String preprocess() {
    input = _processDirectives();
    return _expandMacros(input);
  }

  String _processDirectives() {
    String result = '';
    pos = 0;

    while (pos < input.length) {
      if (input[pos] == '#') {
        _processLine();
      } else {
        result += input[pos];
        pos++;
      }
    }
    return result;
  }

  String _expandMacros(final String text) {
    String result = '';
    int i = 0;

    while (i < text.length) {
      if (_isLetter(text[i])) {
        String name = '';
        while (i < text.length && _isLetter(text[i])) {
          name += text[i];
          i++;
        }
        if (defs.containsKey(name)) {
          result += defs[name]!;
        } else {
          result += name;
        }
      } else {
        result += text[i];
        i++;
      }
    }
    return result;
  }

  String _getString(final String endChar) {
    String result = '';
    while (pos < input.length && input[pos] != endChar) {
      result += input[pos];
      pos++;
    }
    if (pos < input.length && input[pos] == endChar) {
      pos++;
    }
    return result.trim();
  }

  void _processLine() {
    pos++;
    final String cmd = _getString(' ');

    if (cmd == 'def') {
      final String name = _getString(' ');
      final String value = _getString('\n');
      defs[name] = value;
    }
  }

  bool _isLetter(final String c) {
    final int code = c.codeUnitAt(0);
    return (code >= 65 && code <= 90) || (code >= 97 && code <= 122);
  }
}
