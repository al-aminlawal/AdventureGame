import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;

PImage texture0, texture1, texture2, texture3, texture4, texture7;

void setup() {
  size(640, 640, P3D);
  frameRate(60);
  colorMode(RGB, 1.0f);

  Rotator head = new Rotator(new float[]{0,180,0}, new float[]{0,0,0}, new float[]{0,1,0}, 0, -30, 30, 1);
  Rotator rightShoulder = new Rotator(new float[]{0,90,0}, new float[]{0,0,0}, new float[]{1,0,0}, 30, -30, 30, 1);
  Rotator rightElbow = new Rotator(new float[]{0,-90,0}, new float[]{0,0.075f,0}, new float[]{1,0,0}, 30, -30, 30, 1);
  Rotator leftShoulder = new Rotator(new float[]{0,90,0}, new float[]{0,0,0}, new float[]{1,0,0}, -30, -30, 30, 1);
  Rotator leftElbow = new Rotator(new float[]{0,-90,0}, new float[]{0,0.075f,0}, new float[]{1,0,0}, -30, -30, 30, 1);
  Rotator rightThigh = new Rotator(new float[]{90,0,0}, new float[]{0,0.15f,0}, new float[]{1,0,0}, -30, -30, 30, 1);
  Rotator rightKnee = new Rotator(new float[]{-90,0,0}, new float[]{0,0.15f,0}, new float[]{1,0,0}, 0, 0, 45, 0.75f);
  Rotator leftThigh = new Rotator(new float[]{90,0,0}, new float[]{0,0.15f,0}, new float[]{1,0,0}, 30, -30, 30, 1);
  Rotator leftKnee = new Rotator(new float[]{-90,0,0}, new float[]{0,0.15f,0}, new float[]{1,0,0}, 45, 0, 45, 0.75f);
  rotators = new Rotator[] {
    head,
    rightShoulder,
    rightElbow,
    leftShoulder,
    leftElbow,
    rightThigh,
    rightKnee,
    leftThigh,
    leftKnee
  };
  robot = new Structure(
            new Shape[] {
              new Shape(new float[] {0.1f,0.15f,0.1f}, head),
              //new Shape("dodecahedron.obj", new float[] {0.2, 0.2, 0.2}, head),
              new Structure(new Shape[] {
                  new Shape(new float[] {0.06f, -0.125f, 0.06f}, rightElbow)},
                  new float[][] {{-0.058f, -0.15f, -0.001f}},
                  new float[] {0.125f, 0.075f, 0.075f}, rightShoulder),
              new Structure(new Shape[] {
                  new Shape(new float[] {0.06f, -0.125f, 0.06f}, leftElbow)},
                  new float[][] {{0.058f, -0.15f, -0.001f}},
                  new float[] {0.125f, 0.075f, 0.075f}, leftShoulder),
              new Structure(new Shape[] {
                  new Shape(new float[] {0.1f, 0.15f, 0.1f}, rightKnee)},
                  new float[][] {{0.0f, -0.3f, 0.0f}},
                  new float[] {0.1f, 0.15f, 0.1f}, rightThigh),
              new Structure(new Shape[] {
                  new Shape(new float[] {0.1f, 0.15f, 0.1f}, leftKnee)},
                  new float[][] {{0.0f, -0.3f, 0.0f}},
                  new float[] {0.1f, 0.15f, 0.1f}, leftThigh)
            }, new float[][] {
              {0, 0.4f, 0 },
              {-0.25f, 0.15f, 0},
              {0.25f, 0.15f, 0},
              {-0.15f, -0.3f, 0 },
              {0.15f, -0.3f, 0 }
            },
            new float[] {0.15f,0.25f,0.15f}, null);
            
  textureMode(NORMAL); // you want this!
  texture0 = loadImage("assets/cobblestone.jpeg");
  texture1 = loadImage("assets/brickpavement2.jpeg");
  texture2 = loadImage("assets/concretestairs.jpeg");
  texture3 = loadImage("assets/road.jpeg");
  texture4 = loadImage("assets/dirtroad.jpeg");
  texture7 = loadImage("assets/flatmaps.jpeg");
  
  // if this isn't set, the textures will clamp (by default): try it
  textureWrap(REPEAT);
}

int projection = 0;
int cameraAngle = 0;
boolean viewChanged = true;

