// Double Pendulum
// https://github.com/i-am-gizm0/DoublePendulum
// Equations from https://www.myphysicslab.com/pendulum/double-pendulum-en.html

import java.util.Date;

// Physics Values
float theta1 = 0;
float deltaTheta1 = 0;
float omega1 = 0;
float deltaOmega1 = 0;
float alpha1 = 0;

float x1 = 0;
float vx1 = 0;
float ax1 = 0;

float y1 = 0;
float vy1 = 0;
float ay1 = 0;

ArrayList pos1 = new ArrayList<Pair<Float>>();

float theta2 = 0;
float deltaTheta2 = 0;
float omega2 = 0;
float deltaOmega2 = 0;
float alpha2 = 0;

float x2 = 0;
float vx2 = 0;
float ax2 = 0;

float y2 = 0;
float vy2 = 0;
float ay2 = 0;

ArrayList pos2 = new ArrayList<Pair<Float>>();

// Physics "Constants" (for now)
final float g = Constants.g;

final float l1 = Constants.length1;
final float m1 = Constants.mass1;

final float l2 = Constants.length2;
final float m2 = Constants.mass2;

float viewScale = Constants.viewScale;


// Time
int now;
int lastMillis = 0;
int deltaMillis = 0;
long frameRateSum = 0;

// Debug Text
int textLine = 1;
int textMaxLength = 0;
int textShift = 7;

boolean help = false;
boolean debug = true;
boolean paused = false;
boolean saveFrame = false;
boolean record = true;

PFont font;
PFont Sen;

Date d = new Date();
PrintWriter csvOutput;
String configName;

void setup() {
  size(720, 720);
  surface.setResizable(true);
  
  font = loadFont("Consolas-12.vlw");
  Sen = loadFont("Sen-36.vlw");
  
  theta1 = (float)Math.random() * 2 * PI;
  theta2 = (float)Math.random() * 2 * PI;
  
  startRecording();
}

