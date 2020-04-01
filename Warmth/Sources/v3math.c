#include "v3math.h"


v3
hsv_shade(const v3* c, const v3* s) {
    v3 r = {0, 0, 0};
    r.x = c->x;
    r.y = c->y;
    r.z = s->z;
    return r;
}


v3
hsv_to_rgb(const v3* hsv) {
    float h = hsv->x, s = hsv->y, v = hsv->z;
    int i = h * 6;
    float f = h * 6 - i;
    float p = v * (1 - s);
    float q = v * (1 - f * s);
    float t = v * (1 - (1 - f) * s);
    float r=0, g=0, b=0;
    switch (i % 6) {
        case 0: r = v; g = t; b = p; break;
        case 1: r = q; g = v; b = p; break;
        case 2: r = p; g = v; b = t; break;
        case 3: r = p; g = q; b = v; break;
        case 4: r = t; g = p; b = v; break;
        case 5: r = v; g = p; b = q; break;
    }
    v3 rgb = {r, g, b};
    return rgb;
}
