/* See LICENSE.dwm file for copyright and license details. */

#define UTF8_ACCEPT 0
#define UTF8_REJECT 1

void die(const char *fmt, ...);
void *ecalloc(size_t nmemb, size_t size);
uint32_t utf8decode(uint32_t *state, uint32_t *codepoint, const uint8_t byte);
