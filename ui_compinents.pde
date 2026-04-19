abstract class ui_object {
  protected boolean active = true;
  
}
abstract class ui_function extends ui_object {
}

abstract class ui_component  extends ui_object{
  ui_rect rect;
  ui_component parent = null;
  ArrayList<ui_function> functions = new ArrayList<ui_function>();
  protected ArrayList<ui_component> children = new ArrayList<ui_component>();
  ui_component(ui_rect _rect) {
    rect = _rect;
  }
  void addChild(ui_component uc){
    children.add(uc);
    uc.parent = this;
    uc.rect.x+=rect.x;
    uc.rect.y+=rect.y;
    uc.resetChildRect(rect);
  }
  void background(color c){
    if(!active) return;
    noStroke();
    fill(c);
    rect(rect.x,rect.y,rect.w,rect.h);
  }
  void resetChildRect(ui_rect rect) {
    for(ui_component c: children){
      c.rect.x += rect.x;
      c.rect.y += rect.y;
      c.resetChildRect(rect);
    }
  }
  boolean isOnMouse(){
    if(aida(mouseX,rect.x,rect.x+rect.w)&&aida(mouseY,rect.y,rect.y+rect.h)){
      return true;
    }
    return false;
  }
  void setActive(boolean b){
    active = b;
    for(ui_component child :children){
      child.setActive(b);
    }
  }
  void addButtonFunc(ui_action action)  {
    functions.add(new ui_button(this,action));
  }
  ui_button getButtonFunc(){
     for(ui_function f : functions){
       if(f instanceof ui_button){
         return (ui_button)f;
       }
     }
     return null;
   }
  void draw(){
    if(!active) return;
    for(ui_component ui : children){
      ui.draw();
    }
  };
}
boolean aida(int x,int min,int max){
  if(min<x && x<max){
    return true;
  }
  return false;
}

class ui_image extends ui_component {
  String path;
  PImage img;
  ui_image(String _path,ui_rect _rect){
    super(_rect);
    path = _path;
    img = loadImage(_path);
  }
  void draw()
  {
    if(!active) return;
    image(img, rect.x,rect.y,rect.w,rect.h);
    super.draw();
  }
}

class ui_text_config{
  color c;
  int fontsize;
  int align = CENTER;
  int valign = CENTER;
  ui_text_config(int _fontsize,color _c,int _align){
    fontsize = _fontsize;
    c = _c;
    align = _align;
  }
    ui_text_config(int _fontsize,color _c,int _align,int _alignv){
    fontsize = _fontsize;
    c = _c;
    align = _align;
    valign = _alignv;
  }
}

class ui_text extends ui_component {

  String text;
  ui_text_config conf;
  ui_text(String _text,ui_rect _rect,ui_text_config config){
    super(_rect);
    text =_text;
    conf = config;
    
  }
  void draw(){
    if(!active) return;
    textSize(conf.fontsize);
    fill(conf.c);
    textAlign(conf.align,conf.valign);
    text(text,rect.x,rect.y,rect.w,rect.h);
    super.draw();
  }
}

class ui_rect {  
  int w;
  int h;
  int x;
  int y;
  ui_rect(float _x,float _y,float _w,float _h){
    w = int(_w);
    h = int(_h);
    x = int(_x);
    y = int(_y);
  }
}

class ui_box extends ui_component{
  color c;
  boolean border = false;
  color borderC;
  int borderW;
  ui_box(ui_rect _rect,color _c){
    super(_rect);
    c = _c;
  }
  ui_box(ui_rect _rect,color _c,color bc,int bw){
    super(_rect);
    c = _c;
    borderC = bc;
    borderW = bw;
  }
  void draw(){
    if(!active) return;
    if(border){
      stroke(borderC);
      strokeWeight(borderW);
    }else{
      noStroke();
    }
    fill(c);
    rect(rect.x,rect.y,rect.w,rect.h);
    super.draw();
  }
}
interface ui_action {
  void action();
}
class ui_button extends ui_function {
  ui_component target;
  ui_action action;
  ui_button(ui_component _target,ui_action _action){
    target = _target;
    action = _action;
    ui.buttons.add(this);
  }
  void pushed(){
    if(!active) return ;
    action.action();
  }
  boolean inspectPushed(){
    return target.isOnMouse();
  }
}
