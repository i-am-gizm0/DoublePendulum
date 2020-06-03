// Physics Values
float theta1 = 0;
float lastTheta1 = 0;
float deltaTheta1 = 0;
float omega1 = 0;
float lastOmega1 = 0;
float deltaOmega1 = 0;
float alpha1 = 0;

float x1 = 0;
float vx1 = 0;
float ax1 = 0;

float y1 = 0;
float vy1 = 0;
float ay1 = 0;


float theta2 = 0;
float lastTheta2 = 0;
float deltaTheta2 = 0;
float omega2 = 0;
float lastOmega2 = 0;
float deltaOmega2 = 0;
float alpha2 = 0;

float x2 = 0;
float vx2 = 0;
float ax2 = 0;

float y2 = 0;
float vy2 = 0;
float ay2 = 0;

// Physics Constants (for now)
final float l1 = Constants.length1;
final float m1 = Constants.mass1;

final float l2 = Constants.length2;
final float m2 = Constants.mass2;


// Time
int lastMillis = 0;
int deltaMillis = 0;

// Debug Text
int textLine = 1;
int textMaxLength = 0;
int textShift = 6;

PFont font;

void setup() {
  size(720, 720);
  background(0);
  
  font = loadFont("Consolas-12.vlw");
  textFont(font, 12);
}

void draw() {
  int now = millis();
  deltaMillis = now - lastMillis;
  float deltaSec = deltaMillis / 1000.0;
  translate(width / 2, height / 2);  // Moves the origin to the center of the window
  scale(1, -1);  // Inverts the Y axis so it points up like we're used to. It hopefully will make math easier later
  background(0);
  textLine = 1;
  textMaxLength = 0;
  textShift = 6;
  
  // Calculate *physics*
  // Calculate rotational kinematics of first pendulum
  deltaTheta1 = theta1 - lastTheta1;
  omega1 = deltaTheta1 / deltaSec;
  
  deltaOmega1 = omega1 - lastOmega1;
  alpha1 = deltaOmega1 / deltaSec;
  
  // Calculate rotational kinematics of second pendulum
  deltaTheta2 = theta2 - lastTheta2;
  omega2 = deltaTheta2 / deltaSec;
  
  deltaOmega2 = omega2 - lastOmega2;
  alpha2 = deltaOmega2 / deltaSec;
  
  
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
  
  // Draw debug
  // [TODO] add toggle (d?)
  scale(1, -1);
  translate(-width / 2, -height / 2);
  debug();
  
  // Cleanup for the next frame
  lastMillis = now;
  
  lastTheta1 = theta1;
  lastOmega1 = omega1;
  
  lastTheta2 = theta2;
  lastOmega2 = omega2;
}

private float drawScale(float n) {
  return n * Constants.lengthScaleFactor;
}

private void debug() {
  fill(255);
  textDraw("Gravity: " + Constants.g + "m/s");
  textDraw("Mass Scale Factor: " + Constants.massScaleFactor);
  textDraw("Length Scale Factor: " + Constants.lengthScaleFactor);
  textDraw();
  
  fill(128, 255, 128);
  textDraw("W: " + width + "px");
  textDraw("H: " + height + "px");
  fill(0, 255, 0);
  textDraw("Frame Rate: " + String.format("%1$-" + 9 + "s", frameRate) + "fps");
  textDraw("Rendered Frames: " + frameCount + "frames");
  textDraw("Elapsed Time: " + millis() + "ms");
  textDraw("Last Time: " + lastMillis + "ms");
  textDraw("Interframe Time: " + deltaMillis + "ms");
  nextColumn();
  
  fill(255, 128, 128);
  textDraw("L₁  " + l1 + "m");
  textDraw("M₁  " + m1 + "kg");
  textDraw();
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
  textShift = (textMaxLength * 6) + 32 + textShift;
  textMaxLength = 0;
}
