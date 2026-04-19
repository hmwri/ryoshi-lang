class Program {
  ArrayList<Statement> Statements = new ArrayList<Statement>();

  void Add(Statement stmt) {
    this.Statements.add(stmt);
  }
 
  
  String Str() {
    String result = "";
    for (Statement s : Statements) {
      result += s.Str();
    }
    return result;
  }
}

interface Statement {
  String Str() ;
}
class Types {
  tokenes type;
  int bit = 0;
  Types(token token){
    this.type = token.token;
    if(type == tokenes.bool){
      this.bit = 1;
      return;
    }
    if(token.body!=null){
      this.bit = Integer.parseInt(token.body);
    }
    
  }
  Types(tokenes token, int _bit){
    this.type = token;
    this.bit = _bit;
  }
 String str(){
   return String.format("%s:%d",type.name(),bit);
 }
}

class Declaration implements Statement {
  Types type;
  String name;
  Expression value;
  Declaration(Types _type, String _name, Expression _value) {
    type = _type;
    name = _name;
    value = _value;
  }
  String Str() {
    return String.format("[Declaration  type:%s,name:%s,value:%s]", type.str(), name, value.Str());
  }
  String Compile(){
    return "";
  }
}

class Measure implements Statement {
  ArrayList<Identifer> target;
  Measure(ArrayList<Identifer> _target) {
    target= _target;
  }
  String Str() {
    String result = "";
    for(Identifer ex :target){
      result+=","+ex.Str();
    }
    return String.format("[Measure %s]", result);
  }
}

class Up implements Statement {
  ArrayList<Identifer> target;
  Up(ArrayList<Identifer> _target) {
    target= _target;
  }
  String Str() {
     String result = "";
    for(Identifer ex :target){
      result+=","+ex.Str();
    }
    return String.format("[Up %s]", result);
  }
}
class Mark implements Statement {
  ArrayList<Expression> target;
  Mark(ArrayList<Expression> _target) {
    target= _target;
  }
  String Str() {
    String result = "";
    for(Expression ex :target){
      result+=","+ex.Str();
    }
    return String.format("[Mark %s]", result);
  }
}


interface Expression {
  String Str();
}

class Value implements Expression {
  String Str() {
    return String.format("Value");
  }
}

class All extends Value {
  String Str() {
    return String.format("[All]");
  }
}

class Entangle extends Value {
  int[] nums;
  String Str() {
    String[] strArray = new String[nums.length];

    for (int i = 0; i < nums.length; i++) {
      strArray[i] = String.valueOf(nums[i]);
    }
    String str = String.join(",", strArray);
    return String.format("[Engangle %s]", str);
  }
  Entangle(int[] _nums) {
    nums = _nums;
  }
}

class Number extends Value {
  int number;
  Number(int n) {
    number = n;
  }
  String Str() {
    return String.format("[Number %s]", number);
  }
}

class Bool extends Value {
  boolean bool;
  String Str() {
    return String.format("[Bool %b]", bool);
  }
  Bool(boolean b) {
    bool = b;
  }
}

class Identifer implements Expression  {
  String name;
  String Str() {
    return String.format("[Identifier %s]", name);
  }
  Identifer (String _name) {
    name = _name;
  }
}
class Config implements Statement {
  String parameter;
  String value;
  String Str() {
    return String.format("[config %s : %s]", parameter,value);
  }
  Config (String _parameter,String _value) {
    parameter = _parameter;
    value = _value;
  }
}


class Prefix implements Expression, Statement {
  tokenes operator;
  Expression right;
  Prefix(tokenes token,Expression expr) {
    operator = token;
    right = expr;
  }
  String Str() {
    return String.format("[Prefix %s, %s]", operator.name(), right.Str());
  }
}

class Infix implements Expression, Statement {
  Expression left;
  tokenes operator;
  Expression right;
  Infix(Expression _left,tokenes token,Expression _right) {
    left = _left;
    operator = token;
    right = _right;
  }
  String Str() {
    return String.format("[Infix %s, %s, %s]", left.Str(),operator.name(), right.Str());
  }
}

class ExpressionStatement implements Statement{
  Expression body;
  ExpressionStatement(Expression _body){
    body= _body;
  }
    String Str() {
    return String.format("[Expression Statement %s]", body.Str());
  }
}
