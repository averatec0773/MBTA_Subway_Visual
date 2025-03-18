class Edge {
  Node from; 
  Node to; 
  float minutes;
  color edgeColor;
  boolean isActive;  // Flag for shortest path visualization

  // Integrator objects for smooth animation of saturation and brightness
  Integrator saturation;
  Integrator brightness;

  // Constructor
  Edge(Node from, Node to, float minutes, String col) {
    this.from = from; 
    this.to = to; 
    this.minutes = minutes;
    this.edgeColor = getColorFromString(col);
    this.isActive = true;  // Default: all edges are active

    // Retrieve the default saturation and brightness of edgeColor
    float defaultSaturation = saturation(edgeColor);
    float defaultBrightness = brightness(edgeColor);

    // Initialize Integrator objects with default values
    saturation = new Integrator(defaultSaturation);
    brightness = new Integrator(defaultBrightness);
  }

  // Getter methods
  Node getFromNode() {
    return from;
  }

  Node getToNode() {
    return to;
  }

  float getMinutes() {
    return minutes;
  }

  // Convert color identifier to RGB color
  color getColorFromString(String col) {
    char firstLetter = col.toLowerCase().charAt(0);
    switch (firstLetter) {
      case 'r': return color(230, 19, 16);   // red
      case 'g': return color(1, 104, 66);    // green
      case 'b': return color(0, 48, 140);    // blue
      case 'o': return color(255, 131, 5);   // orange
      default:  return color(230, 19, 16);   // default to red
    }
  }

  // Update animation values
  void update() {
    saturation.update();
    brightness.update();
  }

  // Adjust the color when the edge is inactive (not in shortest path)
  void setActive(boolean state) {
    isActive = state;
    if (!state) {
      // Reduce saturation and brightness for non-active edges
      saturation.target(0);
      brightness.target(200);
    } else {
      // Restore original saturation and brightness dynamically
      saturation.target(saturation(edgeColor));
      brightness.target(brightness(edgeColor));
    }
  }

  // Draw the edge with HSB color adjustments
  void draw() {
    colorMode(HSB, 255);  // Switch to HSB mode for better visual transitions
    float h = hue(edgeColor);
    float s = saturation.value;  // Get interpolated saturation
    float b = brightness.value;  // Get interpolated brightness

    stroke(color(h, s, b));
    strokeWeight(3);  // Make edges slightly thicker
    line(from.x, from.y, to.x, to.y);

    colorMode(RGB); // Restore color mode to RGB for other drawings
  }
}
