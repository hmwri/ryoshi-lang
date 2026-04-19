class ui_console extends ui_component {
  int bh = 0;
  ui_text_config conf;
  ui_box box;
  ui_console(int  buttonh) {
    super(new ui_rect(0, buttonh, width/2, height-ui.headerh-buttonh));
    bh = buttonh;
    conf = new ui_text_config(15, color(255), LEFT, CENTER);
    box = new ui_box(new ui_rect(0, 0, width/2, height-ui.headerh-bh), color(0));

    addChild(box);
  }
  void set(String str) {
    consoleText.append(str);
  }
  void add(String from, String str) {
    consoleText.append(from + ":" + str);
  }
  void draw() {
    box.children = new ArrayList<ui_component>();
    int i=consoleText.size();
    for (String s : consoleText) {
      i--;
      ui_text text = new ui_text(s, new ui_rect(10, height-ui.headerh-bh -5 - (i+1)*20, width/2-10, 20), conf);
      box.addChild(text);
      
    }
    super.draw();
  }
  public  String diffFrontUnmatchStr(String str1, String str2) {
    if (str1 !=null && str1.equals("")) {
      return str2;
    }
    StringBuffer buf = new StringBuffer();
    String result = null;
    if (str1 != null && str2 != null) {
      // 前方一致しない部分の文字列を取得
      String tmpStr1 = str1.trim();
      String tmpStr2 = str2.trim();
      boolean firstCharMachFlg = false;
      for (char str1Char : tmpStr1.toCharArray()) {
        buf.setLength(0);
        boolean unmachFlg = false;
        for (char str2Char : tmpStr2.toCharArray()) {
          // 不一致以降の文字列を全て設定
          if (unmachFlg || str1Char != str2Char) {
            buf.append(str2Char);
            unmachFlg = true;
          } else {
            firstCharMachFlg = true;
          }
        }
        // 判定した文字列は除外
        tmpStr2 = buf.toString();
      }

      if (!firstCharMachFlg || buf.toString().isEmpty()) {
        result = null;
      } else {
        result = buf.toString();
      }
    }
    return result;
  }
}
