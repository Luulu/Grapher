/* //<>//
add: label system (graph labels M key, node labels N)
add: reload data (R key)
*/

import javax.swing.*;
import javax.swing.SwingUtilities;
import javax.swing.filechooser.*;
import javax.swing.filechooser.FileFilter;
import peasy.*;
import controlP5.*;
import processing.dxf.*;
import processing.pdf.*;

boolean record;
PeasyCam cam;
boolean dataLoaded = false;
ArrayList<Graph> graphs = new ArrayList<Graph>();
ArrayList<Label> labelsNode = new ArrayList<Label>();
ArrayList<Label> labelsGraph = new ArrayList<Label>();
Graph activeGraphRef;
Node activeNodeRef;
Node overMouseNodeRef;
int activeGraph = 0;
int activeNode = 0;
PVector pointerV = new PVector();


PFont fontGraphLabel;
PFont fontNodeLabel;

color colorNodes = color(0);
color colorEdges = color(0);
color colorNodeActive = color(255);




PShader fog;
PShader fogLine;

ControlP5 controlP5;
boolean showPanel = false, doFog = false, showGraphLabels = true, showNodeLabels = true;

public void setup(){
    fontGraphLabel = loadFont("Klavika-Medium-50.vlw");
    fontNodeLabel = loadFont("Klavika-Regular-50.vlw");
    frameRate(24);
    noLoop();
    hint(ENABLE_STROKE_PURE);
    cam = new PeasyCam(this, 1000);
    cam.setWheelScale(2.0);
    frame.setLocation(0, 0);
  
    size(1920, 1080, P3D);
    background(190);
    smooth();
    stroke(200);
    
    // fog = loadShader("Fog.frag", "Fog.vert");
    // fogLine = loadShader("FogLine.frag", "FogLine.vert");
    loadData();
    activeGraphRef = graphs.get(activeGraph);
    lookAtPV(activeGraphRef.position, 2000);
    
    // controlP5 = new ControlP5(this);
    // controlP5.setAutoDraw(false);
    // Group g1 = controlP5.addGroup("SETUP").setPosition(800, 20);
    // controlP5.addToggle("doFog", false, 0, 150, 24, 12)
    //  .setGroup(g1);
    // controlP5.hide();
    
     
}
  
  
public void draw() {
  if (record) {
   // beginRaw(DXF, "raw-####.dxf");
   beginRaw(PDF, "frame-###.pdf");
  }
  
  background(179);
  
  fill(255);
  // if (doFog) { 
  //   shader(fog, TRIANGLES);
  //   shader(fogLine, LINES);
  //   noLights();
  // } else {
  //   resetShader(TRIANGLES);
  //   resetShader(LINES); 
  // }
  

  
  if (activeGraphRef != null) {
      pointerV.x = screenX(activeGraphRef.position.x, activeGraphRef.position.y, activeGraphRef.position.z);
      pointerV.y = screenY(activeGraphRef.position.x, activeGraphRef.position.y, activeGraphRef.position.z);
  }
  if (activeGraphRef != null && showGraphLabels) {
      labelsGraph.add(new Label(screenX(activeGraphRef.position.x, activeGraphRef.position.y, activeGraphRef.position.z),
                               screenY(activeGraphRef.position.x, activeGraphRef.position.y, activeGraphRef.position.z),
                               0, 0, activeGraphRef.name, 48, fontGraphLabel));
  }
  hudBack();
  
  for(Graph graph: graphs){

    pushMatrix();
    translate(graph.position.x, graph.position.y, graph.position.z);
    // hint(DISABLE_DEPTH_TEST);
    for(Integer id: graph.nodes.keySet()) {
      Node n = null;
      n = graph.nodes.get(id);
      
      float size = 0;
      for(Edge e: n.edgesFromThis){
        size += e.weight;
      }
      for(Edge e: n.edgesToThis){
        size += e.weight;
      }
      size = map(size, 0, 50, 10, 50);
      
      if (activeGraphRef == graph && showNodeLabels){
        labelsNode.add(new Label(screenX(n.position.x, n.position.y, n.position.z),
                                 screenY(n.position.x, n.position.y, n.position.z),
                                 0, 0, n.label, 15, fontNodeLabel));
      }
      
      // int size = n.edgesFromThis.size() + n.edgesToThis.size();
      if (dist(screenX(n.position.x, n.position.y, n.position.z),
               screenY(n.position.x, n.position.y, n.position.z),
               mouseX, mouseY) < 6 && activeGraphRef == graph){
        fill(colorNodeActive);
        overMouseNodeRef = n;
      } else {
        fill(colorNodes);
      }
       
      pushMatrix();
      translate(n.position.x, n.position.y, n.position.z);
      

      
      noStroke();
      box(size);
      
      
      popMatrix();
      
      for(Edge edgeFrom: n.edgesFromThis){
        strokeWeight(map(edgeFrom.weight, 0, 13, 1, 8));
        stroke(colorEdges, map(edgeFrom.weight, 0, 11, 20, 255));  
        line(n.position.x, n.position.y, n.position.z,
             edgeFrom.target.position.x, edgeFrom.target.position.y, edgeFrom.target.position.z);
      }
      
      
    }
    popMatrix();
    hudFront();
  }
  // hint(ENABLE_DEPTH_TEST);
  if (record) { 
    endRaw();
    record = false;
    background(255,255,0);
  }
  
}


