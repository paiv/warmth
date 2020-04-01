#pragma once


typedef struct {
    float x;
    float y;
    float z;
} v3;


v3 hsv_shade(const v3* c, const v3* s);
v3 hsv_to_rgb(const v3* hsv);
