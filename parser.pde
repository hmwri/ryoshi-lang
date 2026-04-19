enum Priority {
  NOTFOUND(0),
    LOWEST(1),
    LOGIC(2),
    EQUALS(3),
    LESSGREATER(4),
    SUM(5),

    PREFIX(6),
    ;
  private final int id;

  private Priority(final int id) {
    this.id = id;
  }

  public int getInt() {
    return this.id;
  }
}
HashMap<tokenes, Priority> priorities = new HashMap<tokenes, Priority>();

void setupPriorities() {
  priorities.put(tokenes.equalOp, Priority.EQUALS);
  priorities.put(tokenes.notequal, Priority.EQUALS);
  priorities.put(tokenes.plus, Priority.SUM);
  priorities.put(tokenes.plusEqual, Priority.SUM);
  priorities.put(tokenes.minusEqual, Priority.SUM);
  priorities.put(tokenes.minus, Priority.SUM);
  priorities.put(tokenes.And, Priority.LOGIC);
  priorities.put(tokenes.Or, Priority.LOGIC);
  priorities.put(tokenes.number, Priority.LOWEST);
  priorities.put(tokenes.bool, Priority.LOWEST);
  priorities.put(tokenes.comma, Priority.LOWEST);
}

class Parser {
  ArrayList<token> _tokenes;
  int now;
  errorManager eM;
  Parser(ArrayList<token> _tokenes, errorManager em) {
    this._tokenes = _tokenes;
    now = -1;
    eM = em;
  }
  token now() {
    if (now >= _tokenes.size()) return null;
    return _tokenes.get(now);
  }
  Priority nowPriority() throws ryoshiException {
    if (now >= _tokenes.size()) return null;
    if (!priorities.containsKey(now().token)) {
      eM.Panic(306, "予期しない演算子:"+now().str());
      return null;
    }
    return priorities.get(now().token);
  }
  Priority nextPriority() throws ryoshiException {
    if (now+1 >= _tokenes.size()) return null;
    if (!priorities.containsKey(next().token)) {
      eM.Panic(306, "予期しない演算子:"+next().str());
      return null;
    }
    return priorities.get(next().token);
  }
  token next() {
    if (now+1 >= _tokenes.size()) return null;
    return _tokenes.get(now+1);
  }

  token expect(tokenes token) throws ryoshiException {
    if (now+1 >= _tokenes.size()) return null;
    var target = _tokenes.get(now+1);
    if (target.token != token) eM.Panic(200, String.format("except %s but got %s", token.name(), target.token.name()));
    now++;
    return target;
  }
  token expect(tokenes token1, tokenes token2) throws ryoshiException {
    if (now+1 >= _tokenes.size()) return null;
    var target = _tokenes.get(now+1);
    if (target.token != token1 && target.token != token2) eM.Panic(200, String.format("except %s or %s but got %s", token1.name(), token2.name(), target.token.name()));
    now++;
    return target;
  }
  token next(int n) {
    if (now+n >= _tokenes.size()) return null;
    return _tokenes.get(now+n);
  }
  token read() {
    now++;
    return now();
  }
  Program parse() throws ryoshiException {
    Program program = new Program();
    while (next() != null) {
      Statement stmt = parseStatement();
      if (stmt != null) {
        program.Add(stmt);
      }
    }
    return program;
  }

  Statement parseStatement() throws ryoshiException {
    tokenes tok = read().token;
    switch(tok) {
    case i:
    case bool:
      return parseDeclaration();
    case question:
      return parseMeasure();
    case atmark:
      return parseConfig();
    case up:
      return parseUp();
    case mark:
      return parseMark();
    case semiColon:
      return null;
    default:
      return parseExpressionStatement();
    }
  }
  ExpressionStatement parseExpressionStatement() throws ryoshiException {
    Expression expr = parseExpression(Priority.LOWEST);
    println(expr);
    if (next().token == tokenes.semiColon) {
      read();
    }
    return new ExpressionStatement(expr);
  }
  Expression parseExpression(Priority prio) throws ryoshiException {
    Expression left = parsePrefix();
    if (left == null) {
      eM.Add(102, String.format("%s を解析できませんでした。", now().str()));
    }
    if (next() == null) return null;
    while (!(next().token==tokenes.semiColon) && prio.getInt() < nextPriority().getInt()) {
      left = parseInfix(next(), left);
    }
    return left;
  }

