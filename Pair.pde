public class Pair {
  T a;
  T b;
  void Pair<T, T>(T a, T b) {
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
}
