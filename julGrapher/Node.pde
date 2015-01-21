public class Node {

  public int id;
  public String label;

  public float ecce; //?
  public float closeness; //? 
  public float between; //?
  public float modclass; //?

  public float size;
  public PVector position =  new PVector(0, 0, 0);
  public color colour;
  
  ArrayList<Edge> edges = new ArrayList<Edge>();

  Node(int id, String label, float size, PVector position, color colour, float ecce, float closeness, float between, float modclass) {

    this.id = id;
    this.label = label;

    this.size = size;
    this.position = position;
    this.colour = colour;

    this.ecce = ecce;
    this.closeness = closeness;
    this.between = between;
    this.modclass = modclass;
  }
  
  public void addEdge(int id, int source, int target, float weight){
    if (this.id == source){
      edges.add(new Edge(id, source, target, weight));
    }
  }
}