Structure robot;
Rotator[] rotators;
float robotZ = -9;

float newSetObstacles = 50;

ParticleSystem particle = new ParticleSystem();

float t = 0;
float leftTurn = 0.0;
float rightTurn = 0.0;
float t1 = 0.0;
float x1 = 0.0;
float y = 0;
boolean up = true;
boolean jumped = false;
boolean moveGrid = true;
boolean moved = false;

void draw() {
  background(0.05, 0.05, 0.1);
  fill(1, 0, 0);
  stroke(1, 1, 1);
  strokeWeight(5.5);

  if (viewChanged) {   
    perspective(-PI/10, 1, 1.0, 40.0f);
    viewChanged = false;
  }
  
  resetMatrix();
  if (cameraAngle == 0) {
      if (lookingAround) {
        resetMatrix();
        camera(0.0,0.5,-7, xMouse,yMouse,0.0, 0.0,1.0,0.0);
      } else if (mouseClicked) {
        resetMatrix();
        camera(0.0,0.5,-7, 0.0,0.0,0.0, 0.0,1.0,0.0);
        mouseClicked = false;
      }
      else {
        xMouse = 0;
        yMouse = 0;
        lookingAround = false;
        mouseClicked = false;
        resetMatrix();
        camera(0.0,0.5,-7, 0.0,0.0,0.0, 0.0,1.0,0.0);
      }
    translate(0, 0, -6.5f);
  } else if (cameraAngle == 1) {
    // just back in z
    resetMatrix();
    camera(0.0,0.5,-7, 0.0,0.0,0.0, 0.0,1.0,0.0);
    translate(0, 0, -3.5f);
  }

  scale(0.5);
  
  // Add obstacles for the first grid
  if (robotZ == -9) {
    particle.addParticle();
  }
  
  /* This block of code is to implement the robot stopping when it gets near to the obstacles */
  if (!particle.hit) {
    robotZ += 0.05f;
  } else {
    if (jumped || moveGrid) {
      moveGrid = true;
      robotZ += 0.05f;
    }
  }
  /* End of block of code to implement the robot stopping when it gets near to the obstacles*/
  
  /*This block of code is to implement the robot jumping*/
  if (space) {
    if (up) {
      if (t < 1) {
        y = mylerp(t, 0, 1.3);
      } else {
        jumped = true;
        up = false;
        t = 0;
      }
    } else {      
      if (t < 1) {
        y = mylerp(t, 1.3, 0);
      } else {
        space = false;
        jumped = false;
        up = true;
        t = 0;
      }
    }
    t = t + 0.01;
  }
  /* End block of code to implement the robot jumping */
  
  if (robotZ > 31.0f) {
    particle.addParticle();
    robotZ = -10f;
  }
  
  /*
    This block of code here is to move the robot left or right
  */
  if (turnLeft) {
    x1 = mylerp(t1, leftTurn, leftTurn-0.8);
    moved = true;
  } else if (turnRight) {
    x1 = mylerp(t1,rightTurn, rightTurn+0.8);
    moved = true;
  }
  t1 = t1 + 0.01;
  
  if (t1 > 1) {
    // If the robot just moved and moved to the left, then let the 2nd parameter of the right turn lerp be leftTUrn and vice versa
    if (moved) {
      if (turnLeft) {
        leftTurn = leftTurn-0.8;
        rightTurn = leftTurn;
      } else if (turnRight) {
        rightTurn = rightTurn+0.8;
        leftTurn = rightTurn;
      }
      moved = false;
    }
    turnLeft = false;
    turnRight = false;
    t1 = 0;
  }
  
  pushMatrix();
  scale(0.75f);
  pushMatrix();
  translate(x1, 0, 0);
  // Let robot start from the bottom of our world
  translate(0, y, 0);
  robot.draw();
  popMatrix();
  // End of block of code to implement side step for robot
  /**/
  
  pushMatrix();
  
  /* This code is to move entire grid */
  translate(0,0, -robotZ);  
  // Move grid to appropriate position on screen
  translate(0, -0.75f, 0);
  boolean dark = true;
  final float SQSIZE = 0.8f;
  int rowCount = 0;
  
  for (float x = -2; x < 2; x+=SQSIZE) {    
    for (float z = -20; z < 50; z+=SQSIZE) {
      if (dark) {
        fill(0.2f, 0.2f, 0.2f);
      } else {
        fill(0.5f, 0.5f, 0.5f);
      }
      
      dark = !dark;
      beginShape(QUADS);
            
      if (rowCount == 0 || rowCount == 4) {
        texture(texture4);
        vertex(x, 0, z, 0, 1);
        vertex(x+SQSIZE, 0, z, 1, 1);
        vertex(x+SQSIZE, 0, z+SQSIZE, 1, 0);
        vertex(x, 0, z+SQSIZE, 0, 0);
        endShape();
      } else {
        texture(texture3);
        vertex(x, 0, z, 0, 1);
        vertex(x+SQSIZE, 0, z, 1, 1);
        vertex(x+SQSIZE, 0, z+SQSIZE, 1, 0);
        vertex(x, 0, z+SQSIZE, 0, 0);
        endShape();  
      }
    }
    rowCount++;
    dark = !dark;
  }
  
  particle.run();
  
  popMatrix();  
  popMatrix();
  
  for (Rotator r: rotators) {
    r.update(1);
  }
  
}

