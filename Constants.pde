public static class Constants {
  static final public float g = -9.8;
  static final public float massScaleFactor = 20;
  static final public float lengthScaleFactor = 150;
  static final public int color1 = 0xff0000;
  static final public float mass1 = 1;
  static final public float length1 = 1;
  static final public int color2 = 0x0000ff;
  static final public float mass2 = 1;
  static final public float length2 = 1;
  
  static final public float cartesianToProcessing(float y) {
    return -y;
  }
}