  Expression parsePrefix() throws ryoshiException {
    switch(now().token) {
    case keyword:

      return parseIdent();


    case number:
      return parseNumber();
    case all:
      return parseAll();
    case True:
      return parseTrue();
    case False:
      return parseFalse();
    case not:
    case minus:
      return parsePrefixExpression();
    case lparam:
      return parseGroup();
    default:
      return null;
    }
  }
  Expression parseInfix(token token, Expression left) throws ryoshiException {
    switch(token.token) {
    case plus:
    case plusEqual:
    case minusEqual:
    case minus:
    case equalOp:
    case notequal:
    case And:
    case Or:
      read();
      return parseInfixExpression(left);
    default:
      eM.Panic(204, "無効な演算子:"+token.str());
      return null;
    }
  }
  Expression parseInfixExpression(Expression left) throws ryoshiException {
    tokenes operator = now().token;
    Priority prio = nowPriority();
    read();
    Expression right = parseExpression(prio);
    if (right == null) {
      eM.Panic(101, "右辺がありません"+operator.name());
    }
    return new Infix(left, operator, right);
  }
  Expression parsePrefixExpression() throws ryoshiException {
    tokenes operator = now().token;
    read();
    Expression expr = parseExpression(Priority.PREFIX);
    return new Prefix(operator, expr);
  }
  Expression parseGroup() throws ryoshiException {
    println("parse group");
    read();
    Expression expr = parseExpression(Priority.LOWEST);
    if (next().token != tokenes.rparam) {
      print("here");
      return null;
    }
    read();
    return expr;
  }
  Identifer parseIdent() {
    return new Identifer(now().body);
  }
  Bool parseTrue() {
    return new Bool(true);
  }
  Bool parseFalse() {
    return new Bool(false);
  }
  All parseAll() {
    return new All();
  }
  Value parseNumber() throws ryoshiException {
    if (next().token == tokenes.vertical) {
      return parseEntangle();
    }
    return new Number(Integer.parseInt(now().body));
  }
  Entangle parseEntangle() throws ryoshiException {
    IntList ints = new IntList();
    while (now().token == tokenes.number) {
      ints.append(Integer.parseInt(now().body));
      if (next() != null && next().token == tokenes.vertical) {
        read();
        expect(tokenes.number);
      } else {
        break;
      }
    }
    return  new Entangle(ints.array());
  }
  Declaration parseDeclaration() throws ryoshiException {
    token type = now();
    String name = expect(tokenes.keyword).body;
    if (next().token == tokenes.semiColon) {
      read();
      return new Declaration(new Types(type), name, new Number(0));
    }
    expect(tokenes.equal);
    read();
    Expression expr = parseExpression(Priority.LOWEST);
    if (next().token == tokenes.semiColon) {
      read();
    }
    return new Declaration(new Types(type), name, expr);
  }
  Config parseConfig() throws ryoshiException {
    String parameter = expect(tokenes.keyword).body;
    String value = expect(tokenes.keyword, tokenes.number).body;
    if (next().token == tokenes.semiColon) {
      read();
    }
    return new Config(parameter, value);
  }
  Measure parseMeasure() throws ryoshiException {
    ArrayList<Identifer> targets = new ArrayList<Identifer>();
    while (true) {
      read();
      Expression ex = parseExpression(Priority.LOWEST);
      if (ex == null ) eM.Panic(305, "measure　の対象を用意してくだい");
      if (!(ex instanceof Identifer)) eM.Panic(304, "measureの対象は変数のみ有効です");
      Identifer target = (Identifer)ex;
      targets.add(target);
      if (next().token == tokenes.comma) {
        read();
      } else {
        break;
      }
    }
    if (next() != null && next().token == tokenes.semiColon) {
      read();
    }
    return new Measure(targets);
  }
  Statement parseUp() throws ryoshiException {
    ArrayList<Identifer> targets = new ArrayList<Identifer>();
    while (true) {
      read();
      Expression ex = parseExpression(Priority.LOWEST);
      if (ex == null ) eM.Panic(305, "up　の対象を用意してくだい");
      if (!(ex instanceof Identifer)) eM.Panic(304, "upの対象は変数のみ有効です");
      Identifer target = (Identifer)ex;
      targets.add(target);
      if (next().token == tokenes.comma) {
        read();
      } else {
        break;
      }
    }
    if (next() != null && next().token == tokenes.semiColon) {
      read();
    }
    return new Up(targets);
  }
  Statement parseMark() throws ryoshiException {
    ArrayList<Expression> expressions = new ArrayList<Expression>();
    while (true) {
      read();
      Expression target = parseExpression(Priority.LOWEST);
      expressions.add(target);
      if (next().token == tokenes.comma) {
        read();
      } else {
        break;
      }
    }
    if (next() != null && next().token == tokenes.semiColon) {
      read();
    }
    return new Mark(expressions);
  }
}
