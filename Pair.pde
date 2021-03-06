public class Pair<T> {
  T a;
  T b;
  public Pair(T a, T b) {
    this.a = a;
    this.b = b;
  }
  
  T getA() {
    return a;
  }
  
  void setA(T a) {
    this.a = a;
  }
  
  T getB() {
    return b;
  }
  
  void setB(T b) {
    this.b = b;
  }
  
  String toString() {
    return "(" + a + ", " + b + ")";
  }
}
