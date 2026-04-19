import java.util.Arrays;
import java.util.List;


char EOF = '\0';

class Pair<A, B> {
  final A left;
  final B right;
  Pair(A l, B r) {
    left = l;
    right = r;
  }
}

class lexer {
  String body;
  errorManager eM;
  int now;
  ArrayList<token> result = new ArrayList<token>();


  lexer(String _body, errorManager _em) {
    body = _body;
    now = -1;
    eM = _em;
  }

  char now() {
    if (now >= body.length()) return EOF;
    return body.charAt(now);
  }

  char next() {
    if (now+1 >= body.length()) return EOF;
    return body.charAt(now+1);
  }

  char next(int n) {
    if (now+n >= body.length()) return EOF;
    return body.charAt(now+n);
  }

  char read() {
    now++;
    return now();
  }

  void skip() {
    if (next() == EOF || !isWhite(next()))
      return;
    read();
    skip();
  }

  void skipComment() {
    if (next() == EOF || next() == '\n' || next() == ';')
      return;
    read();
    skipComment();
  }


  boolean isNum(char c) {
    return Character.isDigit(c);
  }

  boolean isWhite(char c) {
    if (c == '\n') return false;
    return Character.isWhitespace(c);
  }

  boolean isWord(char c) {
    char[] excludes = { '?', ',', '=', '!', ':', ')', '(', '#', '@', ';' ,'+','-'};
    for (char e : excludes) {
      if (e == c) {
        return false;
      }
    }
    return !Character.isWhitespace(c);
  }

  String readNum() {
    String result = String.valueOf(now());
    while (next() != EOF && isNum(next())) {
      result+=read();
    }
    return result;
  }

  String readWord() {
    String result = String.valueOf(now());
    while (next() != EOF && isWord(next())) {
      result+=read();
    }
    return result;
  }
  Pair<Boolean, token> isType(String str) {

    if (str.length() < 4) {
      return new Pair(false, null);
    }
    if (str.substring(0, 3).equals("int") && str.substring(3, str.length()).matches("[+-]?\\d*(\\.\\d+)?")) {
      return new Pair(true, new token(tokenes.i, str.substring(3, str.length())));
    }
    return new Pair(false, null);
  }
  ArrayList<token> lex() {
    l();
    for (token r : result) {
      r.print();
    }
    return result;
  }

  void l() {
    println(now);
    skip();
    if (next() == EOF) {
      return;
    }
    char r = read();
    
    if (isNum(r)) {
      result.add(new token(tokenes.number, readNum()));
      l();
      return;
    }
    if (next() == '/' && r == '/') {
      read();
      skipComment();
      l();
      return;
    }
    
    switch(r) {

    case ',':
      result.add(new token(tokenes.comma));
      l();
      break;
    case '=':
      if (next() == '=') {
        result.add(new token(tokenes.equalOp));
        read();
      } else {
        result.add(new token(tokenes.equal));
      }
      l();
      break;
    case '!':
      if (next() == '=') {
        result.add(new token(tokenes.notequal));
        read();
      } else {
        result.add(new token(tokenes.not));
      }
      l();
      break;
    case '?':
      result.add(new token(tokenes.question));
      l();
      break;
    case '|':
      result.add(new token(tokenes.vertical));
      l();
      break;
    case '#':
      result.add(new token(tokenes.sharp));
      l();
      break;
    case '-':
      if (next() == '=') {
        result.add(new token(tokenes.minusEqual));
        read();
      } else {
        result.add(new token(tokenes.minus));
      }
      l();
      break;
    case '+':
      if (next() == '=') {
        result.add(new token(tokenes.plusEqual));
        read();
      } else {
        result.add(new token(tokenes.plus));
      }
      l();
      break;
    case ';':
      result.add(new token(tokenes.semiColon));
      l();
      break;
    case '@':
      result.add(new token(tokenes.atmark));
      l();
      break;
    case '(':
      result.add(new token(tokenes.lparam));
      l();
      break;
    case ')':
      result.add(new token(tokenes.rparam));
      l();
      break;
    case '\n':
      if (result.size()>0 && result.get(result.size() - 1).token != tokenes.semiColon) {
        result.add(new token(tokenes.semiColon));
      }
      l();
      break;
    default:
      String word = readWord();
      tokenes token = tokenNames.get(word);
      if (token != null) {
        result.add(new token(token));
        l();
        return;
      }
      var isType = isType(word);
      if (isType.left) {
        result.add(isType.right);
      } else {
        result.add(new token(tokenes.keyword, word));
      }
      l();
    }
  }
}
