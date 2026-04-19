class ui_result extends ui_component {
  int si = 0;
  ui_result(int buttonh){
    super(new ui_rect(0,buttonh,width/2,height-ui.headerh-buttonh));
  }
  void set(result result){
    int i = si;
    this.children = new ArrayList<ui_component>();
    float criteria = 100.0/(float)result.result.size();
    for(result_bit bit :result.result){
      if(i < 0){
        i++;
        continue;
      }
      addChild(new ui_result_row(bit.name,float(bit.value)/float(result.shots)*100.0,i,criteria));
      i++;
    }
  }
  void draw(){
    if(isOnMouse()){
    }
    if(globalResult !=null && !globalResult.isDisplayed){
      set(globalResult);
      globalResult.isDisplayed = false;
    }
    super.draw();
  }
}
void mouseWheel(MouseEvent e ){
  int si = ui.right.result.si;
  if(si < 1 && !(si == 0 && e.getCount() < 0)){
    ui.right.result.si += e.getCount() < 0 ? 1 :-1;
  }
  
}

class ui_result_row extends ui_component {
  String name ;
  float value;
  int h;
  int i;
  ui_result_row(String _name,float _value,int i,float criteria){
    super(new ui_rect(0,0,width/2,0));
    h = 25;
    rect.h = h;
    rect.y = i*h;
    this.i = i;
    name = _name;
    value = _value;
    ui_text_config conf = new ui_text_config((int)(h*0.75),color(255),LEFT,CENTER);
    float nameWidth = 0.8;
    colorMode(HSB, 360, 100, 100, 100);
    float H = 200.0*pow(criteria/value,0.6);
    H = min(H,255);
    H = max(0,H);
    color c = color(H,97,41);
    colorMode(RGB,255,255,255);
    
    ui_box graph = new ui_box(new ui_rect(0,0,width/2.0*value/100.0,h),c);
    ui_text nameText = new ui_text(name,new ui_rect(0,0,width/2.0*nameWidth,30),conf);
    ui_text valueText = new ui_text(String.format("%.2f",float(round(value*100))/100.0)+"%",new ui_rect(width/2.0*nameWidth,0,width/2.0*(1.0-nameWidth),30),conf);
    addChild(graph);
    addChild(nameText);
    addChild(valueText);
  }
  void draw(){
    this.background(i%2 == 0?color(#395171):color(#5578A7));
    super.draw();
  }
}