public void keyReleased() {
  switch(key){         
    case'l':
    case'L':
      String flName = getFile("Load XML");
      println("LOADING COMPLETE:");
      XML xmlLoaded = new XML(flName);
    break;
    
    case'A':
    case'a':
     activeNode--;
     if (activeNode < 0){
       activeNode = graphs.get(activeGraph).nodes.size()-1;
     }
     println("aN: " + activeNode + " ");
     activeNodeRef = activeGraphRef.nodes.get(activeGraphRef.nodes.keySet().toArray()[activeNode]);
     lookAtPV(PVector.add(activeGraphRef.position, activeNodeRef.position), 300);
    break;
    
    case'D':
    case'd':
     activeNode++;
     if (activeNode >= graphs.get(activeGraph).nodes.size()){
       activeNode = 0;
     }
     activeNodeRef = activeGraphRef.nodes.get(activeGraphRef.nodes.keySet().toArray()[activeNode]);
       lookAtPV(PVector.add(activeGraphRef.position, activeNodeRef.position), 300); //<>//
    break;
    
    case'W':
    case'w':
     activeGraph++;
     if (activeGraph >= graphs.size()){
       activeGraph = 0;
     }
     activeNode = -1;
     activeGraphRef = graphs.get(activeGraph);
     lookAtPV(activeGraphRef.position, 2000);
    break;
    
    case'S':
    case's':
      activeGraph--;
     if (activeGraph < 0){
       activeGraph = 0;
     }
     activeNode = -1;
     lookAtPV(graphs.get(activeGraph).position, 1800);
    break;
    
    case'P':
    case'p':
       record = true;
       saveFrame("screenshot-###.png");
       
    break;
    
    case'X':
    case'x':
     lookAtPV(graphs.get(activeGraph).position, 1800);
    break;
    case'G':
    case'g':
      showPanel = !showPanel;
      if (showPanel) {
        controlP5.show();
      } else if (!showPanel) {
        controlP5.hide();
      }
    break;
    case'M':
    case'm':
      showGraphLabels = !showGraphLabels;
    break;
    case'N':
    case'n':
      showNodeLabels = !showNodeLabels;
    break;
    case'R':
      graphs.clear();
      loadData();
      activeGraphRef = graphs.get(activeGraph);
      lookAtPV(activeGraphRef.position, 2000);
    break;
  }
  
}

void lookAtPV(PVector vec, float dist){
  cam.lookAt(vec.x, vec.y, vec.z, dist, 800);
}
  
String getFile(String dialogTxt) {
    String fName = "";
    JFileChooser fc = new JFileChooser();
    int rc = fc.showDialog(null, dialogTxt);
    if (rc == JFileChooser.APPROVE_OPTION)
    {
      File file = fc.getSelectedFile();
      fName = file.getName();
      println("PATH: "+fName);
    }
    return fName;
}
  
  
boolean hasChild(XML myXml, String myKey) {
  boolean has = false;
  for(String tempKey: myXml.listChildren()){
    if (tempKey == myKey){
      has = true;
      break;
    }
  }
  return has;
}


void hudBack() {
  hint(DISABLE_DEPTH_TEST);
  cam.beginHUD();
    if (pointerV != null && activeGraphRef != null && showGraphLabels) {
        noStroke();
        strokeWeight(3);
        fill(255, 204, 153);
        ellipseMode(RADIUS);
        float dellipse = PVector.dist(new PVector(cam.getPosition()[0], cam.getPosition()[1], cam.getPosition()[2]), activeGraphRef.position);
        float radious = constrain(map(dellipse, 0, 10000, 300, 50), 50, 300);
        ellipse(pointerV.x, pointerV.y, radious, radious);
        
        drawLabels(labelsGraph);
        drawLabels(labelsNode);     
        
      }
  // controlP5.draw();
  hint(ENABLE_DEPTH_TEST);
  cam.endHUD();

}


void hudFront() {
  hint(DISABLE_DEPTH_TEST);
  cam.beginHUD();
      if (showGraphLabels) drawLabels(labelsGraph);
      if (showNodeLabels) drawLabels(labelsNode);
  hint(ENABLE_DEPTH_TEST);
  cam.endHUD();

}


void drawLabels(ArrayList<Label> labels){
  for (Label lab: labels){
          textAlign(CENTER);
          fill(255);
          textFont(fontGraphLabel, lab.size);
          text(lab.text, lab.x + lab.offx, lab.y + lab.offy);
        }
        labels.clear();
}

void controlEvent(ControlEvent theEvent) {
  println(theEvent.controller().id());
}

void delay(int delay)
{
  int time = millis();
  while(millis() - time <= delay);
}

boolean loadData(){
  for (int ig=0; ig<1; ig++){
      
      XML xmlConfigs = loadXML("config.xml");
      
      for(XML graphConfig: xmlConfigs.getChildren("graph")){
        
        XML xmlGraph = loadXML(graphConfig.getChild("file").getString("path"));
        Graph newGraph = new Graph(xmlGraph);
        graphs.add(newGraph);
        newGraph.id = graphConfig.getInt("id");
        newGraph.file = graphConfig.getChild("file").getString("path");
        newGraph.name = graphConfig.getChild("person").getString("name");
        newGraph.gender = graphConfig.getChild("person").getString("gender");
        newGraph.age = graphConfig.getChild("person").getString("age");
        newGraph.country = graphConfig.getChild("person").getString("country");
        newGraph.desc = graphConfig.getContent();
      }
    }
    loop();
    return true;
}

void mouseClicked() {
  println(overMouseNodeRef);
  if (overMouseNodeRef != activeNodeRef) {
    activeNodeRef = overMouseNodeRef;
    lookAtPV(PVector.add(activeGraphRef.position, activeNodeRef.position), 300);
    println("yo");
  }
}
