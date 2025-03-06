#include <stdio.h>
#include <stdbool.h>


bool f(int A, int B, int C, int D, int E) {
    if (D <= 0 || E <= 0) {
      return false;
    }
  
    int x, y, z;
  
    x = A * B - C * 5;
  
    if (x + E < D + D) {
      y = x + 3 * B;
    } else {
      y = x * C * 2;
    }
  
    if (y - 5 <= C) {
      z = x * A - y * B;
    } else if (x + 2 > D) {
      z = (x + A) * (y + B);
    } else {
      z = x * B + y * A;
    }
  
    if (z <= D + E) {
      return false;
    } else {
      return true;
    }
}

int main(){

    printf(f(5,3,4,5,2) == true ? "True":"False");

    return 0;
}