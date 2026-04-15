// Generalt kod a DogLang programbol: GCD
#include <stdio.h>

int main() {
    int a = 48;
    int b = 18;
    int temp;
    printf("%d\n", a);
    printf("%d\n", b);
    while ((b != 0)) {
        temp = (a % b);
        a = b;
        b = temp;
    }
    fprintf(stderr, "HOWL: %d\n", a);
    return 0;
}
