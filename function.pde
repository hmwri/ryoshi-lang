abstract class Function implements Cloneable {
  Circuit circuit;
  boolean inv = false;
  Function(Circuit c) {
    circuit = c;
  }
  abstract String Str();
  abstract Register[] entangleRegisters();
  @Override
    public Function clone() throws CloneNotSupportedException {
    Function clone = (Function) super.clone();
    return clone;
  }
  Function getInv() {
    Function result = null;
    try {
      result = this.clone();
    }
    catch(CloneNotSupportedException e) {
      print(e);
    }
    if (result != null)
      result.inv = true;
    return result;
  }
}

enum Author {
  User,
    Compiler,
}

class Register {
  String name;
  int bit;
  Types type;
  Author author;
  Register(String _name, int _bit, Types _type, Author _author) {
    name = _name;
    bit = _bit;
    author = _author;
    type = _type;
  }
}

class Circuit {
  String name;
  ArrayList<Function> functions = new ArrayList<Function>();
  HashMap<String, Register> registers = new HashMap<String, Register>();
  StringList alreadyUsed = new StringList();
  errorManager eM;
  int registerName = 0;
  Circuit(String _name, errorManager _eM) {
    eM = _eM;
    name = _name;
  }

  StringList Str() {
    StringList result = new StringList();
    result.append(String.format("%s = ryoshiCircuit(name='%s')", name, name));
    for (Function f : functions) {
      result.append(f.Str());
    }
    return result;
  }

  void Add(Function function) {
    functions.add(function);
  }

  Register getRegister(String _name) throws ryoshiException
  {
    var r = registers.get(_name);
    if (r == null) {
      eM.Panic(302, String.format("%sという値は見つかりません", _name));
      return null;
    }
    return r;
  }

  Register AutoMakeRegister(Types type) {
    String name = String.format("%d", registerName);
    Add(new MakeRegister(this, type.bit, name, Author.Compiler));
    Register register= new Register(name, type.bit, type, Author.Compiler);
    registers.put(name, register);
    registerName++;
    return register;
  }
  Register MakeRegister(Types type, String _name) {
    Register regi = new Register(_name, type.bit, type, Author.User);
    registers.put(_name, regi);
    Add(new MakeRegister(this, type.bit, _name, Author.User));
    return regi;
  }

  void Write(Register target, int num) {
    Add(new Write(this, target, num));
  }
  void Entangle2(Register target, int num1, int num2) {
    Add(new Entangle2(this, target, num1, num2));
  }
  void AllH(Register target) {
    Add(new AllH(this, target));
  }
  void Equal(Register target1, Register target2, Register help, Register result) {
    Add(new Equal(this, target1, target2, help, result));
  }
  void NotEqual(Register target1, Register target2, Register help, Register result) {
    Add(new NotEqual(this, target1, target2, help, result));
  }
  void And(Register target1, Register target2, Register result) {
    Add(new And(this, target1, target2, result));
  }
  void Or(Register target1, Register target2, Register result) {
    Add(new Or(this, target1, target2, result));
  }
  void Not(Register target1) {
    Add(new Not(this, target1));
  }
  void Mark(Register[] target) {
    Add(new MarkFunc(this, target));
  }
  void Measure(Register[] target) {
    Add(new MeasureFunc(this, target));
  }
  void Diffuser(Register[] target) {
    Add(new Diffuser(this, target));
  }
  void Exe(exeConfig config) {
    Add(new Exe(this, config));
  }
  void getResult(exeConfig config) {
    Add(new getResult(this, config));
  }
  void PlusEqual(Register target1, Register target2){
     Add(new PlusEqual(this, target1, target2));
  }
    void MinusEqual(Register target1, Register target2){
     Add(new MinusEqual(this, target1, target2));
  }
  void Grover(float m,ArrayList<Function> _funcs,MarkFunc _mark,Diffuser diffuse){
    int n = 0;
    for(Register regi : diffuse.targets){
      n += regi.bit;
    }
    float num = sqrt(pow(2,n)/m);
    int N = round(num);
    println(num);
    for(int i=0;i<m;i++){
      Add(new Grover(this,_funcs,_mark,diffuse));
    }
  }
}
class MakeRegister extends Function {
  int bit;
  String name;
  Author author;
  MakeRegister(Circuit _circuit, int _bit, String _name, Author _author) {
    super(_circuit);
    circuit = _circuit;
    bit = _bit;
    name = _name;
    author = _author;
  }
  String Str() {
    var s = "%s.makeRegister(name='%s',bit=%d,author=AuthorType.%s)";
    return String.format(s, circuit.name, name, bit, author.name());
  }
  Register[] entangleRegisters() {
    return new Register[0];
  }
}

