#include "softfloat.h"
#include "softfloat_types.h"

uint16_t fp16_mac(uint16_t a, uint16_t b, uint16_t acc) {
    float16_t fa, fb, facc;
    fa.v = a;
    fb.v = b;
    facc.v = acc;

    float16_t result = f16_mulAdd(fa, fb, facc);
    return result.v;
}