void draw() {
  now = millis();
  deltaMillis = now - lastMillis;
  float deltaSec = deltaMillis / 1000.0;
  //float deltaSec = 1 / frameRate;
  
  background(0);
  
  translate(width / 2, height / 2);  // Moves the origin to the center of the window
  scale(1, -1);  // Inverts the Y axis so it points up like we're used to. It hopefully will make math easier later
  
  int meter = floor(viewScale * Constants.lengthScaleFactor);
  int rowsThatFit = height / meter;
  int columnsThatFit = width / meter;
  for (int x = -1 * columnsThatFit; x <= columnsThatFit; x++) {
    stroke(16);
    strokeWeight(1 * viewScale);
    line(drawScale(x), height / 2, drawScale(x), -height / 2);
    for (int y = -1 * rowsThatFit; y <= rowsThatFit; y++) {
      stroke(16);
      strokeWeight(1 * viewScale);
      line(-width / 2, drawScale(y), width / 2, drawScale(y));
      stroke(32);
      strokeWeight(4 * viewScale);
      point(drawScale(x), drawScale(y));
    }
  }
  
  textLine = 1;
  textMaxLength = 0;
  textShift = 7;
  
  if (!paused) {
    // Calculate *physics*
    // Calculate rotational kinematics of first pendulum
    float num1 = -g * (2 * m1 + m2) * sin(theta1) - m2 * g * sin(theta1 - 2 * theta2) - 2 * sin(theta1 - theta2) * m2 * (pow(omega2, 2) * l2 + pow(omega1, 2) * l1 * cos(theta1 - theta2));
    float den1 = l1 * (2 * m1 + m2 - m2 * cos(2 * theta1 - 2 * theta2));
    alpha1 = num1 / den1;
    
    // It's relatively safe to assume the amount of time between frames is consistent from one to the next.
    // It fluctuates ~2ms but that doesn't really matter and it averages out to 60fps.
    
    deltaOmega1 = alpha1 * deltaSec;
    omega1 += deltaOmega1;
    //omega1 *= 0.99;
    
    deltaTheta1 = omega1 * deltaSec;
    theta1 += deltaTheta1;
    theta1 = theta1 % (2 * PI);
    
    // Calculate rotational kinematics of second pendulum
    
    float num2 = 2 * sin(theta1 - theta2) * (pow(omega1, 2) * l1 * (m1 + m2) + g * (m1 + m2) * cos(theta1) + pow(omega2, 2) * l2 * m2 * cos(theta1 - theta2));
    float den2 = l2 * (2 * m1 + m2 - m2 * cos(2 * theta1 - 2 * theta2));
    alpha2 = num2 / den2;
    
    deltaOmega2 = alpha2 * deltaSec;
    omega2 += deltaOmega2;
    //omega2 *= 0.99;
    
    deltaTheta2 = omega2 * deltaSec;
    theta2 += deltaTheta2;
    theta2 = theta2 % (2 * PI);
    
    
    // Calculate linear kinematics of first pendulum
    x1 = l1 * sin(theta1);
    vx1 = omega1 * l1 * cos(theta1);
    ax1 = -pow(omega1, 2) * l1 * sin(theta1) + alpha1 * l1 * cos(theta1);
    
    y1 = -1 * l1 * cos(theta1);
    vy1 = omega1 * l1 * sin(theta1);
    ay1 = pow(omega1, 2) * l1 * cos(theta1) + alpha1 * l1 * sin(theta1);
    
    pos1.add(0, new Pair<Float>(x1, y1));
    
    // Calculate linear kinematics of second pendulum
    x2 = x1 + l2 * sin(theta2);
    vx2 = vx1 + omega2 * l2 * cos(theta2);
    ax2 = ax1 - pow(omega2, 2) * l2 * sin(theta2) + alpha2 * l2 * cos(theta2); 
    
    y2 = y1 - l2 * cos(theta2);
    vy2 = vy1 + omega2 * l2 * sin(theta2);
    ay2 = ay1 + pow(omega2, 2) * l2 * cos(theta2) + alpha2 * l2 * sin(theta2);
    
    pos2.add(0, new Pair<Float>(x2, y2));
  }
  
  // The hard part's over. Draw it.
  
  strokeWeight(1 * viewScale);
  for (int i = 0; i < pos1.size() - 1; i++) {
    stroke(255, 0, 0, 255 - i);
    Pair a = (Pair)pos1.get(i);
    Pair b = (Pair)pos1.get(i + 1);
    line(drawScale((float)a.getA()), drawScale((float)a.getB()), drawScale((float)b.getA()), drawScale((float)b.getB()));
    
    stroke(0, 0, 255, 255 - i);
    a = (Pair)pos2.get(i);
    b = (Pair)pos2.get(i + 1);
    line(drawScale((float)a.getA()), drawScale((float)a.getB()), drawScale((float)b.getA()), drawScale((float)b.getB()));
  }
  
  if (pos1.size() > Constants.linger) {
    pos1.remove(pos1.size() - 1);
    pos2.remove(pos2.size() - 1);
  }
  
  strokeWeight(2 * viewScale);
  // Draw the first pendulum
  stroke(255, 0, 0);
  line(0, 0, drawScale(x1), drawScale(y1));
  // Draw the second pendulum
  stroke(0, 0, 255);
  line(drawScale(x1), drawScale(y1), drawScale(x2), drawScale(y2));
  
  
  // Draw masses
  strokeWeight(Constants.massScaleFactor * viewScale / 2);
  stroke(16);
  point(0, 0);
  // Draw the first mass
  strokeWeight(Constants.massScaleFactor * m1 * viewScale);
  stroke(255, 0, 0);
  point(drawScale(x1), drawScale(y1));
  // Draw the second mass
  strokeWeight(Constants.massScaleFactor * m2 * viewScale);
  stroke(0, 0, 255);
  point(drawScale(x2), drawScale(y2));
  
  scale(1, -1);
  translate(-width / 2, -height / 2);
  
  fill(128, 128);
  textFont(Sen, 36);
  textAlign(LEFT, BOTTOM);
  text("Double Pendulum", 24, height - 24);
  textFont(Sen, 18);
  text("github.com/i-am-gizm0", 24, height - 60);
  
  if (saveFrame) {
    saveFrame("Pendulum####.png");
  }
  
  textFont(font, 12);
  if (paused) {
    fill(255);
    textDraw("PAUSED");
    textDraw();
    stopRecording();
  }
  
  if (record) {
    fill(255, 64, 64);
    textDraw("RECORDING");
    csvOutput.println(frameCount + "," + theta1 + "," + theta2);
  }
  
  if (help) {
    help();
  }
  
  if (debug) {
    // Draw debug
    debug();
  }
  
  // Cleanup for the next frame
  lastMillis = now;
  saveFrame = false;
}

private float drawScale(float n) {
  return n * Constants.lengthScaleFactor * viewScale;
}

private void help() {
  fill(64);
  textDraw("Keyboard Shortcuts");
  textDraw(" Key   Function");
  textDraw("  ?    Help menu");
  textDraw("  d    Debug List");
  textDraw("space  Pause/Resume");
  textDraw(" =/-   Zoom In/Out");
  textDraw("  0    Reset Zoom");
  textDraw("  p    Take Screenshot");
  textDraw("  r    Toggle Recording");
  nextColumn();
}

