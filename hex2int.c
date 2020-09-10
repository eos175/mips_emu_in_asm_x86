#include "stdint.h"


/*

https://stackoverflow.com/questions/10156409/convert-hex-string-char-to-int


https://stackoverflow.com/questions/8011700/how-do-i-extract-specific-n-bits-of-a-32-bit-unsigned-integer-in-c


*/



/**
 * hex2int
 * take a hex string and convert it to a 32bit number (max 8 hex digits)
 */

uint32_t hex2int(const char *str) 
{
    uint32_t res = 0;
    uint8_t c;

    while (*str) {
        c = *str++;

        // transform hex character to the 4bit equivalent number, using the ascii table indexes
        if (c >= '0' && c <= '9') c = c - '0';
        else if (c >= 'a' && c <='f') c = c - 'a' + 10;
        else if (c >= 'A' && c <='F') c = c - 'A' + 10;

        // shift 4 to make space for new digit, and add the 4 bits of the new digit 
        res = (res << 4) | (c & 0xF);
    }

    return res;
}




/**
 * xtou64
 * Take a hex string and convert it to a 64bit number (max 16 hex digits).
 * The string must only contain digits and valid hex characters.
 */
uint32_t xtou64(const char *str)
{
    uint32_t res = 0;
    char c;

    while ((c = *str++)) {
        c = (c & 0xF) + (c >> 6) | ((c >> 3) & 0x8);
        res = (res << 4) | c;
    }

    return res;
}