class AllH extends Function {
  Register target;
  AllH(Circuit _circuit, Register _target) {
    super(_circuit);
    target=_target;
  }
  String Str() {
    var s = "%s.AllH('%s')";
    return String.format(s, circuit.name, target.name);
  }
  Register[] entangleRegisters() {
    return new Register[0];
  }
}
class Write extends Function {
  Register target;
  int num;
  Write(Circuit _circuit, Register _target, int _num) {
    super(_circuit);
    target=_target;
    num = _num;
  }
  String Str() {
    var s = "%s.write('%s',%d)";
    return String.format(s, circuit.name, target.name, num);
  }
  Register[] entangleRegisters() {
    return new Register[0];
  }
}

class Entangle2 extends Function {
  int num1;
  int num2;
  Register target;
  Entangle2(Circuit _circuit, Register name, int _num1, int _num2) {
    super(_circuit);
    target = name;
    num1 = _num1;
    num2 = _num2;
  }
  String Str() {
    var s = "%s.Entangle2('%s',%d,%d)";
    return String.format(s, circuit.name, target.name, num1, num2);
  }
  Register[] entangleRegisters() {
    return new Register[0];
  }
}
class MarkFunc extends Function {
  Register[] targets;

  MarkFunc(Circuit _circuit, Register[] _targets) {
    super(_circuit);
    targets = _targets;
  }
  String Str() {
    String result = "";
    for (Register r : targets) {
      result  += "'"+r.name+"',";
    }
    result = result.substring(0, result.length()-1);
    var s = "%s.mark(%s)";
    return String.format(s, circuit.name, result);
  }
  Register[] entangleRegisters() {
    return new Register[0];
  }
}
class MeasureFunc extends Function {
  Register[] targets;

  MeasureFunc(Circuit _circuit, Register[] _targets) {
    super(_circuit);
    targets = _targets;
  }
  String Str() {
    String result = "";
    for (Register r : targets) {
      result  += "'"+r.name+"',";
    }
    result = result.substring(0, result.length()-1);
    var s = "%s.measure(%s)";
    return String.format(s, circuit.name, result);
  }
  Register[] entangleRegisters() {
    return new Register[0];
  }
}
class Equal extends Function {
  Register left;
  Register right;
  Register help;
  Register result;

  Equal(Circuit _circuit, Register _left, Register _right, Register _help, Register _result) {
    super(_circuit);
    left = _left;
    right = _right;
    help = _help;
    result= _result;
  }
  String Str() {
    var s = inv ? "%s.inv_equal('%s','%s','%s','%s')"  :"%s.equal('%s','%s','%s','%s')";
    return String.format(s, circuit.name, left.name, right.name, help.name, result.name);
  }
  Register[] entangleRegisters() {
    Register[] regi = {left, right, help, result};
    return  regi;
  }
}

class NotEqual extends Function {
  Register  left;
  Register  right;
  Register  help;
  Register  result;

  NotEqual(Circuit _circuit, Register _left, Register _right, Register _help, Register _result) {
    super(_circuit);
    left = _left;
    right = _right;
    help = _help;
    result= _result;
  }
  String Str() {
    var s = inv ? "%s.inv_notequal('%s','%s','%s','%s')" : "%s.notequal('%s','%s','%s','%s')";
    return String.format(s, circuit.name, left.name, right.name, help.name, result.name);
  }
  Register[] entangleRegisters() {
    Register[] regi = {left, right, help, result};
    return  regi;
  }
}
class And extends Function {
  Register left;
  Register right;
  Register result;