static boolean lookingAround = false;
float xMouse;
float yMouse;
void mouseDragged() {
  
  lookingAround = true;
  
  float nx = 2.0 * mouseX / width - 1;
  float ny = 2.0 * (height-mouseY+1) / height - 1;
  float px = 2.0 * pmouseX / width - 1;
  float py = 2.0 * (height-pmouseY+1) / height - 1;
  xMouse += 2*(nx - px);
  yMouse += 2*(ny - py);    
}

static boolean mouseClicked = false;
void mouseClicked() {
  mouseClicked = true;
  lookingAround = false;
}


void drawTreeObstacle() {
  
  float[][] verts = {
      { -1, -1, -1 },  // llr
      { -1, -1, 1 },  // llf
      { -1, 1, -1 },  // lur
      { -1, 1, 1 },  // luf
      { 1, -1, -1 },  // rlr
      { 1, -1, 1 },  // rlf
      { 1, 1, -1 },  // rur
      { 1, 1, 1 }     // ruf
  };
  
  int[][] faces = {
      { 1, 5, 7, 3 }, // front
      { 4, 0, 2, 6 }, // rear
      { 3, 7, 6, 2 }, // top
      { 0, 4, 5, 1 }, // bottom
      { 0, 1, 3, 2 }, // left
      { 5, 4, 6, 7 }, // right
  };
  
  beginShape(QUADS);
  texture(texture7);
  for (int[] face: faces) {
    
    int count = 0;
    for (int i: face) {      
      if (count == 0) {
        vertex(verts[i][0], verts[i][1], verts[i][2], 0, 1);
      } else if (count == 1) {
        vertex(verts[i][0], verts[i][1], verts[i][2], 1, 1);
      } else if (count == 2) {
        vertex(verts[i][0], verts[i][1], verts[i][2], 1, 0);
      } else if (count == 3) {
        vertex(verts[i][0], verts[i][1], verts[i][2], 0, 0);
      }
      count++;
    }
    
  }
  endShape();
}

void drawUnitCube() {
  float[][] verts = {
      { -1, -1, -1 },  // llr
      { -1, -1, 1 },  // llf
      { -1, 1, -1 },  // lur
      { -1, 1, 1 },  // luf
      { 1, -1, -1 },  // rlr
      { 1, -1, 1 },  // rlf
      { 1, 1, -1 },  // rur
      { 1, 1, 1 }     // ruf
  };
  
  int[][] faces = {
      { 1, 5, 7, 3 }, // front
      { 4, 0, 2, 6 }, // rear
      { 3, 7, 6, 2 }, // top
      { 0, 4, 5, 1 }, // bottom
      { 0, 1, 3, 2 }, // left
      { 5, 4, 6, 7 }, // right
  };
  
  beginShape(QUADS);
  for (int[] face: faces) {
    for (int i: face) {
      vertex(verts[i][0], verts[i][1], verts[i][2]);
    }
  }
  endShape();
}


boolean turnLeft = false;
boolean turnRight = false;
boolean space = false;

