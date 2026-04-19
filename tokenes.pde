enum tokenes {
  comma,
  equal,
  not,
  equalOp,
  notequal,
  plus,
  minus,
  vertical,
  question,
  sharp,
  semiColon,
  i,
  bool,
  mark,
  all,
  number,
  True,
  False,
  And,
  Or,
  up,
  keyword,
  atmark,
  rparam,
  lparam,
  plusEqual,
  minusEqual
}



class token {
 tokenes token;
 String body;
 token(tokenes _token) {
   token = _token;
 }
 token(tokenes _token,String _body) {
   token = _token;
   body = _body;
 }
 void print(){
   println(this.str());
 }
 String str(){
   if(body == null){
      return token.name();
   }
   return "token:"+token.name()+";"+body;
 }
 
}

HashMap<String,tokenes> tokenNames = new HashMap<String,tokenes>();

void setupTokenNames() {
  tokenNames.put("bool",tokenes.bool);
  tokenNames.put("mark",tokenes.mark);
  tokenNames.put("all",tokenes.all);
  tokenNames.put("true",tokenes.True);
  tokenNames.put("false",tokenes.False);
  tokenNames.put("and",tokenes.And);
  tokenNames.put("or",tokenes.Or);
  tokenNames.put("up",tokenes.up);
}
