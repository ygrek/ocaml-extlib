/* compile using gcc -o zlib-test zlib-test.c -lz

   usage: zlib-test <compression-level> <string>

   where compression-level is from 0 to 9
*/
#include <stdio.h>
#include <zlib.h>
#include <string.h>
#include <stdlib.h>

int
main (int argc, char *argv[])
{
    unsigned char dest[32];
    unsigned long destLen = 31;
    int retval, i;
    int level;
    char *endptr;

    if (argc != 3) {
        fprintf (stderr, "Usage: %s: <compression-level> <string>\n", argv[0]);
        return 1;
    }

    level = strtol (argv[1], &endptr, 10);
    if (endptr == argv[1] || level < 0 || level > 9) {
        fprintf (stderr, "Invalid compression level\n");
        return 1;
    }

    retval = compress2 (dest, &destLen, (unsigned char *)argv[2], strlen (argv[2]), level);
    if (retval != Z_OK) {
        fprintf (stderr, "Error calling zlib compress2 function: %d\n", retval);
        return 1;
    }

    for (i = 0; i < destLen; i++)
        printf ("\\x%02hhx", dest[i]);
    printf ("\n");

    return 0;
}