  And(Circuit _circuit, Register _left, Register _right, Register _result) {
    super(_circuit);
    left = _left;
    right = _right;
    result= _result;
  }
  String Str() {
    var s = inv ? "%s.inv_And('%s','%s','%s')" : "%s.And('%s','%s','%s')";
    return String.format(s, circuit.name, left.name, right.name, result.name);
  }
  Register[] entangleRegisters() {
    Register[] regi = {left, right, result};
    return  regi;
  }
}
class Not extends Function {
  Register target;

  Not(Circuit _circuit, Register _target) {
    super(_circuit);
    target = _target;
  }
  String Str() {
    var s = "%s.Not('%s')";
    return String.format(s, circuit.name, target.name);
  }
  Register[] entangleRegisters() {
    Register[] regi = {target};
    return  regi;
  }
}
class Or extends Function {
  Register left;
  Register right;
  Register result;

  Or(Circuit _circuit, Register _left, Register _right, Register _result) {
    super(_circuit);
    left = _left;
    right = _right;
    result= _result;
  }
  String Str() {
    var s = inv ?  "%s.inv_Or('%s','%s','%s')" : "%s.Or('%s','%s','%s')";
    return String.format(s, circuit.name, left.name, right.name, result.name);
  }
  Register[] entangleRegisters() {
    Register[] regi = {left, right, result};
    return  regi;
  }
}
class Diffuser extends Function {
  Register[] targets;

  Diffuser(Circuit _circuit, Register[] _targets) {
    super(_circuit);
    targets = _targets;
  }
  String Str() {
    String result = "";
    for (Register r : targets) {
      result  += "'"+r.name+"',";
    }
    result = result.substring(0, result.length()-1);
    var s = "%s.diffuser(%s)";
    return String.format(s, circuit.name, result);
  }
  Register[] entangleRegisters() {
    return new Register[0];
  }
}
class Exe extends Function {
  exeConfig config;

  Exe(Circuit _circuit, exeConfig conf) {
    super(_circuit);
    config = conf;
  }
  String Str() {
    if (config.simulator) {
      var s = "%s.exe_sim(shots=%s)";
      return String.format(s, circuit.name, config.shots);
    }else{
      var s = "%s.exe_actual(shots=%s)";
      return String.format(s, circuit.name, config.shots);
    }
  }
  Register[] entangleRegisters() {
    return new Register[0];
  }
}
class getResult extends Function {
  exeConfig config;

  getResult(Circuit _circuit, exeConfig conf) {
    super(_circuit);
    config = conf;
  }
  String Str() {
    var s = "%s.get_result()";
    return String.format(s, circuit.name);
  }
  Register[] entangleRegisters() {
    return new Register[0];
  }
}
class PlusEqual extends Function {
  Register left;
  Register right;

  PlusEqual(Circuit _circuit, Register _left, Register _right) {
    super(_circuit);
    left = _left;
    right = _right;
  }
  String Str() {
    var s = inv ? "%s.minusEqual('%s','%s')" : "%s.plusEqual('%s','%s')";
    return String.format(s, circuit.name, left.name, right.name);
  }
  Register[] entangleRegisters() {
    Register[] regi = {left, right};
    return  regi;
  }
}
class MinusEqual extends Function {
  Register left;
  Register right;

  MinusEqual(Circuit _circuit, Register _left, Register _right) {
    super(_circuit);
    left = _left;
    right = _right;
  }
  String Str() {
    var s = inv ? "%s.plusEqual('%s','%s')" : "%s.minusEqual('%s','%s')";
    return String.format(s, circuit.name, left.name, right.name);
  }
  Register[] entangleRegisters() {
    Register[] regi = {left, right};
    return  regi;
  }
}
class Grover extends Function {
  ArrayList<Function> functions = new ArrayList<Function>();
  MarkFunc mark = null;
  Diffuser diffuser = null;
  Grover(Circuit _circuit,ArrayList<Function> _funcs,MarkFunc _mark,Diffuser d){
    super(_circuit);
    functions = _funcs;
    mark = _mark;
    diffuser = d;
  }
   Register[] entangleRegisters() {
    return new Register[0];
  }
  String Str() {
    String result = "";
    for(Function f : functions){
      result += f.Str() + "\n";
    }
    result += mark.Str() + "\n";
    for (int i=functions.size() - 1; i >= 0; i--) {
      result += functions.get(i).getInv().Str() + "\n";
    }
    result += diffuser.Str() + "\n";
    return result;
  }
}