private void debug() {
  fill(255);
  textDraw("Gravity: " + g + "m/s");
  textDraw("Mass Scale Factor: " + Constants.massScaleFactor);
  textDraw("Length Scale Factor: " + Constants.lengthScaleFactor);
  textDraw();
  
  fill(128, 255, 128);
  textDraw("W: " + width + "px");
  textDraw("H: " + height + "px");
  textDraw("S: " + (viewScale * 100) + "%");
  fill(0, 255, 0);
  textDraw("Frame Rate: " + padString(frameRate) + "fps");
  frameRateSum += Math.round(frameRate);
  float avgFrameRate = frameRateSum / frameCount;
  textDraw("Avg. Frame Rate: " + avgFrameRate + "fps");
  textDraw("Rendered Frames: " + frameCount + " frames");
  textDraw("Elapsed Time: " + now + "ms");
  textDraw("Last Time: " + lastMillis + "ms");
  textDraw("Interframe Time:  " + deltaMillis + "ms");
  int calcTime = (millis() - now);
  textDraw("Intraframe Time: " + calcTime + "ms");
  textDraw("Frame Wait Time: " + (deltaMillis - calcTime) + "ms");
  int estimatedFrames = (now / 1000) * 60;
  int difference = estimatedFrames - frameCount;
  if (difference > 0) {
    textDraw("Lag: " + difference + " frames behind");
  } else {
    textDraw("Lag: " + (-1 * difference) + " frames ahead");
  }
  nextColumn();
  
  fill(255, 128, 128);
  textDraw("L₁  " + l1 + "m");
  textDraw("M₁  " + m1 + "kg");
  textDraw("                      ");
  fill(255, 0, 0);
  textDraw("θ₁  " + padString(theta1, 13) + "rad");
  textDraw("Δθ₁ " + padString(deltaTheta1, 13) + "rad");
  textDraw("ω₁  " + padString(omega1, 13) + "rad/s");
  textDraw("Δω₁ " + padString(deltaOmega1, 13) + "rad/s");
  textDraw("α₁  " + padString(alpha1, 13) + "rad/s²");
  textDraw();
  textDraw("x₁  " + padString(x1, 13) + "m");
  textDraw("vx₁ " + padString(vx1, 13) + "m/s");
  textDraw("ax₁ " + padString(ax1, 13) + "m/s²");
  textDraw();
  textDraw("y₁  " + padString(y1, 13) + "m");
  textDraw("vy₁ " + padString(vy1, 13) + "m/s");
  textDraw("ay₁ " + padString(ay1, 13) + "m/s²");
  nextColumn();
  
  fill(128, 128, 255);
  textDraw("L₂  " + l2 + "m");
  textDraw("M₂  " + m2 + "kg");
  textDraw();
  fill(64, 64, 255);
  textDraw("θ₂  " + padString(theta2, 13) + "rad");
  textDraw("Δθ₂ " + padString(deltaTheta2, 13) + "rad");
  textDraw("ω₂  " + padString(omega2, 13) + "rad/s");
  textDraw("Δω₂ " + padString(deltaOmega2, 13) + "rad/s");
  textDraw("α₂  " + padString(alpha2, 13) + "rad/s²");
  textDraw();
  textDraw("x₂  " + padString(x2, 13) + "m");
  textDraw("vx₂ " + padString(vx2, 13) + "m/s");
  textDraw("ax₂ " + padString(ax2, 13) + "m/s²");
  textDraw();
  textDraw("y₂  " + padString(y2, 13) + "m");
  textDraw("vy₂ " + padString(vy2, 13) + "m/s");
  textDraw("ay₂ " + padString(ay2, 13) + "m/s²");
}

private void textDraw() {
  textLine++;
}

private void textDraw(String text) {
  int fontSize = 12;
  textSize(fontSize);
  text(text, textShift, textLine * fontSize * 1.5);
  textLine++;
  if (text.length() > textMaxLength) {
    textMaxLength = text.length();
  }
}

private void nextColumn() {
  textLine = 1;
  textShift = (textMaxLength * 7) + 7 + textShift;
  textMaxLength = 0;
}

private String padString(float number) {
  return padString(number, 9);
}

private String padString(float number, int length) {
  return padString("" + number, length);
}

private String padString(String string) {
  return padString(string, 9);
}

private String padString(String string, int length) {
  return String.format("%1$-" + length + "s", string);
}

void keyPressed() {
  //println(keyCode);
  if (key != CODED) {
    switch (key) {
      case 'd':
        debug = !debug;
        break;
        
       case '?':
       case '/':
         help = !help;
         break;
       
       case ' ':
         paused = !paused;
         break;
       
       case '-':
         if (viewScale != 0.25) {
           viewScale -= 0.25;
         }
         break;
       
       case '+':
       case '=':
         viewScale += 0.25;
         break;
       
       case '0':
         viewScale = 1;
         break;
       
       case 'p':
         saveFrame = true;
         break;
       
       case 'r':
         if (record) {
           stopRecording();
         } else {
           startRecording();
         }
    }
  } else {
    switch (keyCode) {
      case 17: // Print
    }
  }
}

private void startRecording() {
  stopRecording();
  Date d = new Date();
  csvOutput = createWriter("Pendulum " + d.getTime() + ".csv");
  csvOutput.println("Frame,Theta 1,Theta 2");
  configName = "Pendulum " + d.getTime() + ".txt";
  record = true;
}

private void stopRecording() {
  record = false;
  if (csvOutput != null) {
    csvOutput.flush();
    csvOutput.close();
  }
}
