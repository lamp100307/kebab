class Preprocessor {
  String input;
  int pos = 0;

  Map<String, String> defs = {};
  
  Preprocessor(this.input);

  String preprocess() {
    while (pos < input.length) {
      final String c = input[pos];
      if (c == '#') {
        _processLine();
      } else if (_isLetter(c)) {
        String name = '';
        while (pos < input.length && _isLetter(input[pos])) {
          name += input[pos];
          pos++;
        }
        pos++;
        if (defs.containsKey(name)) {
          final String value = defs[name]!;
          input = input.replaceRange(pos - name.length - 1, pos-1, value);
          pos += value.length;
        }
      }
      
      else {
        pos++;
      }
    }
    return input;
  }

  String _getString(final String endChar) {
    String line = '';
    while (pos < input.length && input[pos] != endChar) {
      line += input[pos];
      pos++;
    }
    pos++;
    return line;
  }

  void _processLine() {
    pos++;
    final start = pos - 1;
    final String line = _getString(' ');
    switch (line) {
      case 'def':
        final String name = _getString(' ');
        final String value = _getString('\n');
        input = input.replaceRange(start, pos, '');
        pos = start + value.length;
        defs[name] = value;
        break;
    }
  }

  bool _isLetter(final String c) {
    final int code = c.codeUnitAt(0);
    return (code >= 65 && code <= 90) || (code >= 97 && code <= 122);
  }
}
