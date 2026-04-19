class ui_right extends ui_component {
  int w = width/2;
  int buttonh = 25;
  boolean console = true;
  ui_box resultBox;
  ui_box consoleBox;
  ui_text resultText;
  ui_text consoleText;
  ui_result result;
  ui_console consoleui;
  ui_right(int h) {
    super(new ui_rect(width/2, h, width/2, height-h));
    resultBox = new ui_box(new ui_rect(0, 0, w/2, buttonh), color(200));
    consoleBox = new ui_box(new ui_rect(w/2, 0, w/2, buttonh), color(200));
    ui_text_config buttonConfig1 = new ui_text_config(20, color(255), CENTER);
    ui_text_config buttonConfig2 = new ui_text_config(20, color(255), CENTER);
    resultText = new ui_text("result", new ui_rect(0, 0, w/2, buttonh), buttonConfig1);
    consoleText = new ui_text("console", new ui_rect(0, 0, w/2, buttonh), buttonConfig2);
    resultBox.addChild(resultText);
    consoleBox.addChild(consoleText);
    ui_action displayResult = new changeDisplay(false);
    ui_action displayConsole = new changeDisplay(true);
    resultBox.addButtonFunc(displayResult);
    consoleBox.addButtonFunc(displayConsole);

    result = new ui_result(buttonh);
    this.addChild(result);
    consoleui = new ui_console(buttonh);
    this.addChild(consoleui);
    this.addChild(resultBox);
    this.addChild(consoleBox);
  }
  void draw() {
    color on = color(#AAD8FF);
    color off = color(#788CC6);
    color ton = color(#2D405A);
    color toff = color(200);
    result.setActive(!console);
    consoleui.setActive(console);
    if (console) {
      consoleBox.c = on;
      resultBox.c = off;
      consoleText.conf.c = ton;
      resultText.conf.c = toff;
    } else {
      consoleBox.c = off;
      resultBox.c = on;
      consoleText.conf.c = toff;
      resultText.conf.c = ton;
    }

    super.draw();
  }
}

class changeDisplay implements ui_action {
  boolean console = false;
  changeDisplay(boolean con) {
    console = con;
  }
  void action() {
    println(console);
    ui.right.console = console;
  }
}