void keyPressed() {
  if (keyCode == ENTER) {
    cameraAngle++;
    if (cameraAngle == 2) {
      cameraAngle = 0;
    }
    System.out.println("Pressed space: camera = " + cameraAngle + ", projection = " + projection);
    viewChanged = true;
  } else if (key == ' ') {
    space = true;
  } else if (key == 'a') {
    turnLeft =  true;
    turnRight = false;
  } else if (key == 'd') {
    turnRight = true;
    turnLeft = false;
  }
}


float mylerp(float t, float a, float b) {
  return (1 - t) * a + t * b;
}

class Particle {
  float lifespan;
  float x;
  float z;
  boolean hitObstacle = false;

  Particle(float x, float z) {
    lifespan = z;
    this.x = x;
    this.z = z;
  }

  void run() {
    if (moveGrid) {
      update();
    }
    display();
  }
  
  boolean hitObstacle() {
    boolean hit = false;
    if (z <= lifespan-28.3 && z >= lifespan-28.35) {
      hit = true;
      moveGrid = false;
    }
    return hit;
  }
  
  // Method to update position of obstacle
  void update() {
    z -= 0.05;
  }

  void display() {
    pushMatrix();
    translate(x, 0.5, z);
    scale(0.40,0.5,0.5);
    drawTreeObstacle();
    popMatrix();
  }
  

  // Is the particle still useful?
  boolean isDead() {
    if (z < 10.0) {
      return true;
    } else {
      return false;
    }
  }
}

class ParticleSystem {
  ArrayList<Particle> particles;
  public boolean hit = false;
  
  
  ParticleSystem() {
    particles = new ArrayList<Particle>();
  }
  
  void addParticle() {
    particles.add(new Particle(-1.6,50));
    particles.add(new Particle(-0.8,49));
    particles.add(new Particle(0.0 ,48));
    particles.add(new Particle(0.8,47));
    particles.add(new Particle(1.6,46));
  }

  void run() {
    for (int i = particles.size()-1; i >= 0; i--) {
      Particle p = particles.get(i);
      p.run();
      
      if (p.hitObstacle()) {
        hit = true;
      }
      if (p.isDead()) {
        particles.remove(i);
      }
    }
  }
}

class Face {
  private int[] indices;
  private float[] colour;

  public Face(int[] indices, float[] colour) {
    this.indices = new int[indices.length];
    this.colour = new float[colour.length];
    System.arraycopy(indices, 0, this.indices, 0, indices.length);
    System.arraycopy(colour, 0, this.colour, 0, colour.length);
  }

  public void draw(ArrayList<float[]> vertices, boolean useColour) {
    if (useColour) {
      if (colour.length == 3)
        fill(colour[0], colour[1], colour[2]);
      else
        fill(colour[0], colour[1], colour[2], colour[3]);
    }

    if (indices.length == 1) {
      beginShape(POINTS);
    } else if (indices.length == 2) {
      beginShape(LINES);
    } else if (indices.length == 3) {
      beginShape(TRIANGLES);
    } else if (indices.length == 4) {
      beginShape(QUADS);
    } else {
      beginShape(POLYGON);
    }

    for (int i: indices) {
      vertex(vertices.get(i)[0], vertices.get(i)[1], vertices.get(i)[2]);
    }

    endShape();
  }
}

class Shape {
  // set this to NULL if you don't want outlines
  public float[] line_colour;

  protected ArrayList<float[]> vertices;
  protected ArrayList<Face> faces;
  
  private float[] scale;
  private Rotator rotator;

  public Shape(float[] scale, Rotator rotator) {
    // you could subclass Shape and override this with your own
    init(scale, rotator);

    // default shape: cube
    vertices.add(new float[] { -1.0f, -1.0f, 1.0f });
    vertices.add(new float[] { 1.0f, -1.0f, 1.0f });
    vertices.add(new float[] { 1.0f, 1.0f, 1.0f });
    vertices.add(new float[] { -1.0f, 1.0f, 1.0f });
    vertices.add(new float[] { -1.0f, -1.0f, -1.0f });
    vertices.add(new float[] { 1.0f, -1.0f, -1.0f });
    vertices.add(new float[] { 1.0f, 1.0f, -1.0f });
    vertices.add(new float[] { -1.0f, 1.0f, -1.0f });

    faces.add(new Face(new int[] { 0, 1, 2, 3 }, new float[] { 1.0f, 0.0f, 0.0f } ));
    faces.add(new Face(new int[] { 0, 3, 7, 4 }, new float[] { 1.0f, 1.0f, 0.0f } ));
    faces.add(new Face(new int[] { 7, 6, 5, 4 }, new float[] { 1.0f, 0.0f, 1.0f } ));
    faces.add(new Face(new int[] { 2, 1, 5, 6 }, new float[] { 0.0f, 1.0f, 0.0f } ));
    faces.add(new Face(new int[] { 3, 2, 6, 7 }, new float[] { 0.0f, 0.0f, 1.0f } ));
    faces.add(new Face(new int[] { 1, 0, 4, 5 }, new float[] { 0.0f, 1.0f, 1.0f } ));
  }

