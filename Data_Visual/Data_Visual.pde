import processing.pdf.*;

// nodes
int nodeCount; 
Node[] nodes = new Node[100];
HashMap nodeTable = new HashMap();

// selection
Node selection;

// record
boolean record; 

// edges
int edgeCount; 
Edge[] edges = new Edge[500];

// font
PFont font; 

// ShortestPath
boolean[] activeNodes;
boolean[] activeEdges;
Node A, B;
int numOfNodes;
float numOfMinutes;

void setup() {
  size(1080, 1080);
  font = createFont("SansSerif", 10);
  loadData();
  initializeActiveDataStructures();
  initializeAdjacencyMatrix();
}

void loadData() {
  // Load the CSV file
  Table table = new Table("connections.csv");

  for (int i = 0; i < table.getRowCount(); i++) {
    String from = table.getString(i, 0);  // From
    String to = table.getString(i, 1);    // To
    String colorStr = table.getString(i, 2).toLowerCase();  // Color
    float minutes = table.getFloat(i, 3);  // Minutes

    String col = "r";
    if (colorStr.startsWith("red")) col = "r";
    else if (colorStr.startsWith("green")) col = "g";
    else if (colorStr.startsWith("blue")) col = "b";
    else if (colorStr.startsWith("orange")) col = "o";

    addEdge(from, to, minutes, col);
  }
}

void addEdge(String fromLabel, String toLabel, float minutes, String col) {
  // find nodes
  Node from = findNode(fromLabel);
  Node to = findNode(toLabel);
  
  // old edge?
  for (int i = 0; i < edgeCount; i++) {
    if (edges[i].from == from && edges[i].to == to) {
      return; 
    }
  }
  
  // add edge
  Edge e = new Edge(from, to, minutes, col);
  if (edgeCount == edges.length) {
    edges = (Edge[]) expand(edges);
  }
  edges[edgeCount++] = e; 
}

Node findNode(String label) {
  Node n = (Node) nodeTable.get(label);
  if (n == null) {
    return addNode(label);
  }
  return n; 
}

Node addNode(String label) {
  // Load the CSV file
  Table table = new Table("locations.csv");

  for (int i = 0; i < table.getRowCount(); i++) {
    String stationName = table.getString(i, 0); // Column A: Station Name

    if (stationName.equals(label)) {
      float x = table.getFloat(i, 1); // X coordinate
      float y = table.getFloat(i, 2); // Y coordinate

      Node n = new Node(label, x, y, nodeCount);

      if (nodeCount == nodes.length) {
        nodes = (Node[]) expand(nodes);
      }

      nodeTable.put(label, n);
      nodes[nodeCount++] = n;
      return n;
    }
  }

  // If no matching station is found, create a node with random coordinates
  float x = random(50, width - 50);
  float y = random(50, height - 50);
  Node n = new Node(label, x, y, nodeCount);
  
  if (nodeCount == nodes.length) {
    nodes = (Node[]) expand(nodes);
  }
  
  nodeTable.put(label, n);
  nodes[nodeCount++] = n;
  return n;
}


void draw() {
  if (record) {
    beginRecord(PDF, "output.pdf");
  }

  textFont(font);
  smooth();
  background(255);

  // If the shortest path is active, adjust the visibility of edges
  if (numOfNodes == 1) {
    for (int i = 0; i < edgeCount; i++) {
      edges[i].setActive(true);  // Restore all edges
      edges[i].update();
      edges[i].draw();
    }
    for (int i = 0; i < nodeCount; i++) {
      nodes[i].draw();
    }
    // Display start station name
    fill(0);
    textSize(18);
    textAlign(LEFT, TOP);
    text("From: " + A.label, 20, 20);
  }

  else if (numOfNodes == 2) {
    for (int i = 0; i < edgeCount; i++) {
      if (activeEdges[i]) {
        edges[i].setActive(true);  // Highlight shortest path edges
      } else {
        edges[i].setActive(false); // Dim non-active edges
      }
      edges[i].update(); // Apply smooth transition
      edges[i].draw();
    }

    for (int i = 0; i < nodeCount; i++) {
      nodes[i].draw();
    }

    // Display travel time information
    fill(0);
    textSize(18);
    textAlign(LEFT, TOP);
    text("From: " + A.label, 20, 20);
    text("To: " + B.label, 20, 45);
    text("Travel Time: " + nf(numOfMinutes, 0, 2) + " min", 20, 70);
  }

  else {
    // If no shortest path is computed, display the full network
    for (int i = 0; i < edgeCount; i++) {
      edges[i].setActive(true);  // Restore normal edges
      edges[i].update();
      edges[i].draw();
    }
    for (int i = 0; i < nodeCount; i++) {
      nodes[i].draw();
    }
  }

  // Display station name when hovering over a node
  for (int i = 0; i < nodeCount; i++) {
    Node n = nodes[i];
    float d = dist(mouseX, mouseY, n.x, n.y);
    if (d < 10) { // Detect mouse proximity
      fill(0);
      textSize(15);
      textAlign(LEFT, TOP);
      text(n.label, n.x + 15, n.y - 15); // Display label slightly above and to the right
      break;
    }
  }

  if (record) {
    endRecord();
    record = false;
  }
}


void mousePressed() {
  if (mouseButton == LEFT) {
    float closest = 5;
    for (int i = 0; i < nodeCount; i++) {
      Node n = nodes[i];
      float d = dist(mouseX, mouseY, n.x, n.y);
      if (d < closest) {
        selection = n;
        closest = d;
      }
    }
  }

  if (mouseButton == RIGHT) {
    float closest = 10;
    Node clickedNode = null;

    // Find the nearest node to the right-click position
    for (int i = 0; i < nodeCount; i++) {
      Node n = nodes[i];
      float d = dist(mouseX, mouseY, n.x, n.y);
      if (d < closest) {
        clickedNode = n;
        closest = d;
      }
    }

    if (clickedNode != null) {
      // If two nodes were already selected, reset and start new selection
      if (numOfNodes == 2) {
        A = clickedNode;
        B = null;
        numOfNodes = 1;
        numOfMinutes = 0;
        initializeActiveDataStructures(); // Reset previous path
      }
      // First right-click: Assign to A
      else if (numOfNodes == 0) {
        A = clickedNode;
        numOfNodes = 1;
      }
      // Second right-click: Assign to B and compute shortest path
      else if (numOfNodes == 1 && clickedNode != A) {
        B = clickedNode;
        numOfNodes = 2;
        numOfMinutes = shortestPath(A.getIndex(), B.getIndex());
      }
    } else {
      // If clicked on empty space, reset everything
      A = null;
      B = null;
      numOfNodes = 0;
      numOfMinutes = 0;
      initializeActiveDataStructures();
    }
  }
}

void mouseDragged() {
  if (selection != null) {
    selection.x = mouseX;
    selection.y = mouseY;
  }
}

void mouseReleased() {
  selection = null;
}

void keyPressed() {
  if (key == 'p') {
    record = true;
  }
}
