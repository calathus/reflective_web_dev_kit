part of json_mapper_v1;

//
// Following code are not modified, copied from dart:json
// since this class is private, in order to extend it, I needed to copy here! 
// ideally, this class should be changed to public, _JsonStringifier => JsonStringifier
//
class _JsonStringifier {
  StringSink sink;
  List<Object> seen;  // TODO: that should be identity set.

  _JsonStringifier(this.sink) : seen = [];

  static String stringify(final object) {
    StringBuffer output = new StringBuffer();
    _JsonStringifier stringifier = new _JsonStringifier(output);
    stringifier.stringifyValue(object);
    return output.toString();
  }

  static void printOn(final object, StringSink output) {
    _JsonStringifier stringifier = new _JsonStringifier(output);
    stringifier.stringifyValue(object);
  }

  static String numberToString(num x) {
    return x.toString();
  }

  // ('0' + x) or ('a' + x - 10)
  static int hexDigit(int x) => x < 10 ? 48 + x : 87 + x;

  static void escape(StringSink sb, String s) {
    final int length = s.length;
    bool needsEscape = false;
    final charCodes = new List<int>();
    for (int i = 0; i < length; i++) {
      int charCode = s.codeUnitAt(i);
      if (charCode < 32) {
        needsEscape = true;
        charCodes.add(JsonParser.BACKSLASH);
        switch (charCode) {
        case JsonParser.BACKSPACE:
          charCodes.add(JsonParser.CHAR_b);
          break;
        case JsonParser.TAB:
          charCodes.add(JsonParser.CHAR_t);
          break;
        case JsonParser.NEWLINE:
          charCodes.add(JsonParser.CHAR_n);
          break;
        case JsonParser.FORM_FEED:
          charCodes.add(JsonParser.CHAR_f);
          break;
        case JsonParser.CARRIAGE_RETURN:
          charCodes.add(JsonParser.CHAR_r);
          break;
        default:
          charCodes.add(JsonParser.CHAR_u);
          charCodes.add(hexDigit((charCode >> 12) & 0xf));
          charCodes.add(hexDigit((charCode >> 8) & 0xf));
          charCodes.add(hexDigit((charCode >> 4) & 0xf));
          charCodes.add(hexDigit(charCode & 0xf));
          break;
        }
      } else if (charCode == JsonParser.QUOTE ||
          charCode == JsonParser.BACKSLASH) {
        needsEscape = true;
        charCodes.add(JsonParser.BACKSLASH);
        charCodes.add(charCode);
      } else {
        charCodes.add(charCode);
      }
    }
    sb.write(needsEscape ? new String.fromCharCodes(charCodes) : s);
  }

  void checkCycle(final object) {
    // TODO: use Iterables.
    for (int i = 0; i < seen.length; i++) {
      if (identical(seen[i], object)) {
        throw new JsonCyclicError(object);
      }
    }
    seen.add(object);
  }

  void stringifyValue(final object) {
    // Tries stringifying object directly. If it's not a simple value, List or
    // Map, call toJson() to get a custom representation and try serializing
    // that.
    if (!stringifyJsonValue(object)) {
      checkCycle(object);
      try {
        var customJson = object.toJson();
        if (!stringifyJsonValue(customJson)) {
          throw new JsonUnsupportedObjectError(object);
        }
        seen.removeLast();
      } catch (e) {
        throw new JsonUnsupportedObjectError(object, cause: e);
      }
    }
  }

  /**
   * Serializes a [num], [String], [bool], [Null], [List] or [Map] value.
   *
   * Returns true if the value is one of these types, and false if not.
   * If a value is both a [List] and a [Map], it's serialized as a [List].
   */
  bool stringifyJsonValue(final object) {
    if (object is num) {
      // TODO: use writeOn.
      sink.write(numberToString(object));
      return true;
    } else if (identical(object, true)) {
      sink.write('true');
      return true;
    } else if (identical(object, false)) {
      sink.write('false');
       return true;
    } else if (object == null) {
      sink.write('null');
      return true;
    } else if (object is String) {
      sink.write('"');
      escape(sink, object);
      sink.write('"');
      return true;
    } else if (object is List) {
      checkCycle(object);
      List a = object;
      sink.write('[');
      if (a.length > 0) {
        stringifyValue(a[0]);
        // TODO: switch to Iterables.
        for (int i = 1; i < a.length; i++) {
          sink.write(',');
          stringifyValue(a[i]);
        }
      }
      sink.write(']');
      seen.removeLast();
      return true;
    } else if (object is Map) {
      checkCycle(object);
      Map<String, Object> m = object;
      sink.write('{');
      bool first = true;
      m.forEach((String key, Object value) {
        if (!first) {
          sink.write(',"');
        } else {
          sink.write('"');
        }
        escape(sink, key);
        sink.write('":');
        stringifyValue(value);
        first = false;
      });
      sink.write('}');
      seen.removeLast();
      return true;
    } else {
      return false;
    }
  }
}

