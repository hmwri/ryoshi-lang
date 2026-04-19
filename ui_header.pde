class ui_header extends ui_component{
  Image logo ;
  ui_header(int h){
    super(new ui_rect(0,0,width,h));
    this.addChild(new ui_image("icon.png",new ui_rect(5,h*0.2,h*0.6*10/7,h*0.6)));
    ui_text_config logoConf = new ui_text_config(20,color(255),LEFT);
    this.addChild(new ui_text("Ryoshi Editor",new ui_rect(h*0.8*10/7 + 10,0,6*40,h),logoConf));
    ui_image exeButton = new ui_image("exe.png",new ui_rect(width-h,h*0.1,h*0.8,h*0.8));
    exeButton.addButtonFunc(new exe_action());
    ui_image circuitButton = new ui_image("circuit_button.png",new ui_rect(width-h*2,h*0.1,h*0.8,h*0.8));
    circuitButton.addButtonFunc(new displayCircuit());
    this.addChild(exeButton);
    this.addChild(circuitButton);
  }
  void draw(){
   this.background(#242F4B);
   super.draw();
  }
}

class exe_action implements ui_action {
  void action(){
    exe();
  }
}
class displayCircuit implements ui_action {
  void action(){
    try{
    ProcessBuilder pb = new ProcessBuilder("open","circuit.png");
    pb.directory(new File( dataPath("")));
    Process  p  = pb.start();
    }catch (Exception ex) {
      println(ex);
    }
  }
}
