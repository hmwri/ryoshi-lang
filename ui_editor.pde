class ui_editor extends ui_component{
  JTextArea area = new JTextArea();
  JScrollPane pane;
  ui_master parentui;
  ui_editor(ui_master ui, ui_rect _rect) {
    super(_rect);
    parentui = ui;
    area.setLineWrap(true);
    area.setWrapStyleWord(true);
    area.setMargin(new Insets(5, 5, 0, 0));
    JScrollPane scrollPane = new JScrollPane(area);
    area.setForeground(new Color(255,255,255));
    scrollPane.setBounds(rect.x+20, rect.y, rect.x+rect.w, rect.y+rect.h+1);
    scrollPane.setBackground(new Color(#3A445F));
    area.setBackground(new Color(#3A445F));
    area.setCaretColor(new Color(255,255,255));
    parentui.pane.add(scrollPane);
    area.setFont(new Font("Source Han Code Pro", Font.BOLD, 16));
    pane = scrollPane;
  }
  void setText(String str) {
    area.setText(str);
  }
  void setText(String[] strs) {
    String result = "";
    for (String str : strs) {
      
        result+=(str+"\n");
      
    }
     area.setText(result);
  }
  String getText(){
    return area.getText();
  }
  void draw(){
    
  }
  void reSize(int x1, int y1, int x2, int y2){
    pane.setBounds(x1, y1, x2, y2);
  }
}