  public Shape(String filename, float[] scale, Rotator rotator) {
    init(scale, rotator);

    // TODO Use as you like
    // NOTE that there is limited error checking, to make this as flexible as possible
    BufferedReader input;
    String line;
    String[] tokens;

    float[] vertex;
    float[] colour;
    String specifyingMaterial = null;
    String selectedMaterial;
    int[] face;

    HashMap<String, float[]> materials = new HashMap<String, float[]>();
    materials.put("default", new float[] {0.5,0.5,0.5});
    selectedMaterial = "default";

    // vertex positions start at 1
    vertices.add(new float[] {0,0,0});

    int currentColourIndex = 0;

    // these are for error checking (which you don't need to do)
    int lineCount = 0;
    int vertexCount = 0, colourCount = 0, faceCount = 0;

    try {
      input = new BufferedReader(new FileReader(dataPath(filename)));

      line = input.readLine();
      while (line != null) {
        lineCount++;
        tokens = line.split("\\s+");

        if (tokens[0].equals("v")) {
          assert tokens.length == 4 : "Invalid vertex specification (line " + lineCount + "): " + line;

          vertex = new float[3];
          try {
            vertex[0] = Float.parseFloat(tokens[1]);
            vertex[1] = Float.parseFloat(tokens[2]);
            vertex[2] = Float.parseFloat(tokens[3]);
          } catch (NumberFormatException nfe) {
            assert false : "Invalid vertex coordinate (line " + lineCount + "): " + line;
          }

          System.out.printf("vertex %d: (%f, %f, %f)\n", vertexCount + 1, vertex[0], vertex[1], vertex[2]);
          vertices.add(vertex);

          vertexCount++;
        } else if (tokens[0].equals("newmtl")) {
          assert tokens.length == 2 : "Invalid material name (line " + lineCount + "): " + line;
          specifyingMaterial = tokens[1];
        } else if (tokens[0].equals("Kd")) {
          assert tokens.length == 4 : "Invalid colour specification (line " + lineCount + "): " + line;
          assert faceCount == 0 && currentColourIndex == 0 : "Unexpected (late) colour (line " + lineCount + "): " + line;

          colour = new float[3];
          try {
            colour[0] = Float.parseFloat(tokens[1]);
            colour[1] = Float.parseFloat(tokens[2]);
            colour[2] = Float.parseFloat(tokens[3]);
          } catch (NumberFormatException nfe) {
            assert false : "Invalid colour value (line " + lineCount + "): " + line;
          }
          for (float colourValue: colour) {
            assert colourValue >= 0.0f && colourValue <= 1.0f : "Colour value out of range (line " + lineCount + "): " + line;
          }

          if (specifyingMaterial == null) {
            System.out.printf("Error: no material name for colour %d: (%f %f %f)\n", colourCount + 1, colour[0], colour[1], colour[2]);
          } else {
            System.out.printf("material %s: (%f %f %f)\n", specifyingMaterial, colour[0], colour[1], colour[2]);
            materials.put(specifyingMaterial, colour);
          }

          colourCount++;
        } else if (tokens[0].equals("usemtl")) {
          assert tokens.length == 2 : "Invalid material selection (line " + lineCount + "): " + line;

          selectedMaterial = tokens[1];
        } else if (tokens[0].equals("f")) {
          assert tokens.length > 1 : "Invalid face specification (line " + lineCount + "): " + line;

          face = new int[tokens.length - 1];
          try {
            for (int i = 1; i < tokens.length; i++) {
              face[i - 1] = Integer.parseInt(tokens[i].split("/")[0]);
            }
          } catch (NumberFormatException nfe) {
            assert false : "Invalid vertex index (line " + lineCount + "): " + line;
          }

          System.out.printf("face %d: [ ", faceCount + 1);
          for (int index: face) {
            System.out.printf("%d ", index);
          }
          System.out.printf("] using material %s\n", selectedMaterial);

          colour = materials.get(selectedMaterial);
          if (colour == null) {
            System.out.println("Error: material " + selectedMaterial + " not found, using default.");
            colour = materials.get("default");
          }
          faces.add(new Face(face, colour));

          faceCount++;
        } else {
          System.out.println("Ignoring: " + line);
        }

        line = input.readLine();
      }
    } catch (IOException ioe) {
      System.out.println(ioe.getMessage());
      assert false : "Error reading input file " + filename;
    }
  }

