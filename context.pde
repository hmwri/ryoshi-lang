import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;


class context {
  lexer l ;
  errorManager eM;
  context(String code) {
    code+=";";
    println(code);
    ui.resetConsole();
    eM = new errorManager();
    l = new lexer(code, eM);
  }
  void exe() throws Exception {
    ui.right.console = true;
    ui.addConsole("compiler","字句解析開始");
    ArrayList<token> result =  l.lex();
    ui.addConsole("compiler","字句解析完了");
     ui.addConsole("compiler","構文解析開始");
    Parser parser = new Parser(result, eM);
    Program program = parser.parse();
    ui.addConsole("compiler","構文解析完了");
    print(program.Str());
    ui.addConsole("compiler","コード生成開始");
    compiler c = new compiler(program, eM);
    String[] str = c.compile();
    ui.addConsole("compiler","VV コード生成完了 VV");
    
    println("result:");
    int i = 0;
    for (String s : str) {
      i++;
      ui.addConsole(i+"",s);
    }
    ui.addConsole("editor","生成したコードをPythonで実行します");
    saveStrings("data/compiled.py", str);
    File dataDir = new File(dataPath(""));
    String pythonPath = resolvePythonPath();
    ProcessBuilder pb = new ProcessBuilder(pythonPath, "-u", new File(dataDir, "compiled.py").getAbsolutePath());
    pb.directory(dataDir);
    pb.environment().put("MPLCONFIGDIR", sketchPath(".matplotlib"));
    pb.redirectErrorStream(true);
    Process  p  = pb.start();
    pythonFinished = false;
    BufferedReader br = new BufferedReader(new InputStreamReader(p.getInputStream()));
    String stdout = "";
    while (stdout != null) {
      stdout=br.readLine();
      if(stdout!=null && !stdout.isEmpty()){
        ui.addConsole("python",stdout);
      }
      
    }
    pythonFinished = true;
    String[] empty = {""};
    saveStrings("data/log.txt", empty);
    ui.addConsole("editor","pythonから結果を受け取り表示します");
    ui.right.result.si = 0;
    ui.right.console = false;
    eM.print();
  }

  String resolvePythonPath() {
    String[] candidates = {
      sketchPath(".venv/bin/python"),
      sketchPath("venv/bin/python"),
      "/opt/homebrew/bin/python3",
      "/usr/local/bin/python3"
    };
    for (String candidate : candidates) {
      File file = new File(candidate);
      if (file.exists() && file.canExecute()) {
        return file.getAbsolutePath();
      }
    }
    return "python3";
  }
}
