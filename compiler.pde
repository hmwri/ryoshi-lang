class compiler {
  Program program;
  errorManager eM;
  ArrayList<Circuit> circuits = new ArrayList<Circuit>();
  int circuitIndex = 0;
  String result;
  exeConfig exeConfig = new exeConfig(1, true);

  compiler(Program _program, errorManager _eM) {
    program=_program;
    eM = _eM;
  }
  String[] compile() throws ryoshiException {
    circuits.add(new Circuit("rc", eM));
    for (Circuit c : circuits) {
      compileCircuit(c);
    }
    StringList result = new StringList();
    result.append("import os");
    result.append("import sys");
    result.append("sys.path.insert(0, os.path.join(os.path.dirname(__file__)))");
    result.append("from ryoshiLibrary import *");
    for (Circuit c : circuits) {
      result.append(c.Str());
    }
    return result.array();
  }
  Circuit compileCircuit(Circuit c) throws ryoshiException {
    boolean isMeasured = false;
    for (Statement s : program.Statements) {
      if (s instanceof Declaration) {
        compileDeclaration((Declaration)s, c);
      }
      if (s instanceof Mark) {
        compileMark((Mark)s, c);
      }
      if (s instanceof Up) {
        compileUp((Up)s, c);
      }
      if (s instanceof Measure) {
        isMeasured = true;
        compileMeasure((Measure)s, c);
      }
      if (s instanceof Config) {
        compileConfig((Config)s);
      }
      if (s instanceof ExpressionStatement) {
        compileExpressionStatement((ExpressionStatement)s, c);
      }
    }
    if (!isMeasured) {
      eM.Panic(305, "観測は必ず一回行ってください");
    }
    c.Exe(exeConfig);
    c.getResult(exeConfig);
    return c;
  }
  boolean isOver(int bit, int number) {
    return number >= (int)pow(2, bit);
  }
  boolean IsAlreadyUsed(Circuit c, String str) {
    for (String s : c.alreadyUsed) {
      if (str.equals(s)) return true;
    }
    return false;
  }
  void compileDeclaration(Declaration d, Circuit c) throws ryoshiException {
    int bit = 0;
    if (d.type.type == tokenes.bool) {
      bit = 1;
    } else {
      bit = d.type.bit;
    }
    String name = d.name;
    if (IsAlreadyUsed(c, name))  eM.Panic(302, String.format("%sという変数名はすでに使われています", name));
    c.alreadyUsed.append(name);
    Register regi = c.MakeRegister(d.type, name);
    if (d.value instanceof Number) {
      Number n = (Number)d.value;
      if (isOver(bit, n.number)) {
        eM.Panic(301, String.format("%sビットの変数に%sは代入できません", bit, n.number));
      }
      c.Write(regi, n.number);
      return;
    }
    if (d.value instanceof Bool) {
      Bool b = (Bool)d.value;
      if (d.type.type == tokenes.bool) {
        c.Write(regi, b.bool ? 1 : 0);
        return;
      }
      eM.Panic(304, String.format("%sはbool型ではないため、true,falseは設定できません。", name));
    }
    if (d.value instanceof Entangle) {
      Entangle e = (Entangle)d.value;
      for (int n : e.nums) {
        if (isOver(bit, n))  eM.Panic(301, String.format("%sビットの変数に%sは代入できません", bit, n));
      }
      if (e.nums.length>2) {
        eM.Panic(901, String.format("現在,任意の重ね合わせにできるのは2個までです。"));
      }
      c.Entangle2(regi, e.nums[0], e.nums[1]);
      return;
    }
    if (d.value instanceof All) {
      c.AllH(regi);
      return;
    }
    if (d.value instanceof Identifer) {
      eM.Panic(303, String.format("値のコピーはできません"));
      return;
    }
    compileExpression(regi, d.value, c);
    //eM.Panic(902, String.format("現在初期値に%sはサポートしていません", d.value.Str()));
  }
  Register compileExpression(Register result, Expression e, Circuit c) throws ryoshiException {
    if (e instanceof Identifer) {
      Identifer i = (Identifer)e;
      return c.getRegister(i.name);
    }
    if (e instanceof Number) {
      Number n = (Number)e;
      Register r = c.AutoMakeRegister(new Types(tokenes.i, getMinBit(n.number)));
      c.Write(r, n.number);
      return r;
    }
    if (e instanceof Infix) {
      Infix i = (Infix)e;
      return compileInfix(result, i, c);
    }
    if (e instanceof Prefix) {
      Prefix p = (Prefix)e;
      return compilePrefix(p, c);
    }
    return null;
  }
  int getMinBit(int n) {
    for (int i=0; i<100; i++) {
      if (n < pow(2, i) ) {
        return i;
      }
    }
    return 100;
  }

  Register compileInfix(Register result, Infix i, Circuit c) throws ryoshiException {
    Register leftRegi = compileExpression(null, i.left, c);
    Register rightRegi = compileExpression(null, i.right, c);
    Register resultRegi = result;
    switch(i.operator) {
    case equalOp:
    case notequal:
      Register help = c.AutoMakeRegister(new Types(tokenes.i, max(rightRegi.bit, leftRegi.bit)));
      if (resultRegi == null) {
        resultRegi =  c.AutoMakeRegister(new Types(tokenes.bool, 1));
      }
      if (i.operator == tokenes.equalOp) {
        c.Equal(leftRegi, rightRegi, help, resultRegi);
      } else {
        c.NotEqual(leftRegi, rightRegi, help, resultRegi);
      }
      return resultRegi;
    case And:
    case Or:
      if (leftRegi.bit != 1 || rightRegi.bit != 1) {
        eM.Panic(104, "and , or の両端はboolである必要があります");
      }
      if (resultRegi == null) {
        resultRegi =  c.AutoMakeRegister(new Types(tokenes.bool, 1));
      }
      if (i.operator == tokenes.And) {
        c.And(leftRegi, rightRegi, resultRegi);
      } else {
        c.Or(leftRegi, rightRegi, resultRegi);
      }
      return resultRegi;
    default:
    }
    return null;
  }
  void compileExpressionStatement(ExpressionStatement ex, Circuit c) throws ryoshiException {
    if (ex.body instanceof Infix) {
      compileInfixStatement((Infix)ex.body,c);
    }else{
      eM.Panic(601,"現在Prefix式文に対応していません");
    }
  }
  void compileInfixStatement(Infix i,Circuit c) throws ryoshiException {
    Register leftRegi = compileExpression(null, i.left, c);
    Register rightRegi = compileExpression(null, i.right, c);
    if (leftRegi == null || rightRegi == null) {
      eM.Panic(308, String.format("右辺または左辺を解析できませんでした at %s", i.operator.name()));
      return;
    }
    if (leftRegi.type.type == tokenes.bool || rightRegi.type.type == tokenes.bool) {
      eM.Panic(308, String.format("右辺または左辺がbooleanです at %s", i.operator.name()));
      return ;
    }
    switch(i.operator) {
    case plusEqual:
      c.PlusEqual(leftRegi, rightRegi);
      break;
    case minusEqual:
      c.MinusEqual(leftRegi, rightRegi);
      break;
    default:
      eM.Panic(306, String.format("%sはステートメントではありません", i.operator.name()));
    }
    return;
  }
  Register compilePrefix(Prefix p, Circuit c) throws ryoshiException {
    Register rightRegi = compileExpression(null, p.right, c);
    switch(p.operator) {
    case not:
      c.Not(rightRegi);
      return rightRegi;
    default:
    }
    return null;
  }
  void compileConfig(Config conf) throws ryoshiException {
    switch(conf.parameter) {
    case "device":
      if (conf.value.equals("simulator")) {
        exeConfig.simulator = true;
      } else if (conf.value.equals("actual")) {
        exeConfig.simulator = false;
      } else {
        eM.Panic(402, String.format("不明な設定値%s", conf.value));
      }
      break;
    case "shots":
      try {
        int value = Integer.parseInt(conf.value);
        exeConfig.shots = value;
      }
      catch(NumberFormatException ex) {
        eM.Panic(402, String.format("不明な設定値%s", conf.value));
      }
      break;
    case "grover":
      try {
        int value = Integer.parseInt(conf.value);
        exeConfig.grover = value;
      }
      catch(NumberFormatException ex) {
        eM.Panic(402, String.format("不明な設定値%s", conf.value));
      }
      break;
    default:
      eM.Panic(401, String.format("不明なパラメーター", conf.parameter));
    }
  }
  void compileMark(Mark m, Circuit c) throws ryoshiException {
    ArrayList<Register> registers = new ArrayList<Register>();
    for (Expression e : m.target) {
      registers.add(compileExpression(null, e, c));
    }
    c.Mark((Register[])registers.toArray(new Register[0]));
  }
  void compileMeasure(Measure m, Circuit c) throws ryoshiException {
    ArrayList<Register> registers = new ArrayList<Register>();
    for (Expression e : m.target) {
      registers.add(compileExpression(null, e, c));
    }
    c.Measure((Register[])registers.toArray(new Register[0]));
  }
  void compileUp(Up u, Circuit c) throws ryoshiException {
    ArrayList<Register> registers = new ArrayList<Register>();
    for (Expression e : u.target) {
      registers.add(compileExpression(null, e, c));
    }
    ArrayList<Register> dependancies = new ArrayList<Register>(registers);
    ArrayList<Function> functions = new ArrayList<Function>();
    ArrayList<Function> invFunctions = new ArrayList<Function>();
    MarkFunc mark  = null;
    for (Function f : c.functions) {
      if (f instanceof MarkFunc) {
        mark = (MarkFunc)f;
      }
      if (isDepending(dependancies, f.entangleRegisters())) {
        if (!f.inv) {
          functions.add(f);
          invFunctions.add(f.getInv());
        }
      };
    }
    if (mark == null) {
      eM.Panic(305, "upを行う前にmarkをしてください");
    }
    for (Function f : functions) {
      c.functions.remove(f);
    };
    c.functions.remove(mark);
    c.Grover(exeConfig.grover, functions, mark, new Diffuser(c, (Register[])registers.toArray(new Register[0])));
  }
  boolean isDepending(ArrayList<Register> dependancies, Register[] entangles) {
    for (Register r : dependancies) {
      if (Arrays.asList(entangles).contains(r)) {
        for (Register res : entangles) {
          dependancies.add(res);
        }
        return true;
      }
    }
    return false;
  }
  //int getBit(tokenes type) {
  //  switch(type) {
  //  case i2:
  //    return 2;
  //  case i3:
  //    return 3;
  //  }
  //}
}
