HashMap<String,String> errorMessages = new HashMap<>();
errorManager errorManager = new errorManager();

class error {
  int code;
  String message = "";
  tokenes[] token;
  error(int _code, String _message){
    code = _code;
    message = _message;
  }
  void print(){
    Integer i = Integer.valueOf(code);
    String message = "["+i.toString()+"] : "+this.message;
    println(message);
  }
   String str(){
     Integer i = Integer.valueOf(code);
     String message = "["+i.toString()+"] : "+this.message;
     return message;
  }

}

class errorManager {
  ArrayList<error> errors = new ArrayList<error>();
  errorManager(){
    
  }
  void Add(int _code, String message) {
    error e = new error(_code,message);
    errors.add(e);
  }
  void Panic(int _code, String message) throws ryoshiException{
    error e = new error(_code,message);
    errors.add(e);
    throw new ryoshiException(e.str());
  }
  void print(){
    for (error e : errors) {
      e.print();
    }
  }
}
public class ryoshiException extends Exception{
  private static final long serialVersionUID = 1L; 
  ryoshiException(String message){
    super(message);
  }
}
