import javax.swing.*;
import java.awt.*;
class ui_master {
  Canvas canvas = (Canvas)surface.getNative();
  JLayeredPane pane = (JLayeredPane) canvas.getParent().getParent();
  ArrayList<ui_button> buttons = new ArrayList<ui_button>();
  ui_editor editor;
  ui_header header;
  ui_right right;
  ArrayList<ui_component> uis = new ArrayList<ui_component>();
  int headerh = 40;
  ui_master() {

  }
  void init(){
    editor = new ui_editor(this, new ui_rect(0, headerh, width/2, height-headerh));
    String[] code = {""};
    editor.setText(code);
    uis.add(editor);
    right = new ui_right(headerh);
    uis.add(right);
    header = new ui_header(headerh);
    uis.add(header);
  }

  void draw() {
    for(ui_component ui:uis){
      ui.draw();
    }

    editor.reSize(0,headerh,width/2, height-headerh);
  }
  
  void addConsole(String from,String body){
    right.consoleui.add(from,body);
  }
  
  void resetConsole(){
    right.consoleui.set("");
  }
  
  void inspect(){
    for(ui_button ui:ui.buttons){
      if(ui.inspectPushed()){
        ui.pushed();
      };
    }
  }
}

void mousePressed(){
  ui.inspect();
}
