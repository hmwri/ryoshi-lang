ui_master ui;
boolean pythonSetupInProgress = false;
boolean pythonReady = false;

void setup() {
  init();
  surface.setResizable( true );
  //testLexer();
  size(1000, 800);
  ui = new ui_master();
  ui.init();
  PFont font = loadFont("SourceHanCodeJP-Normal.vlw");
  textFont(font);
  ensurePythonRuntime();
}

void init() {
  setupTokenNames();
  setupPriorities();
}


void draw() {
  background(#242F4B);
  ui.draw();
}

void testLexer() {
  String[] code = loadStrings("test.txt");
  String result = "";
  for (String str : code) {
    if (!str.isEmpty()) {
      result+=(str+"\n");
    }
  }
  context c = new context(result);
  try {
    c.exe();
  }
  catch(Exception e) {
    println(e);
  }
}
void exe() {
  if (pythonSetupInProgress) {
    ui.addConsole("setup", "Python環境をセットアップ中です。完了後に再実行してください");
    return;
  }
  if (!pythonReady) {
    ui.addConsole("setup", "Python実行環境が見つかりません。`uv sync` を確認してください");
    return;
  }
  context c = new context(ui.editor.getText());
  exe1 e = new exe1(c);
  e.start();
}

void ensurePythonRuntime() {
  if (hasPythonRuntime()) {
    pythonReady = true;
    return;
  }
  String uvPath = resolveUvPath();
  if (uvPath == null) {
    ui.addConsole("setup", "`.venv` がなく、`uv` も見つかりませんでした");
    return;
  }
  pythonSetupInProgress = true;
  ui.addConsole("setup", "初回セットアップを開始します");
  new pythonSetupThread(uvPath).start();
}

boolean hasPythonRuntime() {
  String[] candidates = {
    sketchPath(".venv/bin/python"),
    sketchPath("venv/bin/python")
  };
  for (String candidate : candidates) {
    File file = new File(candidate);
    if (file.exists() && file.canExecute()) {
      return true;
    }
  }
  return false;
}

String resolveUvPath() {
  String[] candidates = {
    sketchPath(".venv/bin/uv"),
    System.getProperty("user.home") + "/.local/bin/uv",
    "/opt/homebrew/bin/uv",
    "/usr/local/bin/uv"
  };
  for (String candidate : candidates) {
    File file = new File(candidate);
    if (file.exists() && file.canExecute()) {
      return file.getAbsolutePath();
    }
  }
  return null;
}

result readResult () {
  JSONObject jarray = loadJSONObject("result.json");
  int shots = jarray.getInt("shots");
  result result = new result(shots);
  JSONArray results = jarray.getJSONArray("result");
  for (int i=0; i<results.size(); i++) {
    String name = results.getJSONArray(i).getString(0);
    int value = results.getJSONArray(i).getInt(1);
    result.result.add(new result_bit(name, value));
  }
  return result;
}
class exe1 extends Thread {
  context ctx;
  exe1(context _ctx) {
    ctx = _ctx;
  }
  void run() {
    try {
      ctx.exe();
    }
    catch(Exception e) {
      ui.addConsole("compiler",e.getMessage());
    }
    globalResult = readResult();
  }
}

class pythonSetupThread extends Thread {
  String uvPath;

  pythonSetupThread(String _uvPath) {
    uvPath = _uvPath;
  }

  void run() {
    try {
      File rootDir = new File(sketchPath(""));
      ProcessBuilder pb = new ProcessBuilder(uvPath, "sync", "--no-progress");
      pb.directory(rootDir);
      pb.environment().put("MPLCONFIGDIR", sketchPath(".matplotlib"));
      pb.redirectErrorStream(true);
      Process process = pb.start();
      BufferedReader br = new BufferedReader(new InputStreamReader(process.getInputStream()));
      String line;
      while ((line = br.readLine()) != null) {
        if (!line.isEmpty()) {
          ui.addConsole("uv", line);
        }
      }
      int exitCode = process.waitFor();
      if (exitCode == 0 && hasPythonRuntime()) {
        pythonReady = true;
        ui.addConsole("setup", "Python環境のセットアップが完了しました");
      } else {
        ui.addConsole("setup", "Python環境のセットアップに失敗しました");
      }
    }
    catch(Exception e) {
      ui.addConsole("setup", e.getMessage());
    }
    finally {
      pythonSetupInProgress = false;
    }
  }
}

result globalResult = null;
StringList consoleText = new StringList();
boolean pythonFinished = true;
class result {
  boolean isDisplayed = false;
  int shots;
  ArrayList<result_bit> result = new ArrayList<result_bit>();
  result (int s) {
    shots = s;
  }
}
String storeCode = "";
void keyPressed(){
  
  switch(key){
    case '0':
    case '1':
    case '2':
    case '3':
    case '4':
    case '5':
    case '6':
      getSample(key);
    
  }
}
void getSample(char c){
  
  if(c=='0'){
    ui.editor.setText(storeCode);
  }else{
    storeCode = ui.editor.getText();
    String[] SampleCode = loadStrings("data/Samples/"+c+".txt");
    ui.editor.setText(SampleCode);
  }
  
}

class result_bit {
  String name;
  int value;
  result_bit(String _name, int _value) {
    name = _name;
    value = _value;
  }
}
