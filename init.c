#include <stdio.h>
#include <unistd.h>

int main() {
  while (1) {
    printf("hello, I'm init\n");
    sleep(1);
  }
}
