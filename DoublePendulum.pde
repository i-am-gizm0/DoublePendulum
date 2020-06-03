// Double Pendulum
// https://github.com/i-am-gizm0/DoublePendulum
// Equations from https://www.myphysicslab.com/pendulum/double-pendulum-en.html

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


float theta2 = PI;
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

// Physics "Constants" (for now)
final float g = Constants.g;

final float l1 = Constants.length1;
final float m1 = Constants.mass1;

final float l2 = Constants.length2;
final float m2 = Constants.mass2;


// Time
int now;
int lastMillis = 0;
int deltaMillis = 0;

// Debug Text
int textLine = 1;
int textMaxLength = 0;
int textShift = 7;

boolean help = true;
boolean debug = true;
boolean paused = false;

PFont font;
PFont Sen;

void setup() {
  size(720, 720);
  
  font = loadFont("Consolas-12.vlw");
  Sen = loadFont("Sen-36.vlw");
}

void draw() {
  now = millis();
  deltaMillis = now - lastMillis;
  float deltaSec = deltaMillis / 1000.0;
  
  background(0);
  
  fill(64);
  textFont(Sen, 36);
  textAlign(LEFT, BOTTOM);
  text("Double Pendulum", 24, height - 24);
  textFont(Sen, 18);
  text("github.com/i-am-gizm0", 24, height - 60);
  
  translate(width / 2, height / 2);  // Moves the origin to the center of the window
  scale(1, -1);  // Inverts the Y axis so it points up like we're used to. It hopefully will make math easier later
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
    
    deltaTheta1 = omega1 * deltaSec;
    theta1 += deltaTheta1;
    
    // Calculate rotational kinematics of second pendulum
    
    float num2 = 2 * sin(theta1 - theta2) * (pow(omega1, 2) * l1 * (m1 + m2) + g * (m1 + m2) * cos(theta1) + pow(omega2, 2) * l2 * m2 * cos(theta1 - theta2));
    float den2 = l2 * (2 * m1 + m2 - m2 * cos(2 * theta1 - 2 * theta2));
    alpha2 = num2 / den2;
    
    deltaOmega2 = alpha2 * deltaSec;
    omega2 += deltaOmega2;
    
    deltaTheta2 = omega2 * deltaSec;
    theta2 += deltaTheta2;
    
    
    // Calculate linear kinematics of first pendulum
    x1 = l1 * sin(theta1);
    vx1 = omega1 * l1 * cos(theta1);
    ax1 = -pow(omega1, 2) * l1 * sin(theta1) + alpha1 * l1 * cos(theta1);
    
    y1 = -1 * l1 * cos(theta1);
    vy1 = omega1 * l1 * sin(theta1);
    ay1 = pow(omega1, 2) * l1 * cos(theta1) + alpha1 * l1 * sin(theta1);
    
    // Calculate linear kinematics of second pendulum
    x2 = x1 + l2 * sin(theta2);
    vx2 = vx1 + omega2 * l2 * cos(theta2);
    ax2 = ax1 - pow(omega2, 2) * l2 * sin(theta2) + alpha2 * l2 * cos(theta2); 
    
    y2 = y1 - l2 * cos(theta2);
    vy2 = vy1 + omega2 * l2 * sin(theta2);
    ay2 = ay1 + pow(omega2, 2) * l2 * cos(theta2) + alpha2 * l2 * sin(theta2);
  }
  
  // The hard part's over. Draw it.
  strokeWeight(2);
  // Draw the first pendulum
  stroke(255, 0, 0);
  line(0, 0, drawScale(x1), drawScale(y1));
  // Draw the second pendulum
  stroke(0, 0, 255);
  line(drawScale(x1), drawScale(y1), drawScale(x2), drawScale(y2));
  
  
  // Draw masses
  strokeWeight(Constants.massScaleFactor / 2);
  stroke(0, 255, 0);
  point(0, 0);
  // Draw the first mass
  strokeWeight(Constants.massScaleFactor * m1);
  stroke(255, 0, 0);
  point(drawScale(x1), drawScale(y1));
  // Draw the second mass
  strokeWeight(Constants.massScaleFactor * m2);
  stroke(0, 0, 255);
  point(drawScale(x2), drawScale(y2));
  
  scale(1, -1);
  translate(-width / 2, -height / 2);
  
  textFont(font, 12);
  if (paused) {
    fill(255);
    textDraw("PAUSED");
    textDraw();
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
}

private float drawScale(float n) {
  return n * Constants.lengthScaleFactor;
}

private void help() {
  fill(64);
  textDraw("Keyboard Shortcuts");
  textDraw(" Key   Function");
  textDraw("  ?    Help menu");
  textDraw("  d    Debug List");
  textDraw("space  Pause/Resume");
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
  textDraw("S: " + (Constants.viewScale * 100) + "%");
  fill(0, 255, 0);
  textDraw("Frame Rate: " + String.format("%1$-" + 9 + "s", frameRate) + "fps");
  textDraw("Rendered Frames: " + frameCount + "frames");
  textDraw("Elapsed Time: " + now + "ms");
  textDraw("Last Time: " + lastMillis + "ms");
  textDraw("Interframe Time: " + deltaMillis + "ms");
  textDraw("Calculation Time: " + (millis() - now) + "ms");
  nextColumn();
  
  fill(255, 128, 128);
  textDraw("L₁  " + l1 + "m");
  textDraw("M₁  " + m1 + "kg");
  textDraw("                      ");
  fill(255, 0, 0);
  textDraw("θ₁  " + theta1 + "rad");
  textDraw("Δθ₁ " + deltaTheta1 + "rad");
  textDraw("ω₁  " + omega1 + "rad/s");
  textDraw("Δω₁ " + deltaOmega1 + "rad/s");
  textDraw("α₁  " + alpha1 + "rad/s²");
  textDraw();
  textDraw("x₁  " + x1 + "m");
  textDraw("vx₁ " + vx1 + "m/s");
  textDraw("ax₁ " + ax1 + "m/s²");
  textDraw();
  textDraw("y₁  " + y1 + "m");
  textDraw("vy₁ " + vy1 + "m/s");
  textDraw("ay₁ " + ay1 + "m/s²");
  nextColumn();
  
  fill(128, 128, 255);
  textDraw("L₂  " + l2 + "m");
  textDraw("M₂  " + m2 + "kg");
  textDraw();
  fill(64, 64, 255);
  textDraw("θ₂  " + theta2 + "rad");
  textDraw("Δθ₂ " + deltaTheta2 + "rad");
  textDraw("ω₂  " + omega2 + "rad/s");
  textDraw("Δω₂ " + deltaOmega2 + "rad/s");
  textDraw("α₂  " + alpha2 + "rad/s²");
  textDraw();
  textDraw("x₂  " + x2 + "m");
  textDraw("vx₂ " + vx2 + "m/s");
  textDraw("ax₂ " + ax2 + "m/s²");
  textDraw();
  textDraw("y₂  " + y2 + "m");
  textDraw("vy₂ " + vy2 + "m/s");
  textDraw("ay₂ " + ay2 + "m/s²");
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

void keyPressed() {
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
    }
  } else {
    switch (keyCode) {
    }
  }
}