  protected void init(float[] scale, Rotator rotator) {
    vertices = new ArrayList<float[]>();
    faces = new ArrayList<Face>();

    line_colour = new float[] { 1,1,1 };
    if (null == scale) {
      this.scale = new float[] { 1,1,1 };
    } else {
      this.scale = new float[] { scale[0], scale[1], scale[2] };
    }
    
    this.rotator = rotator;
  }

  public void rotate() {
    if (rotator != null) {
      translate(rotator.origin[0], rotator.origin[1], rotator.origin[2]);
      if (rotator.axis[0] > 0)
        rotateX(radians(rotator.angle));
      else if (rotator.axis[1] > 0)
        rotateY(radians(rotator.angle));
      else
        rotateZ(radians(rotator.angle));
      translate(-rotator.origin[0], -rotator.origin[1], -rotator.origin[2]);
    }
  }
  
  public void draw() {
    pushMatrix();
    scale(scale[0], scale[1], scale[2]);
    if (rotator != null && rotator.orientation != null) {
      rotateX(radians(rotator.orientation[0]));
      rotateY(radians(rotator.orientation[1]));
      rotateZ(radians(rotator.orientation[2]));
    }
    for (Face f: faces) {
      if (line_colour == null) {
        noStroke();
        f.draw(vertices, true);
      } else {
        stroke(line_colour[0], line_colour[1], line_colour[2]);
        f.draw(vertices, true);
      }
    }
    popMatrix();
  }
}

class Structure extends Shape {
  // this array can include other structures...
  private Shape[] contents;
  private float[][] positions;

  public Structure(Shape[] contents, float[][] positions, float[] scale, Rotator rotator) {
    super(scale, rotator);
    init(contents, positions);
  }

  public Structure(String filename, Shape[] contents, float[][] positions, float[] scale, Rotator rotator) {
    super(filename, scale, rotator);
    init(contents, positions);
  }

  private void init(Shape[] contents, float[][] positions) {
    this.contents = new Shape[contents.length];
    this.positions = new float[positions.length][3];
    System.arraycopy(contents, 0, this.contents, 0, contents.length);
    for (int i = 0; i < positions.length; i++) {
      System.arraycopy(positions[i], 0, this.positions[i], 0, 3);
    }
  }

  public void draw() {
    super.draw();    
    for (int i = 0; i < contents.length; i++) {
      pushMatrix();
      translate(positions[i][0], positions[i][1], positions[i][2]);
      contents[i].rotate();
      contents[i].draw();
      popMatrix();
    }
  }
}

class Rotator {
  public float[] orientation;
  public float[] origin;
  public float[] axis;
  public float angle, startAngle, endAngle, vAngle;
  boolean up;
  
  public Rotator(float[] orientation, float[] origin, float[] axis, float angle, float startAngle, float endAngle, float vAngle) {
    this.orientation = new float[] {orientation[0], orientation[1], orientation[2]};
    this.origin = new float[] {origin[0], origin[1], origin[2]};
    this.axis = new float[] {axis[0], axis[1], axis[2]};
    this.angle = angle;
    this.startAngle = startAngle;
    this.endAngle = endAngle;
    this.vAngle = vAngle;
    this.up = true;
  }
  
  public void update(float elapsed) {
    if (up) {
      angle += elapsed * vAngle;
      if (angle > endAngle) {
        angle = endAngle - Math.abs(angle - endAngle);
        up = false;
      }
    } else {
      angle -= elapsed * vAngle;
      if (angle < startAngle) {
        angle = startAngle + Math.abs(angle - startAngle);
        up = true;
      }
    }
  }
}
