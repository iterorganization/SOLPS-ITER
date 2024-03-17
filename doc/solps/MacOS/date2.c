/*  VERSION : 28.05.95 19:11  */
#include <stdio.h>
#include <time.h>

int date2(char *dt) {
    struct tm *t;
    time_t s;
    int y;
    time(&s);
    t = localtime(&s);
    y = t->tm_year;
    sprintf(dt, "%02d.%02d.%02d", t->tm_mday, (t->tm_mon) + 1, y);
    return 0; // Return value indicating success
}

int date2_(char *dt) {
    return date2(dt);
}